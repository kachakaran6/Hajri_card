import React, { useState, useEffect, useRef } from 'react';
import {
  useWorkers,
  useAddWorker,
  useUpdateWorker,
  useDeleteWorker,
  useMarkAttendance,
  useAddTransaction,
  useProjects
} from '../hooks/useSupabase';
import { useTranslation } from '../context/LanguageContext';
import { Swipeable } from '../components/Swipeable';
import { BottomSheet } from '../components/BottomSheet';
import {
  Search,
  Plus,
  Phone,
  MapPin,
  Check,
  X,
  CreditCard,
  Edit2,
  Trash2,
  User,
  MoreHorizontal,
  ChevronRight,
  Wallet,
  CalendarDays,
  UserCheck
} from 'lucide-react';
import { useNavigate, useLocation } from 'react-router-dom';

export const Workers: React.FC = () => {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const location = useLocation();
  
  const { data: workers, isLoading } = useWorkers();
  const { data: projects } = useProjects();
  const addWorkerMutation = useAddWorker();
  const updateWorkerMutation = useUpdateWorker();
  const deleteWorkerMutation = useDeleteWorker();
  const markAttendanceMutation = useMarkAttendance();
  const addTransactionMutation = useAddTransaction();

  // Search & Filters
  const [search, setSearch] = useState('');
  
  // State for Bottom Sheets
  const [isAddOpen, setIsAddOpen] = useState(false);
  const [isEditOpen, setIsEditOpen] = useState(false);
  const [isPaymentOpen, setIsPaymentOpen] = useState(false);
  
  // Selected Worker references for forms
  const [selectedWorker, setSelectedWorker] = useState<any>(null);

  // Multi-select state
  const [isMultiSelectMode, setIsMultiSelectMode] = useState(false);
  const [selectedWorkerIds, setSelectedWorkerIds] = useState<string[]>([]);
  const longPressTimer = useRef<any>(null);

  // Quick Action Form Fields
  const [paymentType, setPaymentType] = useState<'Salary' | 'Advance'>('Salary');
  const [paymentAmount, setPaymentAmount] = useState('');
  const [paymentMethod, setPaymentMethod] = useState<'Cash' | 'UPI' | 'Bank' | 'Cheque'>('Cash');
  const [paymentRemarks, setPaymentRemarks] = useState('');

  // Add/Edit Worker Form Fields
  const [formData, setFormData] = useState({
    full_name: '',
    worker_code: '',
    phone: '',
    father_name: '',
    village: '',
    daily_wage: '',
    overtime_rate: '',
    default_project: '',
    upi_id: '',
    bank_name: '',
    account_number: '',
    ifsc: ''
  });

  // Open add sheet if URL contains ?add=true
  useEffect(() => {
    const searchParams = new URLSearchParams(location.search);
    if (searchParams.get('add') === 'true') {
      setIsAddOpen(true);
    }
  }, [location.search]);

  // Long press handler triggers selection mode
  const handleTouchStart = (workerId: string) => {
    longPressTimer.current = setTimeout(() => {
      setIsMultiSelectMode(true);
      toggleSelectWorker(workerId);
    }, 600); // 600ms hold
  };

  const handleTouchEnd = () => {
    if (longPressTimer.current) {
      clearTimeout(longPressTimer.current);
    }
  };

  const toggleSelectWorker = (workerId: string) => {
    setSelectedWorkerIds(prev =>
      prev.includes(workerId)
        ? prev.filter(id => id !== workerId)
        : [...prev, workerId]
    );
  };

  const handleCardClick = (worker: any) => {
    if (isMultiSelectMode) {
      toggleSelectWorker(worker.id);
    } else {
      navigate(`/workers/${worker.id}`);
    }
  };

  // Bulk Attendance Marking
  const handleBulkAttendance = async (status: 'Present' | 'Absent' | 'Half Day') => {
    const today = new Date().toISOString().split('T')[0];
    
    for (const workerId of selectedWorkerIds) {
      const worker = workers?.find(w => w.id === workerId);
      await markAttendanceMutation.mutateAsync({
        worker_id: workerId,
        date: today,
        status,
        working_hours: status === 'Present' ? 8 : status === 'Half Day' ? 4 : 0,
        overtime_hours: 0,
        project_id: worker?.default_project || undefined
      });
    }

    // Reset multi select
    setIsMultiSelectMode(false);
    setSelectedWorkerIds([]);
  };

  // Add Worker Submit
  const handleAddSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!formData.full_name || !formData.daily_wage) return;

    await addWorkerMutation.mutateAsync({
      full_name: formData.full_name,
      worker_code: formData.worker_code || undefined,
      phone: formData.phone || undefined,
      father_name: formData.father_name || undefined,
      village: formData.village || undefined,
      daily_wage: Number(formData.daily_wage),
      overtime_rate: Number(formData.overtime_rate || 0),
      status: 'Active',
      default_project: formData.default_project || undefined,
      upi_id: formData.upi_id || undefined,
      bank_name: formData.bank_name || undefined,
      account_number: formData.account_number || undefined,
      ifsc: formData.ifsc || undefined,
      joining_date: new Date().toISOString().split('T')[0]
    });

    setIsAddOpen(false);
    resetForm();
  };

  // Edit Worker Load & Submit
  const handleEditOpen = (worker: any) => {
    setSelectedWorker(worker);
    setFormData({
      full_name: worker.full_name || '',
      worker_code: worker.worker_code || '',
      phone: worker.phone || '',
      father_name: worker.father_name || '',
      village: worker.village || '',
      daily_wage: worker.daily_wage?.toString() || '',
      overtime_rate: worker.overtime_rate?.toString() || '',
      default_project: worker.default_project || '',
      upi_id: worker.upi_id || '',
      bank_name: worker.bank_name || '',
      account_number: worker.account_number || '',
      ifsc: worker.ifsc || ''
    });
    setIsEditOpen(true);
  };

  const handleEditSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedWorker || !formData.full_name || !formData.daily_wage) return;

    await updateWorkerMutation.mutateAsync({
      id: selectedWorker.id,
      full_name: formData.full_name,
      worker_code: formData.worker_code,
      phone: formData.phone,
      father_name: formData.father_name,
      village: formData.village,
      daily_wage: Number(formData.daily_wage),
      overtime_rate: Number(formData.overtime_rate || 0),
      default_project: formData.default_project || undefined,
      upi_id: formData.upi_id,
      bank_name: formData.bank_name,
      account_number: formData.account_number,
      ifsc: formData.ifsc
    });

    setIsEditOpen(false);
    resetForm();
  };

  const handleDelete = async (id: string) => {
    if (window.confirm(t('confirmDelete'))) {
      await deleteWorkerMutation.mutateAsync(id);
      setIsEditOpen(false);
      resetForm();
    }
  };

  // Record Payment Submit
  const handlePaymentOpen = (worker: any, type: 'Salary' | 'Advance') => {
    setSelectedWorker(worker);
    setPaymentType(type);
    setPaymentAmount('');
    setPaymentRemarks('');
    setIsPaymentOpen(true);
  };

  const handlePaymentSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedWorker || !paymentAmount) return;

    await addTransactionMutation.mutateAsync({
      worker_id: selectedWorker.id,
      transaction_type: paymentType,
      amount: Number(paymentAmount),
      payment_method: paymentMethod,
      transaction_date: new Date().toISOString().split('T')[0],
      remarks: paymentRemarks || undefined,
      project_id: selectedWorker.default_project || undefined
    });

    setIsPaymentOpen(false);
  };

  // Quick swipe-right -> marks Present Today
  const handleSwipeRightPresent = (worker: any) => {
    const today = new Date().toISOString().split('T')[0];
    markAttendanceMutation.mutate({
      worker_id: worker.id,
      date: today,
      status: 'Present',
      working_hours: 8,
      overtime_hours: 0,
      project_id: worker.default_project || undefined
    });
  };

  const resetForm = () => {
    setFormData({
      full_name: '',
      worker_code: '',
      phone: '',
      father_name: '',
      village: '',
      daily_wage: '',
      overtime_rate: '',
      default_project: '',
      upi_id: '',
      bank_name: '',
      account_number: '',
      ifsc: ''
    });
    setSelectedWorker(null);
  };

  // Filter workers based on search string
  const filteredWorkers = workers?.filter(w => {
    const term = search.toLowerCase();
    return (
      w.full_name.toLowerCase().includes(term) ||
      (w.phone && w.phone.includes(term)) ||
      (w.village && w.village.toLowerCase().includes(term)) ||
      (w.worker_code && w.worker_code.toLowerCase().includes(term))
    );
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
            {isMultiSelectMode ? t('multipleSelect') : t('allWorkers')}
          </h1>
        </div>

        {isMultiSelectMode ? (
          <button
            onClick={() => {
              setIsMultiSelectMode(false);
              setSelectedWorkerIds([]);
            }}
            className="px-3 py-1.5 text-xs font-bold bg-zinc-100 dark:bg-zinc-800 text-zinc-700 dark:text-zinc-300 rounded-xl"
          >
            {t('cancel')}
          </button>
        ) : (
          <button
            onClick={() => setIsAddOpen(true)}
            className="w-9 h-9 rounded-xl bg-violet-600 hover:bg-violet-500 text-white flex items-center justify-center shadow-md shadow-violet-500/20"
          >
            <Plus size={18} />
          </button>
        )}
      </header>

      {/* Main List */}
      <main className="p-5 flex-1 max-w-lg mx-auto w-full flex flex-col gap-4">
        {/* Search Box */}
        <div className="relative">
          <Search className="absolute left-4 top-3.5 text-zinc-400" size={18} />
          <input
            type="text"
            placeholder={t('searchPlaceholder')}
            value={search}
            onChange={e => setSearch(e.target.value)}
            className="w-full bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-2xl pl-11 pr-5 py-3 text-sm focus:ring-2 focus:ring-violet-500 focus:outline-none shadow-sm placeholder:text-zinc-400"
          />
        </div>

        {/* Count */}
        <div className="text-left text-xs font-bold text-zinc-400 dark:text-zinc-500 uppercase tracking-wider pl-1">
          {filteredWorkers?.length || 0} {t('recordsFound')}
        </div>

        {/* List Content */}
        {isLoading ? (
          <div className="py-20 flex flex-col items-center justify-center gap-3">
            <div className="w-8 h-8 rounded-full border-2 border-violet-500 border-t-transparent animate-spin" />
            <span className="text-xs text-zinc-500">Loading Workers...</span>
          </div>
        ) : filteredWorkers?.length === 0 ? (
          <div className="py-20 text-center bg-white dark:bg-zinc-900 rounded-3xl border border-zinc-150 dark:border-zinc-800 p-8 shadow-sm">
            <User size={48} className="mx-auto text-zinc-300 mb-4" />
            <p className="text-sm text-zinc-500 leading-normal">{t('emptyLabourList')}</p>
          </div>
        ) : (
          <div className="flex flex-col gap-1">
            {filteredWorkers?.map(worker => {
              const isSelected = selectedWorkerIds.includes(worker.id);
              
              return (
                <div
                  key={worker.id}
                  onTouchStart={() => handleTouchStart(worker.id)}
                  onTouchEnd={handleTouchEnd}
                  onMouseDown={() => handleTouchStart(worker.id)}
                  onMouseUp={handleTouchEnd}
                >
                  <Swipeable
                    leftActions={
                      <div className="flex items-center gap-2">
                        <Check size={18} />
                        <span className="font-extrabold text-sm">Mark Present</span>
                      </div>
                    }
                    rightActions={
                      <div className="flex items-center gap-3 text-zinc-100">
                        <button
                          onClick={(e) => { e.stopPropagation(); handlePaymentOpen(worker, 'Salary'); }}
                          className="flex flex-col items-center p-2 rounded-xl hover:bg-white/10"
                        >
                          <Wallet size={16} />
                          <span className="text-[9px] font-bold mt-1">Pay</span>
                        </button>
                        <button
                          onClick={(e) => { e.stopPropagation(); handlePaymentOpen(worker, 'Advance'); }}
                          className="flex flex-col items-center p-2 rounded-xl hover:bg-white/10"
                        >
                          <Plus size={16} />
                          <span className="text-[9px] font-bold mt-1">Advance</span>
                        </button>
                        <button
                          onClick={(e) => { e.stopPropagation(); handleEditOpen(worker); }}
                          className="flex flex-col items-center p-2 rounded-xl hover:bg-white/10"
                        >
                          <Edit2 size={16} />
                          <span className="text-[9px] font-bold mt-1">Edit</span>
                        </button>
                      </div>
                    }
                    onSwipeRightComplete={() => handleSwipeRightPresent(worker)}
                  >
                    <div
                      onClick={() => handleCardClick(worker)}
                      className={`flex items-center gap-4 p-4 rounded-xl text-left transition-colors cursor-pointer ${
                        isSelected
                          ? 'bg-violet-50 dark:bg-violet-950/20 border-2 border-violet-500'
                          : 'bg-white dark:bg-zinc-900 hover:bg-zinc-50 dark:hover:bg-zinc-850'
                      }`}
                    >
                      {/* Selection circle or Photo */}
                      {isMultiSelectMode ? (
                        <div className={`w-11 h-11 rounded-full flex items-center justify-center border-2 ${
                          isSelected
                            ? 'bg-violet-600 border-violet-600 text-white'
                            : 'border-zinc-300 dark:border-zinc-700'
                        }`}>
                          {isSelected && <Check size={20} />}
                        </div>
                      ) : (
                        <div className="w-11 h-11 rounded-full bg-violet-100 dark:bg-violet-950/40 text-violet-600 dark:text-violet-400 flex items-center justify-center font-bold text-base shadow-sm">
                          {worker.full_name.charAt(0)}
                        </div>
                      )}

                      {/* Content Info */}
                      <div className="flex-1 min-w-0">
                        <div className="flex items-center justify-between gap-2">
                          <h4 className="text-sm font-extrabold text-zinc-900 dark:text-white truncate">
                            {worker.full_name}
                          </h4>
                          <span className="text-xs font-black text-zinc-900 dark:text-zinc-100">
                            ₹{worker.daily_wage}/day
                          </span>
                        </div>

                        <div className="flex items-center justify-between mt-1 text-xs text-zinc-500">
                          <div className="flex items-center gap-3">
                            {worker.village && (
                              <span className="flex items-center gap-1">
                                <MapPin size={12} />
                                {worker.village}
                              </span>
                            )}
                            {worker.worker_code && (
                              <span className="bg-zinc-100 dark:bg-zinc-800 px-1.5 py-0.5 rounded text-[10px]">
                                Code: {worker.worker_code}
                              </span>
                            )}
                          </div>
                          
                          <span className="text-[10px] text-zinc-400 font-medium">
                            Swipe → Present
                          </span>
                        </div>
                      </div>
                    </div>
                  </Swipeable>
                </div>
              );
            })}
          </div>
        )}
      </main>

      {/* Multi-Select Floating Action Bar */}
      {isMultiSelectMode && (
        <div className="fixed bottom-6 left-6 right-6 z-40 bg-zinc-900 text-white p-4 rounded-3xl flex items-center justify-between shadow-2xl border border-zinc-850">
          <div className="text-xs font-bold">
            {selectedWorkerIds.length} {t('selectedWorkers')}
          </div>
          <div className="flex gap-2">
            <button
              onClick={() => handleBulkAttendance('Present')}
              className="flex items-center gap-1.5 px-3 py-2 bg-emerald-600 hover:bg-emerald-500 rounded-xl text-xs font-bold transition-colors"
            >
              <UserCheck size={14} />
              <span>Present</span>
            </button>
            <button
              onClick={() => handleBulkAttendance('Absent')}
              className="flex items-center gap-1.5 px-3 py-2 bg-red-600 hover:bg-red-500 rounded-xl text-xs font-bold transition-colors"
            >
              <X size={14} />
              <span>Absent</span>
            </button>
          </div>
        </div>
      )}

      {/* Add Worker Bottom Sheet */}
      <BottomSheet isOpen={isAddOpen} onClose={() => { setIsAddOpen(false); resetForm(); }} title={t('addLabour')}>
        <form onSubmit={handleAddSubmit} className="flex flex-col gap-4">
          <div>
            <label className="block text-xs font-bold text-zinc-500 dark:text-zinc-400 uppercase tracking-wider mb-1.5">
              {t('fullName')} *
            </label>
            <input
              type="text"
              required
              value={formData.full_name}
              onChange={e => setFormData({ ...formData, full_name: e.target.value })}
              className="w-full bg-zinc-50 dark:bg-zinc-850 border border-zinc-200 dark:border-zinc-800 rounded-xl px-4 py-2.5 text-sm focus:ring-2 focus:ring-violet-500 focus:outline-none"
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-bold text-zinc-500 dark:text-zinc-400 uppercase tracking-wider mb-1.5">
                {t('dailyWage')} (₹) *
              </label>
              <input
                type="number"
                required
                value={formData.daily_wage}
                onChange={e => setFormData({ ...formData, daily_wage: e.target.value })}
                className="w-full bg-zinc-50 dark:bg-zinc-850 border border-zinc-200 dark:border-zinc-800 rounded-xl px-4 py-2.5 text-sm focus:ring-2 focus:ring-violet-500 focus:outline-none"
              />
            </div>
            <div>
              <label className="block text-xs font-bold text-zinc-500 dark:text-zinc-400 uppercase tracking-wider mb-1.5">
                {t('overtimeRate')} (₹)
              </label>
              <input
                type="number"
                value={formData.overtime_rate}
                onChange={e => setFormData({ ...formData, overtime_rate: e.target.value })}
                className="w-full bg-zinc-50 dark:bg-zinc-850 border border-zinc-200 dark:border-zinc-800 rounded-xl px-4 py-2.5 text-sm focus:ring-2 focus:ring-violet-500 focus:outline-none"
              />
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-bold text-zinc-500 dark:text-zinc-400 uppercase tracking-wider mb-1.5">
                {t('workerCode')} (Hajri No)
              </label>
              <input
                type="text"
                value={formData.worker_code}
                onChange={e => setFormData({ ...formData, worker_code: e.target.value })}
                className="w-full bg-zinc-50 dark:bg-zinc-850 border border-zinc-200 dark:border-zinc-800 rounded-xl px-4 py-2.5 text-sm focus:ring-2 focus:ring-violet-500 focus:outline-none"
              />
            </div>
            <div>
              <label className="block text-xs font-bold text-zinc-500 dark:text-zinc-400 uppercase tracking-wider mb-1.5">
                {t('phone')}
              </label>
              <input
                type="tel"
                value={formData.phone}
                onChange={e => setFormData({ ...formData, phone: e.target.value })}
                className="w-full bg-zinc-50 dark:bg-zinc-850 border border-zinc-200 dark:border-zinc-800 rounded-xl px-4 py-2.5 text-sm focus:ring-2 focus:ring-violet-500 focus:outline-none"
              />
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-bold text-zinc-500 dark:text-zinc-400 uppercase tracking-wider mb-1.5">
                {t('fatherName')}
              </label>
              <input
                type="text"
                value={formData.father_name}
                onChange={e => setFormData({ ...formData, father_name: e.target.value })}
                className="w-full bg-zinc-50 dark:bg-zinc-850 border border-zinc-200 dark:border-zinc-800 rounded-xl px-4 py-2.5 text-sm focus:ring-2 focus:ring-violet-500 focus:outline-none"
              />
            </div>
            <div>
              <label className="block text-xs font-bold text-zinc-500 dark:text-zinc-400 uppercase tracking-wider mb-1.5">
                {t('village')}
              </label>
              <input
                type="text"
                value={formData.village}
                onChange={e => setFormData({ ...formData, village: e.target.value })}
                className="w-full bg-zinc-50 dark:bg-zinc-850 border border-zinc-200 dark:border-zinc-800 rounded-xl px-4 py-2.5 text-sm focus:ring-2 focus:ring-violet-500 focus:outline-none"
              />
            </div>
          </div>

          <div>
            <label className="block text-xs font-bold text-zinc-500 dark:text-zinc-400 uppercase tracking-wider mb-1.5">
              {t('defaultProject')}
            </label>
            <select
              value={formData.default_project}
              onChange={e => setFormData({ ...formData, default_project: e.target.value })}
              className="w-full bg-zinc-50 dark:bg-zinc-850 border border-zinc-200 dark:border-zinc-800 rounded-xl px-4 py-2.5 text-sm focus:ring-2 focus:ring-violet-500 focus:outline-none"
            >
              <option value="">No Active Project</option>
              {projects?.map(p => (
                <option key={p.id} value={p.id}>{p.name}</option>
              ))}
            </select>
          </div>

          <div className="border-t border-zinc-150 dark:border-zinc-850 my-2 pt-4">
            <h4 className="text-xs font-bold text-zinc-400 uppercase tracking-wider mb-3">Bank Details (Optional)</h4>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-xs font-bold text-zinc-550 dark:text-zinc-450 uppercase mb-1.5">UPI ID</label>
                <input
                  type="text"
                  value={formData.upi_id}
                  onChange={e => setFormData({ ...formData, upi_id: e.target.value })}
                  className="w-full bg-zinc-50 dark:bg-zinc-850 border border-zinc-200 dark:border-zinc-800 rounded-xl px-4 py-2.5 text-sm"
                />
              </div>
              <div>
                <label className="block text-xs font-bold text-zinc-550 dark:text-zinc-450 uppercase mb-1.5">Bank Name</label>
                <input
                  type="text"
                  value={formData.bank_name}
                  onChange={e => setFormData({ ...formData, bank_name: e.target.value })}
                  className="w-full bg-zinc-50 dark:bg-zinc-850 border border-zinc-200 dark:border-zinc-800 rounded-xl px-4 py-2.5 text-sm"
                />
              </div>
            </div>
            <div className="grid grid-cols-2 gap-4 mt-3">
              <div>
                <label className="block text-xs font-bold text-zinc-555 dark:text-zinc-455 uppercase mb-1.5">Account Number</label>
                <input
                  type="text"
                  value={formData.account_number}
                  onChange={e => setFormData({ ...formData, account_number: e.target.value })}
                  className="w-full bg-zinc-50 dark:bg-zinc-850 border border-zinc-200 dark:border-zinc-800 rounded-xl px-4 py-2.5 text-sm"
                />
              </div>
              <div>
                <label className="block text-xs font-bold text-zinc-555 dark:text-zinc-455 uppercase mb-1.5">IFSC</label>
                <input
                  type="text"
                  value={formData.ifsc}
                  onChange={e => setFormData({ ...formData, ifsc: e.target.value })}
                  className="w-full bg-zinc-50 dark:bg-zinc-850 border border-zinc-200 dark:border-zinc-800 rounded-xl px-4 py-2.5 text-sm"
                />
              </div>
            </div>
          </div>

          <button
            type="submit"
            className="w-full py-3 bg-violet-600 hover:bg-violet-500 text-white font-bold rounded-xl shadow-md transition-colors mt-2"
          >
            {t('save')}
          </button>
        </form>
      </BottomSheet>

      {/* Edit Worker Bottom Sheet */}
      <BottomSheet isOpen={isEditOpen} onClose={() => { setIsEditOpen(false); resetForm(); }} title="Modify Worker">
        <form onSubmit={handleEditSubmit} className="flex flex-col gap-4">
          <div>
            <label className="block text-xs font-bold text-zinc-550 dark:text-zinc-450 uppercase mb-1.5">{t('fullName')} *</label>
            <input
              type="text"
              required
              value={formData.full_name}
              onChange={e => setFormData({ ...formData, full_name: e.target.value })}
              className="w-full bg-zinc-50 dark:bg-zinc-855 border border-zinc-200 dark:border-zinc-800 rounded-xl px-4 py-2.5 text-sm"
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-bold text-zinc-550 dark:text-zinc-450 uppercase mb-1.5">{t('dailyWage')} *</label>
              <input
                type="number"
                required
                value={formData.daily_wage}
                onChange={e => setFormData({ ...formData, daily_wage: e.target.value })}
                className="w-full bg-zinc-50 dark:bg-zinc-855 border border-zinc-200 dark:border-zinc-800 rounded-xl px-4 py-2.5 text-sm"
              />
            </div>
            <div>
              <label className="block text-xs font-bold text-zinc-550 dark:text-zinc-455 uppercase mb-1.5">{t('overtimeRate')}</label>
              <input
                type="number"
                value={formData.overtime_rate}
                onChange={e => setFormData({ ...formData, overtime_rate: e.target.value })}
                className="w-full bg-zinc-50 dark:bg-zinc-855 border border-zinc-200 dark:border-zinc-800 rounded-xl px-4 py-2.5 text-sm"
              />
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-bold text-zinc-550 dark:text-zinc-455 uppercase mb-1.5">{t('workerCode')}</label>
              <input
                type="text"
                value={formData.worker_code}
                onChange={e => setFormData({ ...formData, worker_code: e.target.value })}
                className="w-full bg-zinc-50 dark:bg-zinc-855 border border-zinc-200 dark:border-zinc-800 rounded-xl px-4 py-2.5 text-sm"
              />
            </div>
            <div>
              <label className="block text-xs font-bold text-zinc-550 dark:text-zinc-455 uppercase mb-1.5">{t('phone')}</label>
              <input
                type="tel"
                value={formData.phone}
                onChange={e => setFormData({ ...formData, phone: e.target.value })}
                className="w-full bg-zinc-50 dark:bg-zinc-855 border border-zinc-200 dark:border-zinc-800 rounded-xl px-4 py-2.5 text-sm"
              />
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-bold text-zinc-550 dark:text-zinc-455 uppercase mb-1.5">{t('fatherName')}</label>
              <input
                type="text"
                value={formData.father_name}
                onChange={e => setFormData({ ...formData, father_name: e.target.value })}
                className="w-full bg-zinc-50 dark:bg-zinc-855 border border-zinc-200 dark:border-zinc-800 rounded-xl px-4 py-2.5 text-sm"
              />
            </div>
            <div>
              <label className="block text-xs font-bold text-zinc-550 dark:text-zinc-455 uppercase mb-1.5">{t('village')}</label>
              <input
                type="text"
                value={formData.village}
                onChange={e => setFormData({ ...formData, village: e.target.value })}
                className="w-full bg-zinc-50 dark:bg-zinc-855 border border-zinc-200 dark:border-zinc-800 rounded-xl px-4 py-2.5 text-sm"
              />
            </div>
          </div>

          <div className="flex gap-3 mt-4">
            <button
              type="button"
              onClick={() => handleDelete(selectedWorker.id)}
              className="flex-1 py-3 bg-red-100 hover:bg-red-200 dark:bg-red-950/20 text-red-600 dark:text-red-400 font-bold rounded-xl border border-red-200 dark:border-red-900 transition-colors"
            >
              Delete
            </button>
            <button
              type="submit"
              className="flex-[2] py-3 bg-violet-600 hover:bg-violet-500 text-white font-bold rounded-xl shadow-md transition-colors"
            >
              Update Details
            </button>
          </div>
        </form>
      </BottomSheet>

      {/* Record Payment/Advance Bottom Sheet */}
      <BottomSheet isOpen={isPaymentOpen} onClose={() => setIsPaymentOpen(false)} title={paymentType === 'Salary' ? 'Record Payment' : 'Record Advance'}>
        <form onSubmit={handlePaymentSubmit} className="flex flex-col gap-4">
          <div>
            <label className="block text-xs font-bold text-zinc-550 dark:text-zinc-450 uppercase mb-1.5">Worker</label>
            <div className="p-3 bg-zinc-100 dark:bg-zinc-850 rounded-xl text-sm font-bold text-zinc-900 dark:text-white">
              {selectedWorker?.full_name}
            </div>
          </div>

          <div>
            <label className="block text-xs font-bold text-zinc-550 dark:text-zinc-450 uppercase mb-1.5">Amount (₹) *</label>
            <input
              type="number"
              required
              value={paymentAmount}
              onChange={e => setPaymentAmount(e.target.value)}
              className="w-full bg-zinc-50 dark:bg-zinc-850 border border-zinc-200 dark:border-zinc-800 rounded-xl px-4 py-2.5 text-sm focus:ring-2 focus:ring-violet-500 focus:outline-none"
            />
          </div>

          <div>
            <label className="block text-xs font-bold text-zinc-550 dark:text-zinc-450 uppercase mb-1.5">Payment Method</label>
            <div className="grid grid-cols-4 gap-2">
              {(['Cash', 'UPI', 'Bank', 'Cheque'] as const).map(method => (
                <button
                  key={method}
                  type="button"
                  onClick={() => setPaymentMethod(method)}
                  className={`py-2 px-1 text-xs font-bold rounded-lg border transition-all ${
                    paymentMethod === method
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
            <label className="block text-xs font-bold text-zinc-550 dark:text-zinc-450 uppercase mb-1.5">Remarks</label>
            <input
              type="text"
              placeholder="E.g. Pay for week 2"
              value={paymentRemarks}
              onChange={e => setPaymentRemarks(e.target.value)}
              className="w-full bg-zinc-50 dark:bg-zinc-850 border border-zinc-200 dark:border-zinc-800 rounded-xl px-4 py-2.5 text-sm focus:ring-2 focus:ring-violet-500 focus:outline-none"
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
