import React, { createContext, useContext, useState, useEffect, useCallback } from 'react';
import { supabase } from '../utils/supabaseClient';

export interface SyncOperation {
  id: string;
  table: string;
  action: 'INSERT' | 'UPDATE' | 'DELETE' | 'UPSERT';
  data: any;
  timestamp: number;
}

interface SyncContextProps {
  isOnline: boolean;
  isSyncing: boolean;
  hasPendingChanges: boolean;
  enqueueChange: (table: string, action: SyncOperation['action'], data: any) => Promise<void>;
  triggerSync: () => Promise<void>;
  offlineCache: {
    get: (key: string) => any;
    set: (key: string, data: any) => void;
  };
}

const SyncContext = createContext<SyncContextProps | undefined>(undefined);

export const SyncProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [isOnline, setIsOnline] = useState(navigator.onLine);
  const [isSyncing, setIsSyncing] = useState(false);
  const [queue, setQueue] = useState<SyncOperation[]>([]);

  // Initialize queue from local storage
  useEffect(() => {
    const savedQueue = localStorage.getItem('hajri_sync_queue');
    if (savedQueue) {
      try {
        setQueue(JSON.parse(savedQueue));
      } catch (e) {
        console.error('Failed to parse sync queue', e);
      }
    }

    const handleOnline = () => setIsOnline(true);
    const handleOffline = () => setIsOnline(false);

    window.addEventListener('online', handleOnline);
    window.addEventListener('offline', handleOffline);

    return () => {
      window.removeEventListener('online', handleOnline);
      window.removeEventListener('offline', handleOffline);
    };
  }, []);

  // Persist queue to localStorage whenever it changes
  useEffect(() => {
    localStorage.setItem('hajri_sync_queue', JSON.stringify(queue));
  }, [queue]);

  // Offline cache implementation
  const offlineCache = {
    get: (key: string) => {
      const val = localStorage.getItem(`hajri_cache_${key}`);
      if (!val) return null;
      try {
        return JSON.parse(val);
      } catch {
        return null;
      }
    },
    set: (key: string, data: any) => {
      localStorage.setItem(`hajri_cache_${key}`, JSON.stringify(data));
    }
  };

  // Enqueue a local modification
  const enqueueChange = useCallback(async (
    table: string,
    action: SyncOperation['action'],
    data: any
  ) => {
    const newOp: SyncOperation = {
      id: crypto.randomUUID ? crypto.randomUUID() : Math.random().toString(36).substring(2),
      table,
      action,
      data,
      timestamp: Date.now()
    };

    // Update local cache state immediately to ensure instantaneous UI updates (Optimistic UI)
    updateLocalCacheOptimistically(table, action, data);

    setQueue(prev => [...prev, newOp]);
  }, []);

  // Optimistically update the cache for instant offline responsiveness
  const updateLocalCacheOptimistically = (table: string, action: SyncOperation['action'], data: any) => {
    if (table === 'workers') {
      const cached = offlineCache.get('workers') || [];
      if (action === 'INSERT') {
        offlineCache.set('workers', [...cached, { ...data, created_at: new Date().toISOString() }]);
      } else if (action === 'UPDATE' || action === 'UPSERT') {
        offlineCache.set('workers', cached.map((w: any) => w.id === data.id ? { ...w, ...data } : w));
      } else if (action === 'DELETE') {
        offlineCache.set('workers', cached.filter((w: any) => w.id !== data.id));
      }
    } else if (table === 'attendance') {
      const cached = offlineCache.get('attendance') || [];
      if (action === 'INSERT' || action === 'UPSERT') {
        const itemIndex = cached.findIndex((a: any) => a.worker_id === data.worker_id && a.date === data.date);
        if (itemIndex > -1) {
          cached[itemIndex] = { ...cached[itemIndex], ...data };
          offlineCache.set('attendance', [...cached]);
        } else {
          offlineCache.set('attendance', [...cached, data]);
        }
      }
    }
  };

  // Process queue and sync with Supabase
  const triggerSync = useCallback(async () => {
    if (!isOnline || queue.length === 0 || isSyncing) return;

    setIsSyncing(true);
    const tempQueue = [...queue];
    const failedOps: SyncOperation[] = [];

    // Order operations by timestamp to preserve causal consistency
    tempQueue.sort((a, b) => a.timestamp - b.timestamp);

    for (const op of tempQueue) {
      try {
        let error = null;

        if (op.action === 'INSERT') {
          const { error: err } = await supabase.from(op.table).insert(op.data);
          error = err;
        } else if (op.action === 'UPDATE') {
          // Expects data to contain id parameter
          const { id, ...updateFields } = op.data;
          const { error: err } = await supabase.from(op.table).update(updateFields).eq('id', id);
          error = err;
        } else if (op.action === 'UPSERT') {
          const { error: err } = await supabase.from(op.table).upsert(op.data);
          error = err;
        } else if (op.action === 'DELETE') {
          const { error: err } = await supabase.from(op.table).delete().eq('id', op.data.id);
          error = err;
        }

        if (error) {
          console.error(`Sync failed for operation on table ${op.table}:`, error);
          failedOps.push(op);
        }
      } catch (err) {
        console.error(`Network or execution error during sync for ${op.table}:`, err);
        failedOps.push(op);
      }
    }

    setQueue(failedOps);
    setIsSyncing(false);
  }, [isOnline, queue, isSyncing]);

  // Run automatic sync when status shifts to online or on interval
  useEffect(() => {
    if (isOnline && queue.length > 0) {
      triggerSync();
    }
  }, [isOnline, queue.length, triggerSync]);

  return (
    <SyncContext.Provider value={{
      isOnline,
      isSyncing,
      hasPendingChanges: queue.length > 0,
      enqueueChange,
      triggerSync,
      offlineCache
    }}>
      {children}
    </SyncContext.Provider>
  );
};

export const useSync = () => {
  const context = useContext(SyncContext);
  if (!context) {
    throw new Error('useSync must be used within a SyncProvider');
  }
  return context;
};
