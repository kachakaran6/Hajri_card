import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '../utils/supabaseClient';
import { useSync } from '../context/SyncContext';

// Types representing our DB tables
export interface Project {
  id: string;
  contractor_id: string;
  name: string;
  location?: string;
  start_date?: string;
  end_date?: string;
  status: string;
  notes?: string;
  created_at: string;
}

export interface Worker {
  id: string;
  contractor_id: string;
  photo?: string;
  worker_code?: string;
  full_name: string;
  phone?: string;
  father_name?: string;
  address?: string;
  village?: string;
  city?: string;
  state?: string;
  joining_date: string;
  daily_wage: number;
  overtime_rate: number;
  status: string;
  default_project?: string;
  notes?: string;
  emergency_contact?: string;
  bank_name?: string;
  account_number?: string;
  ifsc?: string;
  upi_id?: string;
  created_at: string;
}

export interface Attendance {
  id: string;
  contractor_id: string;
  worker_id: string;
  project_id?: string;
  date: string;
  status: 'Present' | 'Absent' | 'Half Day' | 'Leave' | 'Holiday' | 'Overtime';
  working_hours: number;
  overtime_hours: number;
  remarks?: string;
  created_at: string;
}

export interface Transaction {
  id: string;
  contractor_id: string;
  worker_id: string;
  project_id?: string;
  transaction_type: 'Salary' | 'Advance' | 'Bonus' | 'Deduction' | 'Adjustment';
  amount: number;
  payment_method: 'Cash' | 'UPI' | 'Bank' | 'Cheque';
  reference_number?: string;
  transaction_date: string;
  remarks?: string;
  created_at: string;
}

export interface MonthlySummary {
  id: string;
  contractor_id: string;
  worker_id: string;
  month: number;
  year: number;
  present_days: number;
  half_days: number;
  leave_days: number;
  absent_days: number;
  holiday_days: number;
  overtime_hours: number;
  gross_amount: number;
  bonus: number;
  deduction: number;
  advance: number;
  paid: number;
  balance: number;
  updated_at: string;
}

// ----------------------------------------------------
// HOOKS
// ----------------------------------------------------

export const useProjects = () => {
  const { isOnline, offlineCache } = useSync();

  return useQuery({
    queryKey: ['projects'],
    queryFn: async () => {
      if (!isOnline) {
        return (offlineCache.get('projects') || []) as Project[];
      }

      const { data, error } = await supabase
        .from('projects')
        .select('*')
        .order('name', { ascending: true });

      if (error) {
        console.error('Fetch projects error, falling back to cache:', error);
        return (offlineCache.get('projects') || []) as Project[];
      }

      offlineCache.set('projects', data);
      return data as Project[];
    }
  });
};

export const useAddProject = () => {
  const queryClient = useQueryClient();
  const { isOnline, enqueueChange } = useSync();

  return useMutation({
    mutationFn: async (newProject: Omit<Project, 'id' | 'contractor_id' | 'created_at'>) => {
      // Get the logged in contractor's ID
      const { data: { user } } = await supabase.auth.getUser();
      const contractor_id = user?.id || '00000000-0000-0000-0000-000000000000';
      const projectWithId = {
        ...newProject,
        id: crypto.randomUUID ? crypto.randomUUID() : Math.random().toString(36).substring(2),
        contractor_id,
        created_at: new Date().toISOString()
      };

      if (!isOnline) {
        await enqueueChange('projects', 'INSERT', projectWithId);
        return projectWithId;
      }

      const { data, error } = await supabase
        .from('projects')
        .insert({
          name: newProject.name,
          location: newProject.location,
          start_date: newProject.start_date,
          end_date: newProject.end_date,
          status: newProject.status,
          notes: newProject.notes,
          contractor_id
        })
        .select()
        .single();

      if (error) throw error;
      return data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['projects'] });
    }
  });
};

