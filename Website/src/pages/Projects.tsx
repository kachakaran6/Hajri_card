import React, { useState } from 'react';
import { useProjects, useAddProject } from '../hooks/useSupabase';
import { useTranslation } from '../context/LanguageContext';
import { Briefcase, MapPin, Calendar, Plus, Folder, User } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { BottomSheet } from '../components/BottomSheet';

export const Projects: React.FC = () => {
  const { t } = useTranslation();
  const navigate = useNavigate();

  const { data: projects, isLoading } = useProjects();
  const addProjectMutation = useAddProject();

  const [isOpen, setIsOpen] = useState(false);
  const [name, setName] = useState('');
  const [location, setLocation] = useState('');
  const [startDate, setStartDate] = useState('');
  const [endDate, setEndDate] = useState('');
  const [notes, setNotes] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!name) return;

    await addProjectMutation.mutateAsync({
      name,
      location: location || undefined,
      start_date: startDate || undefined,
      end_date: endDate || undefined,
      status: 'Active',
      notes: notes || undefined
    });

    setIsOpen(false);
    setName('');
    setLocation('');
    setStartDate('');
    setEndDate('');
    setNotes('');
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
            {t('projects')}
          </h1>
        </div>
        <button
          onClick={() => setIsOpen(true)}
          className="w-9 h-9 rounded-xl bg-violet-600 hover:bg-violet-500 text-white flex items-center justify-center shadow-md shadow-violet-500/20"
        >
          <Plus size={18} />
        </button>
      </header>

      {/* Main Container */}
      <main className="p-5 flex-1 max-w-lg mx-auto w-full flex flex-col gap-4">
        
        {isLoading ? (
          <div className="py-20 flex flex-col items-center justify-center gap-3">
            <div className="w-8 h-8 rounded-full border-2 border-violet-500 border-t-transparent animate-spin" />
            <span className="text-xs text-zinc-500 font-bold">Loading Projects...</span>
          </div>
        ) : projects?.length === 0 ? (
          <div className="py-20 text-center bg-white dark:bg-zinc-900 rounded-3xl border border-zinc-150 dark:border-zinc-800 p-8 shadow-sm">
            <Folder size={48} className="mx-auto text-zinc-300 mb-4" />
            <p className="text-sm text-zinc-550 leading-normal">{t('noProjects')}</p>
          </div>
        ) : (
          <div className="flex flex-col gap-3">
            {projects?.map(proj => (
              <div
                key={proj.id}
                className="bg-white dark:bg-zinc-900 border border-zinc-150 dark:border-zinc-800 p-5 rounded-3xl text-left shadow-sm flex flex-col gap-3"
              >
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-3 min-w-0">
                    <div className="w-10 h-10 rounded-xl bg-violet-100 dark:bg-violet-950/40 text-violet-600 dark:text-violet-400 flex items-center justify-center flex-shrink-0 font-bold">
                      {proj.name.charAt(0)}
                    </div>
                    <div className="min-w-0">
                      <h3 className="text-sm font-extrabold text-zinc-900 dark:text-white truncate">
                        {proj.name}
                      </h3>
                      {proj.location && (
                        <p className="text-[10px] text-zinc-450 mt-1 flex items-center gap-1">
                          <MapPin size={10} />
                          {proj.location}
                        </p>
                      )}
                    </div>
                  </div>

                  <span className="px-2.5 py-0.5 rounded-full text-[10px] font-bold bg-green-100 dark:bg-green-950/30 text-green-700">
                    {proj.status}
                  </span>
                </div>

                {(proj.start_date || proj.end_date) && (
                  <div className="flex items-center gap-1.5 text-[10px] text-zinc-500 font-bold">
                    <Calendar size={12} />
                    <span>Duration: {proj.start_date || 'N/A'} to {proj.end_date || 'Present'}</span>
                  </div>
                )}

                {proj.notes && (
                  <p className="text-[11px] text-zinc-500 italic mt-1 pl-1">
                    "{proj.notes}"
                  </p>
                )}
              </div>
            ))}
          </div>
        )}

      </main>

      {/* Add Project Bottom Sheet */}
      <BottomSheet isOpen={isOpen} onClose={() => setIsOpen(false)} title={t('addProject')}>
        <form onSubmit={handleSubmit} className="flex flex-col gap-4">
          <div>
            <label className="block text-xs font-bold text-zinc-500 dark:text-zinc-400 uppercase mb-1.5">{t('projectName')} *</label>
            <input
              type="text"
              required
              placeholder="e.g. Solanki Heights Site"
              value={name}
              onChange={e => setName(e.target.value)}
              className="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-800 rounded-xl px-4 py-2.5 text-sm text-zinc-900 dark:text-white"
            />
          </div>

          <div>
            <label className="block text-xs font-bold text-zinc-500 dark:text-zinc-400 uppercase mb-1.5">{t('location')}</label>
            <input
              type="text"
              placeholder="e.g. Sector 12, Gandhinagar"
              value={location}
              onChange={e => setLocation(e.target.value)}
              className="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-800 rounded-xl px-4 py-2.5 text-sm text-zinc-900 dark:text-white"
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-bold text-zinc-550 dark:text-zinc-450 uppercase mb-1.5">{t('startDate')}</label>
              <input
                type="date"
                value={startDate}
                onChange={e => setStartDate(e.target.value)}
                className="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-800 rounded-xl px-4 py-2.5 text-xs font-bold text-zinc-900 dark:text-white"
              />
            </div>
            <div>
              <label className="block text-xs font-bold text-zinc-550 dark:text-zinc-450 uppercase mb-1.5">{t('endDate')}</label>
              <input
                type="date"
                value={endDate}
                onChange={e => setEndDate(e.target.value)}
                className="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-800 rounded-xl px-4 py-2.5 text-xs font-bold text-zinc-900 dark:text-white"
              />
            </div>
          </div>

          <div>
            <label className="block text-xs font-bold text-zinc-500 dark:text-zinc-450 uppercase mb-1.5">{t('notes')}</label>
            <input
              type="text"
              placeholder="Site specific specifications"
              value={notes}
              onChange={e => setNotes(e.target.value)}
              className="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-800 rounded-xl px-4 py-2.5 text-sm text-zinc-900 dark:text-white"
            />
          </div>

          <button
            type="submit"
            className="w-full py-3 bg-violet-600 hover:bg-violet-500 text-white font-bold rounded-xl shadow-md transition-colors mt-2"
          >
            {t('save')}
          </button>
        </form>
      </BottomSheet>
    </div>
  );
};
