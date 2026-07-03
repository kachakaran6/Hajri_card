import React from 'react';
import { useSync } from '../context/SyncContext';
import { useTranslation } from '../context/LanguageContext';
import { Cloud, CloudOff, RefreshCw } from 'lucide-react';

export const SyncIndicator: React.FC = () => {
  const { isOnline, isSyncing, hasPendingChanges } = useSync();
  const { t } = useTranslation();

  if (!isOnline) {
    return (
      <div className="flex items-center gap-1 px-3 py-1 text-xs font-semibold text-red-700 bg-red-100 dark:bg-red-950/40 dark:text-red-400 rounded-full border border-red-200 dark:border-red-900 shadow-sm animate-pulse">
        <CloudOff size={14} />
        <span>{t('offlineMode')}</span>
      </div>
    );
  }

  if (isSyncing) {
    return (
      <div className="flex items-center gap-1 px-3 py-1 text-xs font-semibold text-amber-700 bg-amber-100 dark:bg-amber-950/40 dark:text-amber-400 rounded-full border border-amber-200 dark:border-amber-900 shadow-sm">
        <RefreshCw size={14} className="animate-spin" />
        <span>{t('syncing')}</span>
      </div>
    );
  }

  if (hasPendingChanges) {
    return (
      <div className="flex items-center gap-1 px-3 py-1 text-xs font-semibold text-amber-700 bg-amber-100 dark:bg-amber-950/40 dark:text-amber-400 rounded-full border border-amber-200 dark:border-amber-900 shadow-sm animate-pulse">
        <RefreshCw size={14} />
        <span>Sync Pending...</span>
      </div>
    );
  }

  return (
    <div className="flex items-center gap-1 px-3 py-1 text-xs font-semibold text-green-700 bg-green-100 dark:bg-green-950/40 dark:text-green-400 rounded-full border border-green-200 dark:border-green-900 shadow-sm">
      <Cloud size={14} />
      <span>{t('synced')}</span>
    </div>
  );
};
