import React, { useState } from 'react';
import { useContractorDashboardStats, useWorkers } from '../hooks/useSupabase';
import { useTranslation } from '../context/LanguageContext';
import { useSync } from '../context/SyncContext';
import { SyncIndicator } from '../components/SyncIndicator';
import { LanguageSelect } from '../components/LanguageSelect';
import {
  Users,
  Briefcase,
  TrendingUp,
  CreditCard,
  Plus,
  CalendarDays,
  Coins,
  Wallet,
  Clock,
  QrCode,
  LogOut,
  Moon,
  Sun
} from 'lucide-react';
import { BottomSheet } from '../components/BottomSheet';
import { QRScanner } from '../components/QRScanner';
import { useNavigate } from 'react-router-dom';
import { supabase } from '../utils/supabaseClient';

export const Dashboard: React.FC = () => {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const stats = useContractorDashboardStats();
  const [isQuickActionsOpen, setIsQuickActionsOpen] = useState(false);
  const [isQrScannerOpen, setIsQrScannerOpen] = useState(false);

  // Time-based greeting
  const getGreeting = () => {
    const hours = new Date().getHours();
    if (hours < 12) return t('goodMorning');
    if (hours < 17) return t('goodAfternoon');
    return t('goodEvening');
  };

  const handleLogout = async () => {
    await supabase.auth.signOut();
  };

  const handleQrScanSuccess = (workerId: string) => {
    navigate(`/workers/${workerId}`);
  };

  return (
    <div className="flex flex-col min-h-screen bg-zinc-50 dark:bg-zinc-950 pb-24 text-zinc-900 dark:text-zinc-100">
      {/* Top Banner / Header */}
      <header className="sticky top-0 z-40 bg-white/80 dark:bg-zinc-900/80 backdrop-blur-md border-b border-zinc-200/50 dark:border-zinc-800/50 px-5 py-4 flex items-center justify-between">
        <div className="flex items-center gap-2">
          <div className="w-10 h-10 rounded-2xl bg-violet-600 flex items-center justify-center text-white font-bold text-xl shadow-md shadow-violet-500/30">
            H
          </div>
          <div>
            <h1 className="text-base sm:text-xl font-black tracking-tight text-zinc-900 dark:text-white m-0">
              {t('appName')}
            </h1>
            <p className="text-[10px] text-zinc-500 font-medium m-0 -mt-1">
              Rojgar Card Digitalized
            </p>
          </div>
        </div>
        <div className="flex items-center gap-3">
          <SyncIndicator />
          <button
            onClick={() => setIsQrScannerOpen(true)}
            className="p-2 text-zinc-500 dark:text-zinc-400 hover:bg-zinc-100 dark:hover:bg-zinc-850 rounded-xl transition-all"
            title="Scan QR Code"
          >
            <QrCode size={20} />
          </button>
        </div>
      </header>

      {/* Main Container */}
      <main className="p-5 flex-1 max-w-lg mx-auto w-full flex flex-col gap-6">
        
        {/* Welcome and Greeting */}
        <div className="flex flex-row items-center justify-between gap-3">
          <div className="text-left min-w-0">
            <p className="text-xs text-zinc-500 dark:text-zinc-400 font-semibold">{getGreeting()},</p>
            <h2 className="text-lg sm:text-2xl font-black text-zinc-900 dark:text-white mt-0.5 truncate">
              Contractor Dashboard
            </h2>
          </div>
          <div className="flex-shrink-0">
            <LanguageSelect />
          </div>
        </div>

        {/* Overview Stats Cards Grid */}
        <div className="grid grid-cols-2 gap-4">
          {/* Active Workers */}
          <div className="bg-white dark:bg-zinc-900 p-4 rounded-3xl border border-zinc-200 dark:border-zinc-800/70 shadow-sm flex flex-col sm:flex-row items-start sm:items-center gap-3 sm:gap-3.5 text-left">
            <div className="w-10 h-10 sm:w-12 sm:h-12 rounded-2xl bg-blue-100 dark:bg-blue-950/40 text-blue-600 dark:text-blue-400 flex items-center justify-center flex-shrink-0">
              <Users size={20} className="sm:w-[22px] sm:h-[22px]" />
            </div>
            <div className="min-w-0">
              <p className="text-[10px] sm:text-[11px] text-zinc-505 dark:text-zinc-400 uppercase font-black tracking-wider m-0 truncate">
                {t('todaysLabour')}
              </p>
              <h3 className="text-lg sm:text-xl font-extrabold m-0 mt-0.5">
                {stats.totalWorkersCount}
              </h3>
            </div>
          </div>

          {/* Active Projects */}
          <div className="bg-white dark:bg-zinc-900 p-4 rounded-3xl border border-zinc-200 dark:border-zinc-800/70 shadow-sm flex flex-col sm:flex-row items-start sm:items-center gap-3 sm:gap-3.5 text-left">
            <div className="w-10 h-10 sm:w-12 sm:h-12 rounded-2xl bg-purple-100 dark:bg-purple-950/40 text-purple-600 dark:text-purple-400 flex items-center justify-center flex-shrink-0">
              <Briefcase size={20} className="sm:w-[22px] sm:h-[22px]" />
            </div>
            <div className="min-w-0">
              <p className="text-[10px] sm:text-[11px] text-zinc-505 dark:text-zinc-400 uppercase font-black tracking-wider m-0 truncate">
                {t('projects')}
              </p>
              <h3 className="text-lg sm:text-xl font-extrabold m-0 mt-0.5">
                {stats.activeProjectsCount}
              </h3>
            </div>
          </div>
        </div>

        {/* Today's Stats Banner Card */}
        <div className="bg-gradient-to-br from-violet-600 to-indigo-700 text-white rounded-3xl p-6 shadow-lg shadow-violet-500/20 text-left relative overflow-hidden">
          {/* Background circles */}
          <div className="absolute right-0 bottom-0 w-32 h-32 bg-white/5 rounded-full -mr-8 -mb-8 pointer-events-none" />
          <div className="absolute left-1/3 top-0 w-24 h-24 bg-white/5 rounded-full -mt-8 pointer-events-none" />

          <p className="text-xs text-white/80 uppercase font-black tracking-wider m-0">
            {t('todaysWage')}
          </p>
          <h3 className="text-3xl font-black m-0 mt-1">
            ₹{stats.todaysWageExpense.toLocaleString()}
          </h3>

          <div className="grid grid-cols-2 gap-4 mt-6 pt-5 border-t border-white/10">
            <div>
              <p className="text-[10px] text-white/70 uppercase font-black tracking-wider m-0">
                {t('present')}
              </p>
              <h4 className="text-lg font-bold m-0 mt-0.5">
                {stats.presentTodayCount}
              </h4>
            </div>
            <div>
              <p className="text-[10px] text-white/70 uppercase font-black tracking-wider m-0">
                {t('absent')}
              </p>
              <h4 className="text-lg font-bold m-0 mt-0.5">
                {stats.absentTodayCount}
              </h4>
            </div>
          </div>
        </div>

        {/* Core Actions Grid */}
        <div className="flex flex-col gap-3.5">
          <h3 className="text-sm font-bold text-zinc-500 dark:text-zinc-400 uppercase tracking-wider text-left">
            Quick Actions
          </h3>

          <div className="grid grid-cols-2 gap-4">
            {/* Take Attendance */}
            <button
              onClick={() => navigate('/attendance')}
              className="bg-white dark:bg-zinc-900 border border-zinc-150 dark:border-zinc-800/70 p-5 rounded-3xl flex flex-col items-start text-left gap-4 hover:border-violet-300 dark:hover:border-violet-850 hover:shadow-md transition-all group"
            >
              <div className="w-12 h-12 rounded-2xl bg-emerald-100 dark:bg-emerald-950/40 text-emerald-600 dark:text-emerald-400 flex items-center justify-center group-hover:scale-110 transition-transform">
                <CalendarDays size={24} />
              </div>
              <div>
                <h4 className="text-base font-bold m-0 text-zinc-900 dark:text-white">
                  {t('takeAttendance')}
                </h4>
                <p className="text-[11px] text-zinc-500 mt-1 leading-normal">
                  Log today's labor cards with 1 tap.
                </p>
              </div>
            </button>

            {/* Workers List */}
            <button
              onClick={() => navigate('/workers')}
              className="bg-white dark:bg-zinc-900 border border-zinc-150 dark:border-zinc-800/70 p-5 rounded-3xl flex flex-col items-start text-left gap-4 hover:border-violet-300 dark:hover:border-violet-850 hover:shadow-md transition-all group"
            >
              <div className="w-12 h-12 rounded-2xl bg-indigo-100 dark:bg-indigo-950/40 text-indigo-600 dark:text-indigo-400 flex items-center justify-center group-hover:scale-110 transition-transform">
                <Users size={24} />
              </div>
              <div>
                <h4 className="text-base font-bold m-0 text-zinc-900 dark:text-white">
                  {t('allWorkers')}
                </h4>
                <p className="text-[11px] text-zinc-500 mt-1 leading-normal">
                  Manage worker details & profiles.
                </p>
              </div>
            </button>

            {/* Pay Salary */}
            <button
              onClick={() => {
                setIsQuickActionsOpen(true);
              }}
              className="bg-white dark:bg-zinc-900 border border-zinc-150 dark:border-zinc-800/70 p-5 rounded-3xl flex flex-col items-start text-left gap-4 hover:border-violet-300 dark:hover:border-violet-850 hover:shadow-md transition-all group"
            >
              <div className="w-12 h-12 rounded-2xl bg-amber-100 dark:bg-amber-950/40 text-amber-600 dark:text-amber-400 flex items-center justify-center group-hover:scale-110 transition-transform">
                <Wallet size={24} />
              </div>
              <div>
                <h4 className="text-base font-bold m-0 text-zinc-900 dark:text-white">
                  {t('paySalary')}
                </h4>
                <p className="text-[11px] text-zinc-500 mt-1 leading-normal">
                  Record payroll payouts.
                </p>
              </div>
            </button>

            {/* Reports */}
            <button
              onClick={() => navigate('/reports')}
              className="bg-white dark:bg-zinc-900 border border-zinc-150 dark:border-zinc-800/70 p-5 rounded-3xl flex flex-col items-start text-left gap-4 hover:border-violet-300 dark:hover:border-violet-850 hover:shadow-md transition-all group"
            >
              <div className="w-12 h-12 rounded-2xl bg-red-100 dark:bg-red-950/40 text-red-600 dark:text-red-400 flex items-center justify-center group-hover:scale-110 transition-transform">
                <CreditCard size={24} />
              </div>
              <div>
                <h4 className="text-base font-bold m-0 text-zinc-900 dark:text-white">
                  {t('reports')}
                </h4>
                <p className="text-[11px] text-zinc-500 mt-1 leading-normal">
                  Generate sheets & monthly cards.
                </p>
              </div>
            </button>
          </div>
        </div>

        {/* Cash Flow Summary */}
        <div className="bg-white dark:bg-zinc-900 p-5 rounded-3xl border border-zinc-150 dark:border-zinc-800/70 shadow-sm text-left">
          <h3 className="text-sm font-bold text-zinc-500 dark:text-zinc-400 uppercase tracking-wider mb-4">
            {t('cashFlow')}
          </h3>
          <div className="flex flex-col gap-3.5">
            <div className="flex justify-between items-center pb-2.5 border-b border-zinc-100 dark:border-zinc-800">
              <span className="text-xs text-zinc-500">Total Wages Allocated</span>
              <span className="text-sm font-bold">₹{(stats.todaysWageExpense * 30).toLocaleString()} <span className="text-[10px] text-zinc-400 font-normal">/mo est.</span></span>
            </div>
            <div className="flex justify-between items-center pb-2.5 border-b border-zinc-100 dark:border-zinc-800">
              <span className="text-xs text-zinc-500">Paid out this month</span>
              <span className="text-sm font-bold text-green-600">₹{stats.totalPaid.toLocaleString()}</span>
            </div>
            <div className="flex justify-between items-center">
              <span className="text-xs text-zinc-500">Total Advances Active</span>
              <span className="text-sm font-bold text-amber-600">₹{stats.totalAdvance.toLocaleString()}</span>
            </div>
          </div>
        </div>
        
        {/* Settings, Sign Out options */}
        <div className="flex justify-center gap-4 mt-4">
          <button
            onClick={() => navigate('/projects')}
            className="flex items-center gap-1.5 text-xs text-zinc-500 hover:text-zinc-800 dark:hover:text-zinc-200 transition-colors"
          >
            <Briefcase size={14} />
            <span>Manage Projects</span>
          </button>
          <span className="text-zinc-300 dark:text-zinc-800">|</span>
          <button
            onClick={handleLogout}
            className="flex items-center gap-1.5 text-xs text-red-500 hover:text-red-600 transition-colors"
          >
            <LogOut size={14} />
            <span>Sign Out</span>
          </button>
        </div>

      </main>

      {/* Floating Action Button (FAB) for Primary Quick Actions */}
      <button
        onClick={() => setIsQuickActionsOpen(true)}
        className="fixed bottom-6 right-6 z-40 w-14 h-14 bg-violet-600 hover:bg-violet-500 text-white rounded-full flex items-center justify-center shadow-lg shadow-violet-500/40 active:scale-95 transition-transform"
        aria-label="Quick Actions"
      >
        <Plus size={28} />
      </button>

      {/* QR Code Scanner Overlay */}
      <QRScanner
        isOpen={isQrScannerOpen}
        onClose={() => setIsQrScannerOpen(false)}
        onScanSuccess={handleQrScanSuccess}
      />

      {/* Bottom Sheet for unified quick actions */}
      <BottomSheet
        isOpen={isQuickActionsOpen}
        onClose={() => setIsQuickActionsOpen(false)}
        title={t('quickActions')}
      >
        <div className="grid grid-cols-1 gap-2.5 py-2">
          <button
            onClick={() => {
              setIsQuickActionsOpen(false);
              navigate('/workers?add=true');
            }}
            className="flex items-center gap-4 p-4 hover:bg-zinc-50 dark:hover:bg-zinc-800/50 rounded-2xl text-left border border-zinc-100 dark:border-zinc-800 transition-colors"
          >
            <div className="w-10 h-10 rounded-xl bg-violet-100 dark:bg-violet-950/40 text-violet-600 dark:text-violet-400 flex items-center justify-center">
              <Plus size={20} />
            </div>
            <div>
              <span className="block text-sm font-bold text-zinc-900 dark:text-white">
                {t('addLabour')}
              </span>
              <span className="block text-[10px] text-zinc-500">
                Register a new worker profile.
              </span>
            </div>
          </button>

          <button
            onClick={() => {
              setIsQuickActionsOpen(false);
              navigate('/attendance');
            }}
            className="flex items-center gap-4 p-4 hover:bg-zinc-50 dark:hover:bg-zinc-800/50 rounded-2xl text-left border border-zinc-100 dark:border-zinc-800 transition-colors"
          >
            <div className="w-10 h-10 rounded-xl bg-emerald-100 dark:bg-emerald-950/40 text-emerald-600 dark:text-emerald-400 flex items-center justify-center">
              <CalendarDays size={20} />
            </div>
            <div>
              <span className="block text-sm font-bold text-zinc-900 dark:text-white">
                {t('takeAttendance')}
              </span>
              <span className="block text-[10px] text-zinc-500">
                Mark today's attendance checklist.
              </span>
            </div>
          </button>

          <button
            onClick={() => {
              setIsQuickActionsOpen(false);
              navigate('/workers');
            }}
            className="flex items-center gap-4 p-4 hover:bg-zinc-50 dark:hover:bg-zinc-800/50 rounded-2xl text-left border border-zinc-100 dark:border-zinc-800 transition-colors"
          >
            <div className="w-10 h-10 rounded-xl bg-amber-100 dark:bg-amber-950/40 text-amber-600 dark:text-amber-400 flex items-center justify-center">
              <Wallet size={20} />
            </div>
            <div>
              <span className="block text-sm font-bold text-zinc-900 dark:text-white">
                Record Payment
              </span>
              <span className="block text-[10px] text-zinc-500">
                Give advance salary or complete payroll payments.
              </span>
            </div>
          </button>

          <button
            onClick={() => {
              setIsQuickActionsOpen(false);
              setIsQrScannerOpen(true);
            }}
            className="flex items-center gap-4 p-4 hover:bg-zinc-50 dark:hover:bg-zinc-800/50 rounded-2xl text-left border border-zinc-100 dark:border-zinc-800 transition-colors"
          >
            <div className="w-10 h-10 rounded-xl bg-blue-100 dark:bg-blue-950/40 text-blue-600 dark:text-blue-400 flex items-center justify-center">
              <QrCode size={20} />
            </div>
            <div>
              <span className="block text-sm font-bold text-zinc-900 dark:text-white">
                {t('scanQrCode')}
              </span>
              <span className="block text-[10px] text-zinc-500">
                Open profile immediately using worker QR card.
              </span>
            </div>
          </button>
        </div>
      </BottomSheet>
    </div>
  );
};
