import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabaseAdmin } from '../../utils/supabaseAdmin';

// ─── TYPES ────────────────────────────────────────────────────────────────────

export interface ContractorProfile {
  id: string;
  full_name: string;
  company_name?: string;
  phone?: string;
  email?: string;
  created_at: string;
}

export interface AdminWorker {
  id: string;
  contractor_id: string;
  full_name: string;
  phone?: string;
  village?: string;
  daily_wage: number;
  status: string;
  joining_date: string;
  created_at: string;
}

export interface AdminAttendance {
  id: string;
  contractor_id: string;
  worker_id: string;
  date: string;
  status: string;
  created_at: string;
}

export interface AdminTransaction {
  id: string;
  contractor_id: string;
  worker_id: string;
  transaction_type: string;
  amount: number;
  transaction_date: string;
  created_at: string;
}

export interface AuditActivity {
  id: string;
  type: 'attendance' | 'worker' | 'transaction';
  action: string;
  contractor_id: string;
  details: string;
  timestamp: string;
}

// ─── HOOKS ────────────────────────────────────────────────────────────────────

export const useAllContractors = () =>
  useQuery({
    queryKey: ['admin', 'contractors'],
    queryFn: async () => {
      const { data, error } = await supabaseAdmin
        .from('profiles')
        .select('*')
        .order('created_at', { ascending: false });
      if (error) throw error;
      return data as ContractorProfile[];
    },
    staleTime: 30_000,
  });

export const useAllWorkers = (contractorId?: string) =>
  useQuery({
    queryKey: ['admin', 'workers', contractorId ?? 'all'],
    queryFn: async () => {
      let q = supabaseAdmin
        .from('workers')
        .select('*')
        .order('full_name', { ascending: true });
      if (contractorId) q = q.eq('contractor_id', contractorId);
      const { data, error } = await q;
      if (error) throw error;
      return data as AdminWorker[];
    },
    staleTime: 30_000,
  });

export const useGlobalAttendanceToday = () =>
  useQuery({
    queryKey: ['admin', 'attendance', 'today'],
    queryFn: async () => {
      const today = new Date().toISOString().split('T')[0];
      const { data, error } = await supabaseAdmin
        .from('attendance')
        .select('*')
        .eq('date', today);
      if (error) throw error;
      return data as AdminAttendance[];
    },
    staleTime: 60_000,
    refetchInterval: 60_000,
  });

export const useAttendanceLast30Days = () =>
  useQuery({
    queryKey: ['admin', 'attendance', '30d'],
    queryFn: async () => {
      const from = new Date();
      from.setDate(from.getDate() - 30);
      const { data, error } = await supabaseAdmin
        .from('attendance')
        .select('date, status, contractor_id')
        .gte('date', from.toISOString().split('T')[0])
        .in('status', ['Present', 'Overtime', 'Half Day']);
      if (error) throw error;
      return data as { date: string; status: string; contractor_id: string }[];
    },
    staleTime: 300_000,
  });

export const useGlobalTransactions = () =>
  useQuery({
    queryKey: ['admin', 'transactions'],
    queryFn: async () => {
      const { data, error } = await supabaseAdmin
        .from('transactions')
        .select('*')
        .order('created_at', { ascending: false })
        .limit(500);
      if (error) throw error;
      return data as AdminTransaction[];
    },
    staleTime: 60_000,
  });

export const useRecentActivity = () =>
  useQuery({
    queryKey: ['admin', 'activity'],
    queryFn: async (): Promise<AuditActivity[]> => {
      const today = new Date().toISOString().split('T')[0];
      const weekAgo = new Date();
      weekAgo.setDate(weekAgo.getDate() - 7);

      const [{ data: att }, { data: tx }, { data: workers }] = await Promise.all([
        supabaseAdmin
          .from('attendance')
          .select('id, contractor_id, worker_id, date, status, created_at')
          .gte('created_at', weekAgo.toISOString())
          .order('created_at', { ascending: false })
          .limit(20),
        supabaseAdmin
          .from('transactions')
          .select('id, contractor_id, worker_id, transaction_type, amount, created_at')
          .gte('created_at', weekAgo.toISOString())
          .order('created_at', { ascending: false })
          .limit(20),
        supabaseAdmin
          .from('workers')
          .select('id, contractor_id, full_name, created_at')
          .gte('created_at', weekAgo.toISOString())
          .order('created_at', { ascending: false })
          .limit(20),
      ]);

      const activities: AuditActivity[] = [
        ...(att || []).map((a: any) => ({
          id: a.id,
          type: 'attendance' as const,
          action: `Attendance marked: ${a.status}`,
          contractor_id: a.contractor_id,
          details: `Worker ${a.worker_id?.slice(0, 8)} — ${a.date}`,
          timestamp: a.created_at,
        })),
        ...(tx || []).map((t: any) => ({
          id: t.id,
          type: 'transaction' as const,
          action: `${t.transaction_type}: ₹${t.amount}`,
          contractor_id: t.contractor_id,
          details: `Worker ${t.worker_id?.slice(0, 8)}`,
          timestamp: t.created_at,
        })),
        ...(workers || []).map((w: any) => ({
          id: w.id,
          type: 'worker' as const,
          action: 'New worker added',
          contractor_id: w.contractor_id,
          details: w.full_name,
          timestamp: w.created_at,
        })),
      ];

      return activities.sort(
        (a, b) => new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime()
      );
    },
    staleTime: 30_000,
    refetchInterval: 30_000,
  });

export const useAddWorkerForContractor = () => {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async (worker: {
      contractor_id: string;
      full_name: string;
      phone?: string;
      daily_wage: number;
      joining_date: string;
      village?: string;
      status: string;
    }) => {
      const { data, error } = await supabaseAdmin
        .from('workers')
        .insert({ ...worker, overtime_rate: 0 })
        .select()
        .single();
      if (error) throw error;
      return data;
    },
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['admin', 'workers'] });
      qc.invalidateQueries({ queryKey: ['admin', 'contractors'] });
    },
  });
};

export const useAddContractor = () => {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async (contractor: {
      email: string;
      password: string;
      full_name: string;
      company_name?: string;
      phone?: string;
    }) => {
      const { data, error } = await supabaseAdmin.auth.admin.createUser({
        email: contractor.email,
        password: contractor.password,
        email_confirm: true,
        user_metadata: {
          full_name: contractor.full_name,
          company_name: contractor.company_name,
          phone: contractor.phone,
        },
      });
      if (error) throw error;
      return data;
    },
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['admin', 'contractors'] });
    },
  });
};