export const useWorkers = () => {
  const { isOnline, offlineCache } = useSync();

  return useQuery({
    queryKey: ['workers'],
    queryFn: async () => {
      if (!isOnline) {
        return (offlineCache.get('workers') || []) as Worker[];
      }

      const { data, error } = await supabase
        .from('workers')
        .select('*')
        .order('full_name', { ascending: true });

      if (error) {
        console.error('Fetch workers error, falling back to cache:', error);
        return (offlineCache.get('workers') || []) as Worker[];
      }

      offlineCache.set('workers', data);
      return data as Worker[];
    }
  });
};

export const useAddWorker = () => {
  const queryClient = useQueryClient();
  const { isOnline, enqueueChange } = useSync();

  return useMutation({
    mutationFn: async (newWorker: Omit<Worker, 'id' | 'contractor_id' | 'created_at'>) => {
      const { data: { user } } = await supabase.auth.getUser();
      const contractor_id = user?.id || '00000000-0000-0000-0000-000000000000';
      const id = crypto.randomUUID ? crypto.randomUUID() : Math.random().toString(36).substring(2);
      const workerWithId = {
        ...newWorker,
        id,
        contractor_id,
        created_at: new Date().toISOString()
      };

      if (!isOnline) {
        await enqueueChange('workers', 'INSERT', workerWithId);
        return workerWithId;
      }

      const { data, error } = await supabase
        .from('workers')
        .insert({
          ...newWorker,
          contractor_id
        })
        .select()
        .single();

      if (error) throw error;
      return data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['workers'] });
    }
  });
};

export const useUpdateWorker = () => {
  const queryClient = useQueryClient();
  const { isOnline, enqueueChange } = useSync();

  return useMutation({
    mutationFn: async (updatedWorker: Partial<Worker> & { id: string }) => {
      if (!isOnline) {
        await enqueueChange('workers', 'UPDATE', updatedWorker);
        return updatedWorker;
      }

      const { data, error } = await supabase
        .from('workers')
        .update(updatedWorker)
        .eq('id', updatedWorker.id)
        .select()
        .single();

      if (error) throw error;
      return data;
    },
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: ['workers'] });
      queryClient.invalidateQueries({ queryKey: ['worker', variables.id] });
    }
  });
};

export const useDeleteWorker = () => {
  const queryClient = useQueryClient();
  const { isOnline, enqueueChange } = useSync();

  return useMutation({
    mutationFn: async (id: string) => {
      if (!isOnline) {
        await enqueueChange('workers', 'DELETE', { id });
        return id;
      }

      const { error } = await supabase
        .from('workers')
        .delete()
        .eq('id', id);

      if (error) throw error;
      return id;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['workers'] });
    }
  });
};

export const useAttendance = (date?: string) => {
  const { isOnline, offlineCache } = useSync();
  const targetDate = date || new Date().toISOString().split('T')[0];

  return useQuery({
    queryKey: ['attendance', targetDate],
    queryFn: async () => {
      if (!isOnline) {
        const cached = (offlineCache.get('attendance') || []) as Attendance[];
        return cached.filter(a => a.date === targetDate);
      }

      const { data, error } = await supabase
        .from('attendance')
        .select('*')
        .eq('date', targetDate);

      if (error) {
        console.error('Fetch attendance error, falling back to cache:', error);
        const cached = (offlineCache.get('attendance') || []) as Attendance[];
        return cached.filter(a => a.date === targetDate);
      }

      // Merge into the global attendance cache
      const cached = (offlineCache.get('attendance') || []) as Attendance[];
      const updatedCache = [...cached.filter(a => a.date !== targetDate), ...data];
      offlineCache.set('attendance', updatedCache);

      return data as Attendance[];
    }
  });
};

