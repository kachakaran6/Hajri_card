import React, { useState } from 'react';
import { useTranslation } from '../context/LanguageContext';
import { FileText, Download, Share2, Printer, Search, FileSpreadsheet } from 'lucide-react';
import { useNavigate } from 'react-router-dom';

export const Reports: React.FC = () => {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const [selectedMonth, setSelectedMonth] = useState(new Date().getMonth() + 1);
  const [selectedYear, setSelectedYear] = useState(new Date().getFullYear());

  const reportsList = [
    {
      id: 'monthly_hajri',
      title: 'Monthly Hajri Card Book',
      desc: 'Complete yellow-card replication for all active labor forces.',
      icon: FileText,
      color: 'bg-amber-100 dark:bg-amber-950/40 text-amber-600 dark:text-amber-450'
    },
    {
      id: 'salary_sheet',
      title: 'Salary Sheet (Payouts)',
      desc: 'Detailed log of regular salaries, advances, bonuses, and deductions.',
      icon: FileSpreadsheet,
      color: 'bg-emerald-100 dark:bg-emerald-950/40 text-emerald-600 dark:text-emerald-450'
    },
    {
      id: 'attendance_sheet',
      title: 'Attendance Register Book',
      desc: 'Matrix grid of days and statuses for contractor registers.',
      icon: FileText,
      color: 'bg-indigo-100 dark:bg-indigo-950/40 text-indigo-600 dark:text-indigo-450'
    },
    {
      id: 'worker_ledger',
      title: 'Worker Ledger Accounts',
      desc: 'Financial balance statements per worker including current due amounts.',
      icon: FileSpreadsheet,
      color: 'bg-blue-100 dark:bg-blue-950/40 text-blue-600 dark:text-blue-450'
    }
  ];

  const handleDownloadReport = (title: string) => {
    alert(`Generating "${title}" for ${selectedMonth}/${selectedYear}...\nReport compiled and exported successfully.`);
  };

  return (
    <div className="flex flex-col min-h-screen bg-zinc-50 dark:bg-zinc-950 pb-24 text-zinc-900 dark:text-zinc-100">
      {/* Header */}
      <header className="sticky top-0 z-40 bg-white/80 dark:bg-zinc-900/80 backdrop-blur-md border-b border-zinc-200/50 dark:border-zinc-800/50 px-5 py-4 flex items-center justify-between">
        <div className="flex items-center gap-2">
          <button
            onClick={() => navigate('/')}
            className="text-sm font-semibold text-zinc-500 hover:text-zinc-700 dark:hover:text-zinc-300"
          >
            ← Back
          </button>
          <h1 className="text-lg font-black text-zinc-900 dark:text-white m-0">
            {t('reports')}
          </h1>
        </div>
      </header>

      {/* Selector */}
      <main className="p-5 flex-1 max-w-lg mx-auto w-full flex flex-col gap-4">
        
        {/* Date Selector */}
        <div className="bg-white dark:bg-zinc-900 border border-zinc-150 dark:border-zinc-800 rounded-3xl p-5 shadow-sm text-left">
          <label className="text-xs font-bold text-zinc-500 uppercase block mb-2">Select Report Period</label>
          <div className="flex gap-2.5">
            <select
              value={selectedMonth}
              onChange={e => setSelectedMonth(Number(e.target.value))}
              className="flex-1 bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-800 rounded-xl px-4 py-2.5 text-xs font-bold text-zinc-700 dark:text-zinc-300 focus:outline-none"
            >
              {[1,2,3,4,5,6,7,8,9,10,11,12].map(m => (
                <option key={m} value={m}>{new Date(2020, m-1).toLocaleString('default', { month: 'long' })}</option>
              ))}
            </select>
            <select
              value={selectedYear}
              onChange={e => setSelectedYear(Number(e.target.value))}
              className="flex-1 bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-800 rounded-xl px-4 py-2.5 text-xs font-bold text-zinc-700 dark:text-zinc-300 focus:outline-none"
            >
              {[2025, 2026, 2027].map(y => (
                <option key={y} value={y}>{y}</option>
              ))}
            </select>
          </div>
        </div>

        {/* Reports list */}
        <div className="flex flex-col gap-3">
          {reportsList.map(rep => {
            const Icon = rep.icon;
            return (
              <div
                key={rep.id}
                className="bg-white dark:bg-zinc-900 border border-zinc-150 dark:border-zinc-800 p-5 rounded-3xl flex items-center justify-between shadow-sm text-left"
              >
                <div className="flex items-center gap-4 min-w-0">
                  <div className={`w-12 h-12 rounded-2xl flex items-center justify-center flex-shrink-0 ${rep.color}`}>
                    <Icon size={22} />
                  </div>
                  <div className="min-w-0">
                    <h3 className="text-sm font-bold text-zinc-900 dark:text-white truncate">
                      {rep.title}
                    </h3>
                    <p className="text-[10px] text-zinc-400 mt-1 leading-normal">
                      {rep.desc}
                    </p>
                  </div>
                </div>

                <div className="flex gap-1 flex-shrink-0">
                  <button
                    onClick={() => handleDownloadReport(rep.title)}
                    className="p-2.5 text-zinc-500 hover:text-zinc-800 dark:hover:text-zinc-200 hover:bg-zinc-100 dark:hover:bg-zinc-800 rounded-xl transition-colors"
                    title="Export File"
                  >
                    <Download size={18} />
                  </button>
                  <button
                    onClick={() => {
                      const text = `Report "${rep.title}" is ready for review.`;
                      window.open(`https://wa.me/?text=${encodeURIComponent(text)}`);
                    }}
                    className="p-2.5 text-zinc-550 hover:text-green-600 hover:bg-zinc-100 dark:hover:bg-zinc-800 rounded-xl transition-colors"
                    title="Share Report"
                  >
                    <Share2 size={18} />
                  </button>
                </div>
              </div>
            );
          })}
        </div>

      </main>
    </div>
  );
};
