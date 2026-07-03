import React, { useState } from 'react';
import { useWorkers, useAttendance, useMarkAttendance, useProjects } from '../hooks/useSupabase';
import { useTranslation } from '../context/LanguageContext';
import { Check, X, Calendar, User, Search, UserCheck } from 'lucide-react';
import { useNavigate } from 'react-router-dom';

export const Attendance: React.FC = () => {
  const { t } = useTranslation();
  const navigate = useNavigate();

  const [date, setDate] = useState(new Date().toISOString().split('T')[0]);
  const [search, setSearch] = useState('');
  const [selectedProjectId, setSelectedProjectId] = useState<string>('');

  const { data: workers, isLoading: isLoadingWorkers } = useWorkers();
  const { data: attendanceList, isLoading: isLoadingAttendance } = useAttendance(date);
  const { data: projects } = useProjects();
  const markAttendanceMutation = useMarkAttendance();

  const handleMark = async (workerId: string, status: 'Present' | 'Absent' | 'Half Day' | 'Overtime') => {
    const worker = workers?.find(w => w.id === workerId);
    const workingHours = status === 'Present' || status === 'Overtime' ? 8 : status === 'Half Day' ? 4 : 0;
    const defaultOt = status === 'Overtime' ? 2 : 0;

    await markAttendanceMutation.mutateAsync({
      worker_id: workerId,
      date,
      status,
      working_hours: workingHours,
      overtime_hours: defaultOt,
      project_id: selectedProjectId || worker?.default_project || undefined
    });
  };

  // Filter workers by search and project
  const filteredWorkers = workers?.filter(w => {
    const matchesSearch = w.full_name.toLowerCase().includes(search.toLowerCase()) || 
                          (w.worker_code && w.worker_code.toLowerCase().includes(search.toLowerCase()));
    
    const matchesProject = !selectedProjectId || w.default_project === selectedProjectId;
    
    return matchesSearch && matchesProject;
  });

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
            {t('takeAttendance')}
          </h1>
        </div>
      </header>

      {/* Settings Bar */}
      <main className="p-5 flex-1 max-w-lg mx-auto w-full flex flex-col gap-4">
        
        {/* Date Selector and Project Selector */}
        <div className="bg-white dark:bg-zinc-900 border border-zinc-150 dark:border-zinc-800 rounded-3xl p-5 shadow-sm flex flex-col gap-4">
          <div className="flex flex-col text-left">
            <label className="text-xs font-bold text-zinc-450 uppercase mb-1.5 flex items-center gap-1">
              <Calendar size={14} />
              <span>Select Attendance Date</span>
            </label>
            <input
              type="date"
              value={date}
              onChange={e => setDate(e.target.value)}
              className="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-800 rounded-xl px-4 py-2.5 text-sm font-bold text-zinc-800 dark:text-white focus:outline-none"
            />
          </div>

          <div className="flex flex-col text-left">
            <label className="text-xs font-bold text-zinc-400 uppercase mb-1.5">Project Filter</label>
            <select
              value={selectedProjectId}
              onChange={e => setSelectedProjectId(e.target.value)}
              className="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-800 rounded-xl px-4 py-2.5 text-sm font-semibold text-zinc-800 dark:text-white focus:outline-none"
            >
              <option value="">All Active Projects</option>
              {projects?.map(p => (
                <option key={p.id} value={p.id}>{p.name}</option>
              ))}
            </select>
          </div>
        </div>

        {/* Search */}
        <div className="relative">
          <Search className="absolute left-4 top-3.5 text-zinc-400" size={18} />
          <input
            type="text"
            placeholder="Search workers..."
            value={search}
            onChange={e => setSearch(e.target.value)}
            className="w-full bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-2xl pl-11 pr-5 py-3 text-sm focus:outline-none shadow-sm"
          />
        </div>

        {/* List Content */}
        {isLoadingWorkers || isLoadingAttendance ? (
          <div className="py-20 flex flex-col items-center justify-center gap-3">
            <div className="w-8 h-8 rounded-full border-2 border-violet-500 border-t-transparent animate-spin" />
            <span className="text-xs text-zinc-500">Loading Attendance List...</span>
          </div>
        ) : filteredWorkers?.length === 0 ? (
          <div className="py-20 text-center bg-white dark:bg-zinc-900 rounded-3xl border border-zinc-150 dark:border-zinc-800 p-8 shadow-sm">
            <User size={48} className="mx-auto text-zinc-300 mb-4" />
            <p className="text-sm text-zinc-500 leading-normal">No workers found to mark attendance.</p>
          </div>
        ) : (
          <div className="flex flex-col gap-2.5">
            {filteredWorkers?.map(worker => {
              const currentAtt = attendanceList?.find(a => a.worker_id === worker.id);
              const status = currentAtt?.status;

              return (
                <div
                  key={worker.id}
                  className="bg-white dark:bg-zinc-900 border border-zinc-150 dark:border-zinc-800 p-4 rounded-2xl flex items-center justify-between shadow-sm text-left"
                >
                  <div className="flex flex-col min-w-0">
                    <span className="text-sm font-extrabold text-zinc-900 dark:text-white truncate">
                      {worker.full_name}
                    </span>
                    <span className="text-[10px] text-zinc-400 font-bold mt-0.5">
                      Rate: ₹{worker.daily_wage}/day
                    </span>
                  </div>

                  {/* Marking Pills */}
                  <div className="flex gap-1.5 flex-shrink-0">
                    <button
                      onClick={() => handleMark(worker.id, 'Present')}
                      className={`px-3 py-1.5 text-xs font-bold rounded-lg transition-all ${
                        status === 'Present'
                          ? 'bg-green-600 text-white shadow-sm border border-green-600'
                          : 'bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-800 text-zinc-500 dark:text-zinc-400'
                      }`}
                    >
                      P
                    </button>
                    <button
                      onClick={() => handleMark(worker.id, 'Half Day')}
                      className={`px-3 py-1.5 text-xs font-bold rounded-lg transition-all ${
                        status === 'Half Day'
                          ? 'bg-amber-500 text-white shadow-sm border border-amber-500'
                          : 'bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-800 text-zinc-500 dark:text-zinc-400'
                      }`}
                    >
                      H
                    </button>
                    <button
                      onClick={() => handleMark(worker.id, 'Absent')}
                      className={`px-3 py-1.5 text-xs font-bold rounded-lg transition-all ${
                        status === 'Absent'
                          ? 'bg-red-600 text-white shadow-sm border border-red-600'
                          : 'bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-800 text-zinc-500 dark:text-zinc-400'
                      }`}
                    >
                      A
                    </button>
                    <button
                      onClick={() => handleMark(worker.id, 'Overtime')}
                      className={`px-2 py-1.5 text-[10px] font-extrabold rounded-lg transition-all ${
                        status === 'Overtime'
                          ? 'bg-violet-600 text-white shadow-sm border border-violet-600'
                          : 'bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-800 text-zinc-500 dark:text-zinc-400'
                      }`}
                    >
                      OT
                    </button>
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </main>
    </div>
  );
};
