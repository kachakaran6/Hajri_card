import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import {
  useWorkers,
  useWorkerAttendance,
  useTransactions,
  useMarkAttendance,
  useMonthlySummaries,
  useAddTransaction,
  useProjects
} from '../hooks/useSupabase';
import { useTranslation } from '../context/LanguageContext';
import { BottomSheet } from '../components/BottomSheet';
import {
  Phone,
  MapPin,
  Calendar,
  Wallet,
  FileText,
  Share2,
  Printer,
  QrCode,
  CheckCircle,
  Plus,
  Coins,
  Settings,
  X,
  PlusCircle,
  AlertCircle
} from 'lucide-react';
import qrcode from 'qrcode';

export const WorkerProfile: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { t } = useTranslation();
  
  const { data: workers } = useWorkers();
  const worker = workers?.find(w => w.id === id);
  const { data: attendance } = useWorkerAttendance(id || '');
  const { data: transactions } = useTransactions(id || '');
  const { data: summaries } = useMonthlySummaries(id || '');
  const { data: projects } = useProjects();
  
  const markAttendanceMutation = useMarkAttendance();
  const addTransactionMutation = useAddTransaction();

  // Active Tab
  const [activeTab, setActiveTab] = useState<'overview' | 'attendance' | 'payments' | 'reports'>('overview');
  
  // QR Code state
  const [qrCodeUrl, setQrCodeUrl] = useState('');
  const [isQrOpen, setIsQrOpen] = useState(false);

  // Month / Year state for Hajri Card
  const [selectedMonth, setSelectedMonth] = useState(new Date().getMonth() + 1); // 1-12
  const [selectedYear, setSelectedYear] = useState(new Date().getFullYear());

  // Edit Day state
  const [editingDay, setEditingDay] = useState<number | null>(null);
  const [dayStatus, setDayStatus] = useState<'Present' | 'Absent' | 'Half Day' | 'Leave' | 'Holiday' | 'Overtime'>('Present');
  const [dayOtHours, setDayOtHours] = useState('0');
  const [dayRemarks, setDayRemarks] = useState('');
  
  // Transaction State
  const [isTxOpen, setIsTxOpen] = useState(false);
  const [txType, setTxType] = useState<'Salary' | 'Advance' | 'Bonus' | 'Deduction'>('Salary');
  const [txAmount, setTxAmount] = useState('');
  const [txMethod, setTxMethod] = useState<'Cash' | 'UPI' | 'Bank' | 'Cheque'>('Cash');
  const [txRemarks, setTxRemarks] = useState('');

  // Generate QR Code
  useEffect(() => {
    if (id) {
      qrcode.toDataURL(id, { width: 250, margin: 2 }, (err, url) => {
        if (!err) setQrCodeUrl(url);
      });
    }
  }, [id]);

  if (!worker) {
    return (
      <div className="flex flex-col items-center justify-center min-h-screen p-5 text-center">
        <AlertCircle size={48} className="text-zinc-400 mb-4" />
        <h3 className="text-lg font-bold">Worker not found</h3>
        <button
          onClick={() => navigate('/workers')}
          className="mt-4 px-4 py-2 bg-violet-600 text-white rounded-xl"
        >
          Back to Workers
        </button>
      </div>
    );
  }

  const defaultProjectName = projects?.find(p => p.id === worker.default_project)?.name || 'None';

  // Get attendance status for a specific day of the selected month/year
  const getDayAttendance = (day: number) => {
    const dateStr = `${selectedYear}-${String(selectedMonth).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
    return attendance?.find(a => a.date === dateStr);
  };

  const handleDayClick = (day: number) => {
    const existing = getDayAttendance(day);
    setEditingDay(day);
    setDayStatus(existing?.status || 'Present');
    setDayOtHours(existing?.overtime_hours?.toString() || '0');
    setDayRemarks(existing?.remarks || '');
  };

  const handleSaveDay = async (e: React.FormEvent) => {
    e.preventDefault();
    if (editingDay === null) return;

    const dateStr = `${selectedYear}-${String(selectedMonth).padStart(2, '0')}-${String(editingDay).padStart(2, '0')}`;
    const workHours = dayStatus === 'Present' || dayStatus === 'Overtime' ? 8 : dayStatus === 'Half Day' ? 4 : 0;

    await markAttendanceMutation.mutateAsync({
      worker_id: worker.id,
      date: dateStr,
      status: dayStatus,
      working_hours: workHours,
      overtime_hours: Number(dayOtHours),
      remarks: dayRemarks || undefined,
      project_id: worker.default_project || undefined
    });

    setEditingDay(null);
  };

  const handleTxSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!txAmount) return;

    await addTransactionMutation.mutateAsync({
      worker_id: worker.id,
      transaction_type: txType,
      amount: Number(txAmount),
      payment_method: txMethod,
      transaction_date: new Date().toISOString().split('T')[0],
      remarks: txRemarks || undefined,
      project_id: worker.default_project || undefined
    });

    setIsTxOpen(false);
    setTxAmount('');
    setTxRemarks('');
  };

  // Get total summary metrics for selected month
  const activeSummary = summaries?.find(s => s.month === selectedMonth && s.year === selectedYear);

  const totalDaysInMonth = new Date(selectedYear, selectedMonth, 0).getDate();
  const daysArray = Array.from({ length: totalDaysInMonth }, (_, i) => i + 1);

  // Month list helper
  const months = [
    { val: 1, label: 'January' },
    { val: 2, label: 'February' },
    { val: 3, label: 'March' },
    { val: 4, label: 'April' },
    { val: 5, label: 'May' },
    { val: 6, label: 'June' },
    { val: 7, label: 'July' },
    { val: 8, label: 'August' },
    { val: 9, label: 'September' },
    { val: 10, label: 'October' },
    { val: 11, label: 'November' },
    { val: 12, label: 'December' }
  ];

  return (
    <div className="flex flex-col min-h-screen bg-zinc-50 dark:bg-zinc-950 pb-24 text-zinc-900 dark:text-zinc-100">
      {/* Header */}
      <header className="sticky top-0 z-40 bg-white/80 dark:bg-zinc-900/80 backdrop-blur-md border-b border-zinc-200/50 dark:border-zinc-800/50 px-5 py-4 flex items-center justify-between">
        <div className="flex items-center gap-2">
          <button
            onClick={() => navigate('/workers')}
            className="text-sm font-semibold text-zinc-500 hover:text-zinc-700 dark:hover:text-zinc-300"
          >
            ← Workers
          </button>
        </div>
        <div className="flex items-center gap-2">
          <button
            onClick={() => setIsQrOpen(true)}
            className="p-2 text-zinc-500 dark:text-zinc-400 hover:bg-zinc-100 dark:hover:bg-zinc-850 rounded-xl transition-all"
            title="Worker QR"
          >
            <QrCode size={18} />
          </button>
          <button
            onClick={() => setIsTxOpen(true)}
            className="px-3.5 py-1.5 bg-violet-600 hover:bg-violet-500 text-white rounded-xl font-bold text-xs shadow-sm flex items-center gap-1"
          >
            <Plus size={14} />
            <span>Payment</span>
          </button>
        </div>
      </header>

      {/* Profile Overview Bar */}
      <div className="bg-white dark:bg-zinc-900 border-b border-zinc-150 dark:border-zinc-800 p-5 text-left">
        <div className="max-w-lg mx-auto w-full flex items-center gap-4">
          <div className="w-16 h-16 rounded-3xl bg-violet-100 dark:bg-violet-950/40 text-violet-600 dark:text-violet-400 flex items-center justify-center font-black text-2xl shadow-sm">
            {worker.full_name.charAt(0)}
          </div>
          <div>
            <div className="flex items-center gap-2">
              <h2 className="text-xl font-black text-zinc-900 dark:text-white m-0">
                {worker.full_name}
              </h2>
              {worker.worker_code && (
                <span className="text-[10px] font-bold bg-zinc-100 dark:bg-zinc-800 text-zinc-500 px-2 py-0.5 rounded">
                  #{worker.worker_code}
                </span>
              )}
            </div>
            <p className="text-sm text-zinc-500 font-bold m-0 mt-0.5">
              ₹{worker.daily_wage} / day ({defaultProjectName})
            </p>
          </div>
        </div>

        {/* Tab Selection */}
        <div className="max-w-lg mx-auto w-full flex gap-1 bg-zinc-100 dark:bg-zinc-800/80 p-1 rounded-xl mt-6">
          {(['overview', 'attendance', 'payments', 'reports'] as const).map(tab => (
            <button
              key={tab}
              onClick={() => setActiveTab(tab)}
              className={`flex-1 py-2 text-xs font-bold rounded-lg capitalize transition-all ${
                activeTab === tab
                  ? 'bg-white dark:bg-zinc-700 text-zinc-900 dark:text-white shadow-sm'
                  : 'text-zinc-500 dark:text-zinc-400 hover:text-zinc-700 dark:hover:text-zinc-200'
              }`}
            >
              {t(tab as any)}
            </button>
          ))}
        </div>
      </div>

      {/* Main Content Area */}
      <main className="p-5 flex-1 max-w-lg mx-auto w-full">
        {/* TAB 1: OVERVIEW */}
        {activeTab === 'overview' && (
          <div className="flex flex-col gap-5 text-left">
            {/* Wages & Outstanding Dues Summary */}
            <div className="bg-gradient-to-br from-violet-600 to-indigo-700 text-white rounded-3xl p-6 shadow-md">
              <span className="text-xs text-white/70 uppercase font-black tracking-wider">
                {t('currentDue')}
              </span>
              <h3 className="text-3xl font-black mt-1">
                ₹{activeSummary?.balance || 0}
              </h3>
              
              <div className="grid grid-cols-2 gap-4 mt-6 pt-4 border-t border-white/10 text-xs">
                <div>
                  <span className="text-white/60 font-semibold uppercase tracking-wider block">Wages Earned</span>
                  <span className="text-lg font-black mt-1 block">₹{activeSummary?.gross_amount || 0}</span>
                </div>
                <div>
                  <span className="text-white/60 font-semibold uppercase tracking-wider block">Advances / Paid</span>
                  <span className="text-lg font-black mt-1 block">₹{((activeSummary?.advance || 0) + (activeSummary?.paid || 0))}</span>
                </div>
              </div>
            </div>

            {/* Info Cards */}
            <div className="bg-white dark:bg-zinc-900 border border-zinc-150 dark:border-zinc-800 rounded-3xl p-5 shadow-sm flex flex-col gap-4">
              <h3 className="text-sm font-bold text-zinc-400 uppercase tracking-wider mb-2">
                {t('personalInfo')}
              </h3>

              {worker.father_name && (
                <div>
                  <span className="text-xs text-zinc-500 font-bold block">{t('fatherName')}</span>
                  <span className="text-sm font-semibold text-zinc-850 dark:text-zinc-150 mt-1 block">{worker.father_name}</span>
                </div>
              )}

              {worker.phone && (
                <div>
                  <span className="text-xs text-zinc-500 font-bold block">{t('phone')}</span>
                  <a href={`tel:${worker.phone}`} className="text-sm font-bold text-violet-600 dark:text-violet-400 flex items-center gap-1.5 mt-1.5">
                    <Phone size={14} />
                    {worker.phone}
                  </a>
                </div>
              )}

              {(worker.village || worker.city || worker.state) && (
                <div>
                  <span className="text-xs text-zinc-500 font-bold block">Address / Village</span>
                  <span className="text-sm font-semibold text-zinc-850 dark:text-zinc-150 mt-1.5 flex items-center gap-1">
                    <MapPin size={14} className="text-zinc-400" />
                    {[worker.village, worker.city, worker.state].filter(Boolean).join(', ')}
                  </span>
                </div>
              )}

              <div>
                <span className="text-xs text-zinc-500 font-bold block">{t('joiningDate')}</span>
                <span className="text-sm font-semibold text-zinc-850 dark:text-zinc-150 mt-1 block">{worker.joining_date}</span>
              </div>

              {worker.notes && (
                <div>
                  <span className="text-xs text-zinc-500 font-bold block">{t('notes')}</span>
                  <span className="text-sm font-medium text-zinc-600 dark:text-zinc-450 mt-1 block italic">{worker.notes}</span>
                </div>
              )}
            </div>

            {/* Bank Card */}
            <div className="bg-white dark:bg-zinc-900 border border-zinc-150 dark:border-zinc-800 rounded-3xl p-5 shadow-sm flex flex-col gap-3">
              <h3 className="text-sm font-bold text-zinc-400 uppercase tracking-wider mb-2">
                {t('bankDetails')}
              </h3>

              {worker.upi_id && (
                <div className="flex justify-between items-center py-1.5 border-b border-zinc-100 dark:border-zinc-800">
                  <span className="text-xs text-zinc-500 font-bold">UPI ID</span>
                  <span className="text-sm font-mono font-bold text-zinc-900 dark:text-white">{worker.upi_id}</span>
                </div>
              )}

              {worker.bank_name && (
                <div className="flex justify-between items-center py-1.5 border-b border-zinc-100 dark:border-zinc-800">
                  <span className="text-xs text-zinc-500 font-bold">Bank Name</span>
                  <span className="text-sm font-semibold text-zinc-900 dark:text-white">{worker.bank_name}</span>
                </div>
              )}

              {worker.account_number && (
                <div className="flex justify-between items-center py-1.5 border-b border-zinc-100 dark:border-zinc-800">
                  <span className="text-xs text-zinc-500 font-bold">Account Number</span>
                  <span className="text-sm font-mono font-bold text-zinc-900 dark:text-white">{worker.account_number}</span>
                </div>
              )}

              {worker.ifsc && (
                <div className="flex justify-between items-center">
                  <span className="text-xs text-zinc-500 font-bold">IFSC</span>
                  <span className="text-sm font-mono font-bold text-zinc-900 dark:text-white">{worker.ifsc}</span>
                </div>
              )}
              
              {!worker.upi_id && !worker.bank_name && (
                <p className="text-xs text-zinc-400 italic">No bank or UPI details provided.</p>
              )}
            </div>
          </div>
        )}

        {/* TAB 2: ATTENDANCE (DIGITAL HAJRI CARD MODE) */}
        {activeTab === 'attendance' && (
          <div className="flex flex-col gap-5 text-left">
            
            {/* Header selector for Month/Year */}
            <div className="flex gap-2 items-center">
              <select
                value={selectedMonth}
                onChange={e => setSelectedMonth(Number(e.target.value))}
                className="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-xl px-3 py-2 text-xs font-bold text-zinc-700 dark:text-zinc-300 focus:outline-none"
              >
                {months.map(m => (
                  <option key={m.val} value={m.val}>{m.label}</option>
                ))}
              </select>
              <select
                value={selectedYear}
                onChange={e => setSelectedYear(Number(e.target.value))}
                className="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-xl px-3 py-2 text-xs font-bold text-zinc-700 dark:text-zinc-300 focus:outline-none"
              >
                {[2025, 2026, 2027].map(y => (
                  <option key={y} value={y}>{y}</option>
                ))}
              </select>
            </div>

            {/* Helper Alert */}
            <div className="bg-amber-50 dark:bg-amber-950/20 border border-amber-200 dark:border-amber-900 p-4 rounded-2xl flex gap-3 text-amber-800 dark:text-amber-400">
              <AlertCircle size={20} className="flex-shrink-0 mt-0.5" />
              <div className="text-xs">
                <span className="font-extrabold block">{t('digitalHajriCardMode')}</span>
                <span className="block mt-0.5 leading-normal">{t('paperCardHelper')}</span>
              </div>
            </div>

            {/* Digital Yellow Paper Card */}
            <div className="bg-amber-100/90 dark:bg-yellow-950/25 border-2 border-amber-300 dark:border-yellow-900/60 rounded-3xl p-5 text-amber-900 dark:text-amber-350 shadow-md relative">
              {/* Paper line overlay */}
              <div className="absolute top-0 bottom-0 left-8 w-[1px] bg-red-400/20 pointer-events-none" />

              <div className="flex items-center justify-between border-b-2 border-amber-300 dark:border-yellow-900/60 pb-3 mb-4">
                <span className="font-black text-xs uppercase tracking-wider">રોજગાર પત્રક / HAJRI CARD</span>
                <span className="text-[10px] font-bold">Month: {months.find(m => m.val === selectedMonth)?.label}</span>
              </div>

              {/* Grid 1 to 31 */}
              <div className="hajri-grid">
                {daysArray.map(day => {
                  const attRecord = getDayAttendance(day);
                  
                  // Color codes for different status stamps
                  let stampColor = 'text-zinc-400';
                  let stampBg = 'bg-white dark:bg-zinc-900';
                  let statusChar = ' ';
                  
                  if (attRecord?.status === 'Present') {
                    statusChar = 'P';
                    stampColor = 'text-green-600 dark:text-green-400 border-green-300 dark:border-green-800';
                    stampBg = 'bg-green-50 dark:bg-green-950/30';
                  } else if (attRecord?.status === 'Absent') {
                    statusChar = 'A';
                    stampColor = 'text-red-600 dark:text-red-400 border-red-300 dark:border-red-800';
                    stampBg = 'bg-red-50 dark:bg-red-950/30';
                  } else if (attRecord?.status === 'Half Day') {
                    statusChar = 'H';
                    stampColor = 'text-amber-600 dark:text-amber-400 border-amber-300 dark:border-amber-800';
                    stampBg = 'bg-amber-50 dark:bg-amber-950/30';
                  } else if (attRecord?.status === 'Leave') {
                    statusChar = 'L';
                    stampColor = 'text-blue-600 dark:text-blue-400 border-blue-300 dark:border-blue-800';
                    stampBg = 'bg-blue-50 dark:bg-blue-950/30';
                  } else if (attRecord?.status === 'Holiday') {
                    statusChar = 'Hld';
                    stampColor = 'text-purple-600 dark:text-purple-400 border-purple-300 dark:border-purple-800';
                    stampBg = 'bg-purple-50 dark:bg-purple-950/30';
                  } else if (attRecord?.status === 'Overtime') {
                    statusChar = 'OT';
                    stampColor = 'text-violet-600 dark:text-violet-400 border-violet-300 dark:border-violet-850';
                    stampBg = 'bg-violet-50 dark:bg-violet-950/30';
                  }

                  return (
                    <div
                      key={day}
                      onClick={() => handleDayClick(day)}
                      className={`hajri-day-card border ${stampColor} ${stampBg} shadow-sm active:scale-95`}
                    >
                      <span className="text-[9px] text-zinc-400 font-bold block mb-0.5">{day}</span>
                      <span className="text-sm font-black">{statusChar}</span>
                    </div>
                  );
                })}
              </div>

              {/* Monthly stats bottom section of Card */}
              <div className="mt-6 pt-4 border-t-2 border-amber-300 dark:border-yellow-900/60 grid grid-cols-2 gap-4 text-xs font-bold">
                <div className="flex flex-col gap-2">
                  <div className="flex justify-between">
                    <span>Present Days:</span>
                    <span>{activeSummary?.present_days || 0}</span>
                  </div>
                  <div className="flex justify-between">
                    <span>Half Days:</span>
                    <span>{activeSummary?.half_days || 0}</span>
                  </div>
                  <div className="flex justify-between">
                    <span>Overtime Hours:</span>
                    <span>{activeSummary?.overtime_hours || 0} hrs</span>
                  </div>
                </div>
                <div className="flex flex-col gap-2 border-l border-amber-300 dark:border-yellow-900/60 pl-4">
                  <div className="flex justify-between">
                    <span>Total Wages:</span>
                    <span>₹{activeSummary?.gross_amount || 0}</span>
                  </div>
                  <div className="flex justify-between">
                    <span>Advances:</span>
                    <span>₹{activeSummary?.advance || 0}</span>
                  </div>
                  <div className="flex justify-between border-t border-amber-300 dark:border-yellow-900/60 pt-1 text-violet-750">
                    <span>Net Balance:</span>
                    <span>₹{activeSummary?.balance || 0}</span>
                  </div>
                </div>
              </div>

            </div>
          </div>
        )}

        {/* TAB 3: PAYMENTS TIMELINE */}
        {activeTab === 'payments' && (
          <div className="flex flex-col gap-5 text-left">
            <div className="flex justify-between items-center">
              <h3 className="text-sm font-bold text-zinc-400 uppercase tracking-wider">
                {t('paymentTimeline')}
              </h3>
              <button
                onClick={() => setIsTxOpen(true)}
                className="flex items-center gap-1 text-xs font-bold text-violet-600 dark:text-violet-400 hover:text-violet-500"
              >
                <PlusCircle size={14} />
                <span>Add Record</span>
              </button>
            </div>

            {transactions?.length === 0 ? (
              <div className="py-12 text-center bg-white dark:bg-zinc-900 border border-zinc-150 dark:border-zinc-800 rounded-3xl p-6">
                <Wallet size={36} className="mx-auto text-zinc-300 mb-3" />
                <p className="text-xs text-zinc-500">{t('noPayments')}</p>
              </div>
            ) : (
              <div className="relative border-l border-zinc-200 dark:border-zinc-800 ml-4 pl-6 flex flex-col gap-5">
                {transactions?.map(tx => {
                  let badgeColor = 'bg-green-100 dark:bg-green-950/30 text-green-700';
                  let sign = '-';
                  if (tx.transaction_type === 'Advance') {
                    badgeColor = 'bg-amber-100 dark:bg-amber-950/30 text-amber-700';
                    sign = '-';
                  } else if (tx.transaction_type === 'Salary') {
                    badgeColor = 'bg-blue-100 dark:bg-blue-950/30 text-blue-700';
                    sign = '-';
                  } else if (tx.transaction_type === 'Bonus') {
                    badgeColor = 'bg-emerald-100 dark:bg-emerald-950/30 text-emerald-700';
                    sign = '+';
                  } else if (tx.transaction_type === 'Deduction') {
                    badgeColor = 'bg-red-100 dark:bg-red-950/30 text-red-700';
                    sign = '-';
                  }

                  return (
                    <div key={tx.id} className="relative">
                      {/* Timeline dot */}
                      <div className="absolute -left-9 top-1 w-6 h-6 rounded-full bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 flex items-center justify-center text-[10px] font-bold text-zinc-400">
                        •
                      </div>

                      <div className="bg-white dark:bg-zinc-900 border border-zinc-150 dark:border-zinc-800 p-4 rounded-2xl flex items-center justify-between shadow-sm">
                        <div>
                          <div className="flex items-center gap-2">
                            <span className={`px-2 py-0.5 rounded text-[10px] font-extrabold uppercase ${badgeColor}`}>
                              {tx.transaction_type}
                            </span>
                            <span className="text-[10px] text-zinc-400 font-bold">{tx.transaction_date}</span>
                          </div>
                          {tx.remarks && (
                            <p className="text-xs text-zinc-500 mt-2 font-medium italic">"{tx.remarks}"</p>
                          )}
                          <p className="text-[10px] text-zinc-400 mt-1">Paid via: {tx.payment_method}</p>
                        </div>
                        <span className="text-base font-black">
                          {sign}₹{tx.amount}
                        </span>
                      </div>
                    </div>
                  );
                })}
              </div>
            )}
          </div>
        )}

        {/* TAB 4: REPORTS EXPORT */}
        {activeTab === 'reports' && (
          <div className="flex flex-col gap-4 text-left">
            <h3 className="text-sm font-bold text-zinc-400 uppercase tracking-wider mb-2">
              Generate Export Reports
            </h3>

            <div className="bg-white dark:bg-zinc-900 border border-zinc-150 dark:border-zinc-800 p-5 rounded-3xl flex flex-col gap-3 shadow-sm">
              <div className="flex items-center gap-4.5">
                <div className="w-12 h-12 rounded-2xl bg-violet-100 dark:bg-violet-950/40 text-violet-600 dark:text-violet-400 flex items-center justify-center">
                  <FileText size={22} />
                </div>
                <div>
                  <h4 className="text-sm font-bold text-zinc-900 dark:text-white">Monthly Attendance Rojgar Card</h4>
                  <p className="text-[10px] text-zinc-400 leading-normal mt-0.5">Includes full daily grid with wage breakdown, payments, and net remaining dues.</p>
                </div>
              </div>

              <div className="flex gap-2.5 mt-3 pt-3 border-t border-zinc-100 dark:border-zinc-800">
                <button
                  onClick={() => alert('PDF generation is simulated for sandbox. Report is ready for export.')}
                  className="flex-1 py-2 bg-zinc-100 dark:bg-zinc-800 hover:bg-zinc-200 text-zinc-700 dark:text-zinc-300 font-bold rounded-xl text-xs flex items-center justify-center gap-1.5 transition-colors"
                >
                  <Printer size={14} />
                  <span>{t('printCard')}</span>
                </button>
                <button
                  onClick={() => {
                    const text = `Hajri Card Summary for ${worker.full_name}:\nMonth: ${months.find(m => m.val === selectedMonth)?.label}\nPresent Days: ${activeSummary?.present_days || 0}\nGross Wages: ₹${activeSummary?.gross_amount || 0}\nAdvance Given: ₹${activeSummary?.advance || 0}\nPaid: ₹${activeSummary?.paid || 0}\nNet Balance Due: ₹${activeSummary?.balance || 0}`;
                    window.open(`https://wa.me/?text=${encodeURIComponent(text)}`);
                  }}
                  className="flex-1 py-2 bg-green-600 hover:bg-green-500 text-white font-bold rounded-xl text-xs flex items-center justify-center gap-1.5 transition-colors"
                >
                  <Share2 size={14} />
                  <span>WhatsApp</span>
                </button>
              </div>
            </div>
          </div>
        )}
      </main>

      {/* QR Code Dialog Overlay */}
      {isQrOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/80 backdrop-blur-xs p-5">
          <div className="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 p-6 rounded-3xl text-center max-w-sm w-full relative shadow-2xl">
            <button
              onClick={() => setIsQrOpen(false)}
              className="absolute top-4 right-4 p-1.5 text-zinc-400 hover:text-zinc-600 dark:hover:text-zinc-200 rounded-full hover:bg-zinc-100 dark:hover:bg-zinc-800 transition-colors"
            >
              <X size={18} />
            </button>
            <h3 className="text-lg font-black text-zinc-900 dark:text-white mb-2">Worker ID Card QR</h3>
            <p className="text-xs text-zinc-500 mb-5">Print or scan this QR Code to instantly access {worker.full_name}'s digital card.</p>
            
            <div className="w-56 h-56 mx-auto bg-white border border-zinc-250 dark:border-zinc-800 rounded-2xl flex items-center justify-center overflow-hidden p-3 shadow-inner">
              {qrCodeUrl ? (
                <img src={qrCodeUrl} alt="Worker QR Code" className="w-full h-full object-contain" />
              ) : (
                <div className="w-8 h-8 rounded-full border-2 border-violet-500 border-t-transparent animate-spin" />
              )}
            </div>

            <div className="bg-zinc-50 dark:bg-zinc-850 border border-zinc-150 dark:border-zinc-800/60 p-3 rounded-2xl text-left mt-6 flex justify-between items-center text-xs">
              <div>
                <span className="block font-bold text-zinc-900 dark:text-white">{worker.full_name}</span>
                <span className="block text-zinc-400 mt-0.5 text-[10px]">Code: {worker.worker_code || 'N/A'}</span>
              </div>
              <span className="font-extrabold text-violet-600 dark:text-violet-400">₹{worker.daily_wage}/day</span>
            </div>
          </div>
        </div>
      )}

      {/* Edit Day Details Bottom Sheet */}
      <BottomSheet isOpen={editingDay !== null} onClose={() => setEditingDay(null)} title={`Attendance Stamp: Day ${editingDay}`}>
        <form onSubmit={handleSaveDay} className="flex flex-col gap-4">
          <div>
            <label className="block text-xs font-bold text-zinc-550 dark:text-zinc-450 uppercase mb-2">Attendance Status</label>
            <div className="grid grid-cols-3 gap-2">
              {(['Present', 'Absent', 'Half Day', 'Leave', 'Holiday', 'Overtime'] as const).map(status => (
                <button
                  key={status}
                  type="button"
                  onClick={() => {
                    setDayStatus(status);
                    if (status !== 'Overtime') setDayOtHours('0');
                  }}
                  className={`py-2 px-1 text-xs font-bold rounded-lg border transition-all ${
                    dayStatus === status
                      ? 'bg-violet-600 border-violet-600 text-white'
                      : 'bg-zinc-50 dark:bg-zinc-850 border-zinc-200 dark:border-zinc-850 text-zinc-700 dark:text-zinc-300'
                  }`}
                >
                  {status}
                </button>
              ))}
            </div>
          </div>

          {dayStatus === 'Overtime' && (
            <div>
              <label className="block text-xs font-bold text-zinc-550 dark:text-zinc-450 uppercase mb-1.5">Overtime Hours</label>
              <input
                type="number"
                step="0.5"
                required
                value={dayOtHours}
                onChange={e => setDayOtHours(e.target.value)}
                className="w-full bg-zinc-50 dark:bg-zinc-855 border border-zinc-200 dark:border-zinc-800 rounded-xl px-4 py-2.5 text-sm"
              />
            </div>
          )}

          <div>
            <label className="block text-xs font-bold text-zinc-550 dark:text-zinc-450 uppercase mb-1.5">Remarks / Work details</label>
            <input
              type="text"
              placeholder="e.g. Tile layout work done"
              value={dayRemarks}
              onChange={e => setDayRemarks(e.target.value)}
              className="w-full bg-zinc-50 dark:bg-zinc-855 border border-zinc-200 dark:border-zinc-800 rounded-xl px-4 py-2.5 text-sm focus:ring-2 focus:ring-violet-500 focus:outline-none"
            />
          </div>

          <button
            type="submit"
            className="w-full py-3 bg-violet-600 hover:bg-violet-500 text-white font-bold rounded-xl shadow-md transition-colors mt-2"
          >
            Update stamp
          </button>
        </form>
      </BottomSheet>

      {/* Record Transaction Bottom Sheet */}
      <BottomSheet isOpen={isTxOpen} onClose={() => setIsTxOpen(false)} title="Record Wage Transaction">
        <form onSubmit={handleTxSubmit} className="flex flex-col gap-4">
          <div>
            <label className="block text-xs font-bold text-zinc-550 dark:text-zinc-450 uppercase mb-1.5">Transaction Type</label>
            <div className="grid grid-cols-4 gap-2">
              {(['Salary', 'Advance', 'Bonus', 'Deduction'] as const).map(type => (
                <button
                  key={type}
                  type="button"
                  onClick={() => setTxType(type)}
                  className={`py-2 px-1 text-xs font-bold rounded-lg border transition-all ${
                    txType === type
                      ? 'bg-violet-600 border-violet-600 text-white'
                      : 'bg-zinc-50 dark:bg-zinc-850 border-zinc-200 dark:border-zinc-850 text-zinc-700 dark:text-zinc-300'
                  }`}
                >
                  {type}
                </button>
              ))}
            </div>
          </div>

          <div>
            <label className="block text-xs font-bold text-zinc-550 dark:text-zinc-450 uppercase mb-1.5">Amount (₹) *</label>
            <input
              type="number"
              required
              value={txAmount}
              onChange={e => setTxAmount(e.target.value)}
              className="w-full bg-zinc-50 dark:bg-zinc-850 border border-zinc-200 dark:border-zinc-800 rounded-xl px-4 py-2.5 text-sm"
            />
          </div>

          <div>
            <label className="block text-xs font-bold text-zinc-550 dark:text-zinc-450 uppercase mb-1.5">Payment Method</label>
            <div className="grid grid-cols-4 gap-2">
              {(['Cash', 'UPI', 'Bank', 'Cheque'] as const).map(method => (
                <button
                  key={method}
                  type="button"
                  onClick={() => setTxMethod(method)}
                  className={`py-2 px-1 text-xs font-bold rounded-lg border transition-all ${
                    txMethod === method
                      ? 'bg-violet-600 border-violet-600 text-white'
                      : 'bg-zinc-50 dark:bg-zinc-850 border-zinc-200 dark:border-zinc-850 text-zinc-700 dark:text-zinc-300'
                  }`}
                >
                  {method}
                </button>
              ))}
            </div>
          </div>

          <div>
            <label className="block text-xs font-bold text-zinc-550 dark:text-zinc-450 uppercase mb-1.5">Remarks / Description</label>
            <input
              type="text"
              placeholder="Description"
              value={txRemarks}
              onChange={e => setTxRemarks(e.target.value)}
              className="w-full bg-zinc-50 dark:bg-zinc-850 border border-zinc-200 dark:border-zinc-800 rounded-xl px-4 py-2.5 text-sm"
            />
          </div>

          <button
            type="submit"
            className="w-full py-3 bg-violet-600 hover:bg-violet-500 text-white font-bold rounded-xl shadow-md transition-colors mt-2"
          >
            Add Record
          </button>
        </form>
      </BottomSheet>
    </div>
  );
};