export const useWorkerAttendance = (workerId: string) => {
  const { isOnline, offlineCache } = useSync();

  return useQuery({
    queryKey: ['attendance', 'worker', workerId],
    queryFn: async () => {
      if (!isOnline) {
        const cached = (offlineCache.get('attendance') || []) as Attendance[];
        return cached.filter(a => a.worker_id === workerId);
      }

      const { data, error } = await supabase
        .from('attendance')
        .select('*')
        .eq('worker_id', workerId)
        .order('date', { ascending: false });

      if (error) {
        console.error('Fetch worker attendance error, falling back to cache:', error);
        const cached = (offlineCache.get('attendance') || []) as Attendance[];
        return cached.filter(a => a.worker_id === workerId);
      }

      // Merge into cache
      const cached = (offlineCache.get('attendance') || []) as Attendance[];
      const nonWorkerCached = cached.filter(a => a.worker_id !== workerId);
      offlineCache.set('attendance', [...nonWorkerCached, ...data]);

      return data as Attendance[];
    }
  });
};

export const useMarkAttendance = () => {
  const queryClient = useQueryClient();
  const { isOnline, enqueueChange } = useSync();

  return useMutation({
    mutationFn: async (attendance: Omit<Attendance, 'id' | 'contractor_id' | 'created_at'>) => {
      const { data: { user } } = await supabase.auth.getUser();
      const contractor_id = user?.id || '00000000-0000-0000-0000-000000000000';
      const id = crypto.randomUUID ? crypto.randomUUID() : Math.random().toString(36).substring(2);
      
      const attendanceWithId = {
        ...attendance,
        id,
        contractor_id,
        created_at: new Date().toISOString()
      };

      if (!isOnline) {
        await enqueueChange('attendance', 'UPSERT', attendanceWithId);
        return attendanceWithId;
      }

      const { data, error } = await supabase
        .from('attendance')
        .upsert({
          ...attendance,
          contractor_id
        }, {
          onConflict: 'worker_id,date'
        })
        .select()
        .single();

      if (error) throw error;
      return data;
    },
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: ['attendance', variables.date] });
      queryClient.invalidateQueries({ queryKey: ['attendance', 'worker', variables.worker_id] });
      queryClient.invalidateQueries({ queryKey: ['monthly_summary', variables.worker_id] });
    }
  });
};

export const useTransactions = (workerId?: string) => {
  const { isOnline, offlineCache } = useSync();

  return useQuery({
    queryKey: workerId ? ['transactions', 'worker', workerId] : ['transactions'],
    queryFn: async () => {
      if (!isOnline) {
        const cached = (offlineCache.get('transactions') || []) as Transaction[];
        return workerId ? cached.filter(t => t.worker_id === workerId) : cached;
      }

      let query = supabase.from('transactions').select('*');
      if (workerId) {
        query = query.eq('worker_id', workerId);
      }
      query = query.order('transaction_date', { ascending: false });

      const { data, error } = await query;

      if (error) {
        console.error('Fetch transactions error, falling back to cache:', error);
        const cached = (offlineCache.get('transactions') || []) as Transaction[];
        return workerId ? cached.filter(t => t.worker_id === workerId) : cached;
      }

      // Cache logic
      const cached = (offlineCache.get('transactions') || []) as Transaction[];
      if (workerId) {
        const nonWorkerTx = cached.filter(t => t.worker_id !== workerId);
        offlineCache.set('transactions', [...nonWorkerTx, ...data]);
      } else {
        offlineCache.set('transactions', data);
      }

      return data as Transaction[];
    }
  });
};

