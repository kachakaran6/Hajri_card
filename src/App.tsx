import { useState, useEffect } from 'react';
import { Routes, Route, Navigate, useNavigate } from 'react-router-dom';
import { supabase } from './utils/supabaseClient';
import { Dashboard } from './pages/Dashboard';
import { Workers } from './pages/Workers';
import { WorkerProfile } from './pages/WorkerProfile';
import { Attendance } from './pages/Attendance';
import { Reports } from './pages/Reports';
import { Projects } from './pages/Projects';
import { Lock, Mail, User, Building, Phone } from 'lucide-react';
import { useTranslation } from './context/LanguageContext';

function App() {
  const [session, setSession] = useState<any>(null);
  const [isLoading, setIsLoading] = useState(true);

  // Auth Mode: 'signin' or 'signup'
  const [authMode, setAuthMode] = useState<'signin' | 'signup'>('signin');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [fullName, setFullName] = useState('');
  const [companyName, setCompanyName] = useState('');
  const [phone, setPhone] = useState('');
  
  const [authError, setAuthError] = useState('');
  const [authLoading, setAuthLoading] = useState(false);

  useEffect(() => {
    // 1. Check if we have a demo session saved
    const demoUser = localStorage.getItem('hajri_demo_user');
    if (demoUser) {
      setSession({ user: JSON.parse(demoUser) });
      setIsLoading(false);
      return;
    }

    // 2. Otherwise query Supabase Auth
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session);
      setIsLoading(false);
    });

    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      // If we are in demo mode, ignore supabase auth state changes
      if (localStorage.getItem('hajri_demo_user')) return;
      setSession(session);
    });

    return () => subscription.unsubscribe();
  }, []);

  const handleAuthSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setAuthError('');
    setAuthLoading(true);

    try {
      if (authMode === 'signin') {
        const { data, error } = await supabase.auth.signInWithPassword({
          email,
          password
        });
        if (error) throw error;
        setSession(data.session);
      } else {
        const { data, error } = await supabase.auth.signUp({
          email,
          password,
          options: {
            data: {
              full_name: fullName,
              company_name: companyName,
              phone
            }
          }
        });
        if (error) throw error;
        alert('Registration successful! Please sign in.');
        setAuthMode('signin');
      }
    } catch (err: any) {
      setAuthError(err.message || 'Authentication failed');
    } finally {
      setAuthLoading(false);
    }
  };

  // Demo Mode Login
  const handleDemoMode = () => {
    const dummyUser = {
      id: 'd0000000-0000-0000-0000-000000000000',
      email: 'demo@contractor.com',
      user_metadata: {
        full_name: 'Demo Contractor',
        company_name: 'Vedic Constructions',
        phone: '+91 99999 88888'
      }
    };
    localStorage.setItem('hajri_demo_user', JSON.stringify(dummyUser));
    setSession({ user: dummyUser });
  };

  // Sign out helper
  const handleSignOut = () => {
    localStorage.removeItem('hajri_demo_user');
    supabase.auth.signOut();
    setSession(null);
  };

  if (isLoading) {
    return (
      <div className="flex flex-col items-center justify-center min-h-screen bg-zinc-50 dark:bg-zinc-950 gap-3">
        <div className="w-9 h-9 rounded-full border-3 border-violet-600 border-t-transparent animate-spin" />
        <span className="text-xs text-zinc-500 font-bold">Initializing Rojgar Book...</span>
      </div>
    );
  }

  // Auth Screen (dimmed clean glassmorphic dashboard background)
  if (!session) {
    return (
      <div className="flex items-center justify-center min-h-screen bg-zinc-50 dark:bg-zinc-950 p-5 text-left">
        <div className="w-full max-w-md bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 p-8 rounded-3xl shadow-xl flex flex-col gap-6">
          <div className="text-center">
            <div className="w-12 h-12 rounded-2xl bg-violet-600 flex items-center justify-center text-white font-extrabold text-2xl mx-auto shadow-md shadow-violet-500/20">
              H
            </div>
            <h2 className="text-2xl font-black text-zinc-900 dark:text-white mt-4">
              {authMode === 'signin' ? 'Sign in to Rojgar' : 'Create Contractor Account'}
            </h2>
            <p className="text-xs text-zinc-500 mt-1">
              {authMode === 'signin' ? 'Access your digital attendance cards' : 'Manage your site labor force and wages'}
            </p>
          </div>

          <form onSubmit={handleAuthSubmit} className="flex flex-col gap-4">
            {authError && (
              <div className="p-3 bg-red-50 dark:bg-red-950/20 border border-red-200 dark:border-red-900 text-red-650 dark:text-red-400 rounded-xl text-xs font-bold leading-normal">
                {authError}
              </div>
            )}

            {authMode === 'signup' && (
              <>
                <div className="relative">
                  <User className="absolute left-3 top-3 text-zinc-400" size={18} />
                  <input
                    type="text"
                    required
                    placeholder="Full Name"
                    value={fullName}
                    onChange={e => setFullName(e.target.value)}
                    className="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-800 rounded-xl pl-10 pr-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-violet-500 text-zinc-900 dark:text-white"
                  />
                </div>

                <div className="relative">
                  <Building className="absolute left-3 top-3 text-zinc-400" size={18} />
                  <input
                    type="text"
                    placeholder="Company Name"
                    value={companyName}
                    onChange={e => setCompanyName(e.target.value)}
                    className="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-800 rounded-xl pl-10 pr-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-violet-500 text-zinc-900 dark:text-white"
                  />
                </div>

                <div className="relative">
                  <Phone className="absolute left-3 top-3 text-zinc-400" size={18} />
                  <input
                    type="tel"
                    placeholder="Phone Number"
                    value={phone}
                    onChange={e => setPhone(e.target.value)}
                    className="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-800 rounded-xl pl-10 pr-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-violet-500 text-zinc-900 dark:text-white"
                  />
                </div>
              </>
            )}

            <div className="relative">
              <Mail className="absolute left-3 top-3 text-zinc-400" size={18} />
              <input
                type="email"
                required
                placeholder="Email Address"
                value={email}
                onChange={e => setEmail(e.target.value)}
                className="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-800 rounded-xl pl-10 pr-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-violet-500 text-zinc-900 dark:text-white"
              />
            </div>

            <div className="relative">
              <Lock className="absolute left-3 top-3 text-zinc-400" size={18} />
              <input
                type="password"
                required
                placeholder="Password"
                value={password}
                onChange={e => setPassword(e.target.value)}
                className="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-800 rounded-xl pl-10 pr-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-violet-500 text-zinc-900 dark:text-white"
              />
            </div>

            <button
              type="submit"
              disabled={authLoading}
              className="w-full py-3 bg-violet-600 hover:bg-violet-500 text-white font-bold rounded-xl shadow-md transition-colors mt-2 disabled:opacity-50"
            >
              {authLoading ? 'Signing up...' : authMode === 'signin' ? 'Sign In' : 'Register Contractor'}
            </button>
          </form>

          {/* Toggle modes */}
          <div className="text-center text-xs mt-1">
            {authMode === 'signin' ? (
              <span>
                Don't have an account?{' '}
                <button onClick={() => setAuthMode('signup')} className="text-violet-600 font-extrabold hover:underline">
                  Sign up
                </button>
              </span>
            ) : (
              <span>
                Already have an account?{' '}
                <button onClick={() => setAuthMode('signin')} className="text-violet-600 font-extrabold hover:underline">
                  Sign in
                </button>
              </span>
            )}
          </div>

          <div className="relative my-2">
            <div className="absolute inset-0 flex items-center"><div className="w-full border-t border-zinc-200 dark:border-zinc-800"></div></div>
            <div className="relative flex justify-center text-xs uppercase"><span className="bg-white dark:bg-zinc-900 px-2 text-zinc-400 font-bold">Or Sandbox</span></div>
          </div>

          {/* Demo Mode Button */}
          <button
            onClick={handleDemoMode}
            className="w-full py-2.5 bg-zinc-100 hover:bg-zinc-200 dark:bg-zinc-800 dark:hover:bg-zinc-700 text-zinc-700 dark:text-zinc-300 font-extrabold rounded-xl text-xs transition-colors"
          >
            Explore with Sandbox Demo Mode
          </button>
        </div>
      </div>
    );
  }

  return (
    <Routes>
      <Route path="/" element={<Dashboard />} />
      <Route path="/workers" element={<Workers />} />
      <Route path="/workers/:id" element={<WorkerProfile />} />
      <Route path="/attendance" element={<Attendance />} />
      <Route path="/reports" element={<Reports />} />
      <Route path="/projects" element={<Projects />} />
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}

export default App;
export { App };
