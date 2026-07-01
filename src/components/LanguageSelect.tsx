import React from 'react';
import { useTranslation } from '../context/LanguageContext';
import { Language } from '../utils/translations';

export const LanguageSelect: React.FC = () => {
  const { language, setLanguage } = useTranslation();

  const options: { value: Language; label: string }[] = [
    { value: 'en', label: 'EN' },
    { value: 'hi', label: 'HI' },
    { value: 'gu', label: 'GU' }
  ];

  return (
    <div className="flex items-center gap-1.5 p-1 bg-zinc-100 dark:bg-zinc-800/80 rounded-xl w-fit">
      {options.map(opt => (
        <button
          key={opt.value}
          onClick={() => setLanguage(opt.value)}
          className={`px-3 py-1.5 text-xs font-bold rounded-lg transition-all duration-200 ${
            language === opt.value
              ? 'bg-white dark:bg-zinc-700 text-zinc-900 dark:text-zinc-100 shadow-sm border border-zinc-200/50 dark:border-zinc-600/30'
              : 'text-zinc-500 dark:text-zinc-400 hover:text-zinc-700 dark:hover:text-zinc-200'
          }`}
        >
          {opt.label}
        </button>
      ))}
    </div>
  );
};