export const useAddTransaction = () => {
  const queryClient = useQueryClient();
  const { isOnline, enqueueChange } = useSync();

  return useMutation({
    mutationFn: async (tx: Omit<Transaction, 'id' | 'contractor_id' | 'created_at'>) => {
      const { data: { user } } = await supabase.auth.getUser();
      const contractor_id = user?.id || '00000000-0000-0000-0000-000000000000';
      const id = crypto.randomUUID ? crypto.randomUUID() : Math.random().toString(36).substring(2);
      
      const txWithId = {
        ...tx,
        id,
        contractor_id,
        created_at: new Date().toISOString()
      };

      if (!isOnline) {
        await enqueueChange('transactions', 'INSERT', txWithId);
        return txWithId;
      }

      const { data, error } = await supabase
        .from('transactions')
        .insert({
          ...tx,
          contractor_id
        })
        .select()
        .single();

      if (error) throw error;
      return data;
    },
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: ['transactions'] });
      queryClient.invalidateQueries({ queryKey: ['transactions', 'worker', variables.worker_id] });
      queryClient.invalidateQueries({ queryKey: ['monthly_summary', variables.worker_id] });
    }
  });
};

export const useMonthlySummaries = (workerId: string) => {
  const { isOnline, offlineCache } = useSync();

  return useQuery({
    queryKey: ['monthly_summary', workerId],
    queryFn: async () => {
      if (!isOnline) {
        const cached = (offlineCache.get('monthly_summaries') || []) as MonthlySummary[];
        return cached.filter(m => m.worker_id === workerId);
      }

      const { data, error } = await supabase
        .from('monthly_summary')
        .select('*')
        .eq('worker_id', workerId)
        .order('year', { ascending: false })
        .order('month', { ascending: false });

      if (error) {
        console.error('Fetch monthly summaries error, falling back to cache:', error);
        const cached = (offlineCache.get('monthly_summaries') || []) as MonthlySummary[];
        return cached.filter(m => m.worker_id === workerId);
      }

      // Merge into cache
      const cached = (offlineCache.get('monthly_summaries') || []) as MonthlySummary[];
      const nonWorkerSummaries = cached.filter(m => m.worker_id !== workerId);
      offlineCache.set('monthly_summaries', [...nonWorkerSummaries, ...data]);

      return data as MonthlySummary[];
    }
  });
};

export const useContractorDashboardStats = () => {
  const { data: workers } = useWorkers();
  const { data: projects } = useProjects();
  const todayDate = new Date().toISOString().split('T')[0];
  const { data: todayAttendance } = useAttendance(todayDate);
  const { data: allTransactions } = useTransactions();

  // Compute stats locally (perfect fallback for offline responsiveness!)
  const totalWorkersCount = workers?.length || 0;
  const activeProjectsCount = projects?.filter(p => p.status === 'Active').length || 0;

  const presentTodayCount = todayAttendance?.filter(a => a.status === 'Present' || a.status === 'Overtime').length || 0;
  const absentTodayCount = todayAttendance?.filter(a => a.status === 'Absent').length || 0;
  const halfDayTodayCount = todayAttendance?.filter(a => a.status === 'Half Day').length || 0;

  // Today's total wage expense
  const todaysWageExpense = todayAttendance?.reduce((total, a) => {
    const worker = workers?.find(w => w.id === a.worker_id);
    if (!worker) return total;
    let factor = 0;
    if (a.status === 'Present' || a.status === 'Overtime') factor = 1.0;
    else if (a.status === 'Half Day') factor = 0.5;
    
    const otWage = (a.overtime_hours || 0) * (worker.overtime_rate || 0);
    return total + (worker.daily_wage * factor) + otWage;
  }, 0) || 0;

  // Cash Flow & Net Dues calculation
  // Let's summarize total transaction amounts
  const totalPaid = allTransactions
    ?.filter(t => t.transaction_type === 'Salary')
    ?.reduce((sum, t) => sum + Number(t.amount), 0) || 0;

  const totalAdvance = allTransactions
    ?.filter(t => t.transaction_type === 'Advance')
    ?.reduce((sum, t) => sum + Number(t.amount), 0) || 0;

  return {
    totalWorkersCount,
    activeProjectsCount,
    presentTodayCount,
    absentTodayCount,
    halfDayTodayCount,
    todaysWageExpense,
    totalPaid,
    totalAdvance
  };
};
