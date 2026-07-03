import { useState, useEffect } from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import { supabase } from './utils/supabaseClient';
import { AdminLayout } from './admin/components/AdminLayout';
import { AdminDashboard } from './admin/pages/AdminDashboard';
import { ContractorsPage } from './admin/pages/ContractorsPage';
import { ContractorDetail } from './admin/pages/ContractorDetail';
import { WorkersPage } from './admin/pages/WorkersPage';
import { AuditLogsPage } from './admin/pages/AuditLogsPage';
import { Lock, Mail, Shield } from 'lucide-react';

// ── ADMIN EMAIL GATE ─────────────────────────────────────────────────────────
// Admin emails that are allowed access
const ADMIN_EMAILS = ['kachakaran6@gmail.com', 'admin@karan.com'];

function isAdminUser(email: string | undefined) {
  if (!email) return false;
  return ADMIN_EMAILS.includes(email.toLowerCase().trim());
}

// ── AUTH SCREEN ───────────────────────────────────────────────────────────────
function AuthScreen() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      const { data, error: authErr } = await supabase.auth.signInWithPassword({ email, password });
      if (authErr) throw authErr;
      if (!isAdminUser(data.user?.email)) {
        await supabase.auth.signOut();
        setError('Access denied. This panel is restricted to admin only.');
      }
    } catch (err: any) {
      setError(err.message || 'Authentication failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-zinc-50 dark:bg-zinc-950 p-4">
      <div className="w-full max-w-sm bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-[8px] shadow-sm">
        {/* Header */}
        <div className="px-6 py-5 border-b border-zinc-200 dark:border-zinc-800">
          <div className="flex items-center gap-2.5">
            <div className="w-8 h-8 bg-zinc-900 dark:bg-zinc-100 rounded-[6px] flex items-center justify-center">
              <Shield className="w-4 h-4 text-white dark:text-zinc-900" />
            </div>
            <div>
              <h1 className="text-sm font-semibold text-zinc-900 dark:text-zinc-100">Hajri Admin</h1>
              <p className="text-[11px] text-zinc-400">Master Control Panel</p>
            </div>
          </div>
        </div>

        {/* Form */}
        <form onSubmit={handleSubmit} className="p-6 flex flex-col gap-3">
          {error && (
            <div className="p-2.5 bg-red-50 dark:bg-red-950/20 border border-red-200 dark:border-red-900 text-red-600 dark:text-red-400 rounded-[6px] text-xs">
              {error}
            </div>
          )}

          <div className="flex flex-col gap-1">
            <label className="text-xs font-medium text-zinc-700 dark:text-zinc-300">Email</label>
            <div className="relative">
              <Mail className="absolute left-2.5 top-1/2 -translate-y-1/2 w-3.5 h-3.5 text-zinc-400" />
              <input
                type="email"
                required
                autoComplete="email"
                placeholder="admin@example.com"
                value={email}
                onChange={e => setEmail(e.target.value)}
                className="w-full pl-8 pr-3 py-2 text-sm bg-zinc-50 dark:bg-zinc-800 border border-zinc-300 dark:border-zinc-700 rounded-[6px] text-zinc-900 dark:text-zinc-100 placeholder-zinc-400 focus:outline-none focus:ring-2 focus:ring-zinc-900 dark:focus:ring-zinc-100"
              />
            </div>
          </div>

          <div className="flex flex-col gap-1">
            <label className="text-xs font-medium text-zinc-700 dark:text-zinc-300">Password</label>
            <div className="relative">
              <Lock className="absolute left-2.5 top-1/2 -translate-y-1/2 w-3.5 h-3.5 text-zinc-400" />
              <input
                type="password"
                required
                autoComplete="current-password"
                placeholder="••••••••"
                value={password}
                onChange={e => setPassword(e.target.value)}
                className="w-full pl-8 pr-3 py-2 text-sm bg-zinc-50 dark:bg-zinc-800 border border-zinc-300 dark:border-zinc-700 rounded-[6px] text-zinc-900 dark:text-zinc-100 placeholder-zinc-400 focus:outline-none focus:ring-2 focus:ring-zinc-900 dark:focus:ring-zinc-100"
              />
            </div>
          </div>

          <button
            type="submit"
            disabled={loading}
            className="w-full mt-1 py-2 bg-zinc-900 dark:bg-zinc-100 text-white dark:text-zinc-900 rounded-[6px] text-sm font-semibold hover:bg-zinc-800 dark:hover:bg-zinc-200 transition-colors disabled:opacity-50"
          >
            {loading ? 'Signing in...' : 'Sign In'}
          </button>
        </form>
      </div>
    </div>
  );
}

// ── APP ───────────────────────────────────────────────────────────────────────
function App() {
  const [session, setSession] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session);
      setLoading(false);
    });

    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      setSession(session);
    });

    return () => subscription.unsubscribe();
  }, []);

  // Init dark mode from localStorage
  useEffect(() => {
    const saved = localStorage.getItem('admin-theme');
    const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
    const isDark = saved === 'dark' || (!saved && prefersDark);
    document.documentElement.classList.toggle('dark', isDark);
  }, []);

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-zinc-50 dark:bg-zinc-950">
        <div className="flex flex-col items-center gap-3">
          <div className="w-8 h-8 bg-zinc-900 dark:bg-zinc-100 rounded-[6px] flex items-center justify-center">
            <Shield className="w-4 h-4 text-white dark:text-zinc-900" />
          </div>
          <div className="w-4 h-4 border-2 border-zinc-300 border-t-zinc-900 dark:border-zinc-600 dark:border-t-zinc-100 rounded-full animate-spin" />
        </div>
      </div>
    );
  }

  if (!session || !isAdminUser(session.user?.email)) {
    return <AuthScreen />;
  }

  return (
    <AdminLayout>
      <Routes>
        <Route path="/" element={<Navigate to="/admin" replace />} />
        <Route path="/admin" element={<AdminDashboard />} />
        <Route path="/admin/contractors" element={<ContractorsPage />} />
        <Route path="/admin/contractors/:id" element={<ContractorDetail />} />
        <Route path="/admin/workers" element={<WorkersPage />} />
        <Route path="/admin/activity" element={<AuditLogsPage />} />
        <Route path="*" element={<Navigate to="/admin" replace />} />
      </Routes>
    </AdminLayout>
  );
}

export default App;
