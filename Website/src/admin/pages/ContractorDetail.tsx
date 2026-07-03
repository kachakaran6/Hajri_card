import React, { useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { ArrowLeft, Plus, Building2, Phone, UserRound, IndianRupee, TrendingUp } from 'lucide-react';
import {
  useAllContractors, useAllWorkers, useGlobalAttendanceToday, useAddWorkerForContractor,
} from '../hooks/useAdminData';
import { Badge, Dialog, Input, Select } from '../components/ui';
import { format } from 'date-fns';

export const ContractorDetail: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const contractors = useAllContractors();
  const workers = useAllWorkers(id);
  const todayAtt = useGlobalAttendanceToday();
  const addWorker = useAddWorkerForContractor();

  const contractor = contractors.data?.find(c => c.id === id);
  const todayPresent = (todayAtt.data || []).filter(a =>
    a.contractor_id === id && (a.status === 'Present' || a.status === 'Overtime')
  ).length;
  const totalDailyWage = (workers.data || []).reduce((s, w) => s + (w.daily_wage || 0), 0);

  const [open, setOpen] = useState(false);
  const [form, setForm] = useState({
    full_name: '', phone: '', village: '', daily_wage: '',
    joining_date: new Date().toISOString().split('T')[0], status: 'Active',
  });
  const [formError, setFormError] = useState('');

  const handleAddWorker = async (e: React.FormEvent) => {
    e.preventDefault();
    setFormError('');
    if (!form.full_name || !form.daily_wage || !id) { setFormError('Name and daily wage are required.'); return; }
    try {
      await addWorker.mutateAsync({
        contractor_id: id, full_name: form.full_name.trim(),
        phone: form.phone || undefined, village: form.village || undefined,
        daily_wage: Number(form.daily_wage), joining_date: form.joining_date, status: form.status,
      });
      setOpen(false);
      setForm({ full_name: '', phone: '', village: '', daily_wage: '', joining_date: new Date().toISOString().split('T')[0], status: 'Active' });
    } catch (err: any) { setFormError(err.message || 'Failed to add worker'); }
  };

  if (!contractors.isLoading && !contractor) return (
    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', height: 240, gap: 12 }}>
      <p style={{ color: 'var(--text-muted)', fontSize: 13 }}>Contractor not found</p>
      <button className="btn btn-outline btn-sm" onClick={() => navigate('/admin/contractors')}>
        <ArrowLeft size={13} /> Back
      </button>
    </div>
  );

  return (
    <div>
      {/* Header */}
      <div style={{ display: 'flex', alignItems: 'flex-start', gap: 12, marginBottom: 20 }}>
        <button
          onClick={() => navigate('/admin/contractors')}
          style={{ marginTop: 2, padding: 6, borderRadius: 6, border: 'none', background: 'transparent', cursor: 'pointer', color: 'var(--text-muted)' }}
          onMouseEnter={e => (e.currentTarget.style.background = 'var(--bg-surface-2)')}
          onMouseLeave={e => (e.currentTarget.style.background = 'transparent')}
        >
          <ArrowLeft size={16} />
        </button>
        <div style={{ flex: 1 }}>
          <h1 className="page-title">{contractor?.full_name ?? '...'}</h1>
          <div style={{ display: 'flex', flexWrap: 'wrap', alignItems: 'center', gap: 10, marginTop: 4 }}>
            {contractor?.company_name && (
              <span style={{ display: 'flex', alignItems: 'center', gap: 4, fontSize: 12, color: 'var(--text-muted)' }}>
                <Building2 size={12} />{contractor.company_name}
              </span>
            )}
            {contractor?.phone && (
              <span style={{ display: 'flex', alignItems: 'center', gap: 4, fontSize: 12, color: 'var(--text-muted)' }}>
                <Phone size={12} />{contractor.phone}
              </span>
            )}
            {contractor?.created_at && (
              <Badge variant="outline">Joined {format(new Date(contractor.created_at), 'MMM yyyy')}</Badge>
            )}
          </div>
        </div>
        <button className="btn btn-primary btn-sm" onClick={() => setOpen(true)}>
          <Plus size={13} /> Add Worker
        </button>
      </div>

      {/* Stats */}
      <div className="stats-grid" style={{ gridTemplateColumns: 'repeat(3, 1fr)', marginBottom: 20 }}>
        <div className="stat-card">
          <div>
            <p className="stat-card-label">Total Workers</p>
            <p className="stat-card-value">{workers.data?.length ?? '—'}</p>
          </div>
          <div className="stat-card-icon"><UserRound size={16} /></div>
        </div>
        <div className="stat-card">
          <div>
            <p className="stat-card-label">Present Today</p>
            <p className="stat-card-value">{todayPresent}</p>
          </div>
          <div className="stat-card-icon"><TrendingUp size={16} /></div>
        </div>
        <div className="stat-card">
          <div>
            <p className="stat-card-label">Daily Wage Pool</p>
            <p className="stat-card-value">₹{totalDailyWage.toLocaleString()}</p>
            <p className="stat-card-sub">max per day</p>
          </div>
          <div className="stat-card-icon"><IndianRupee size={16} /></div>
        </div>
      </div>

      {/* Workers table */}
      <div className="card">
        <div className="card-header">
          <span className="card-title"><UserRound size={13} /> Workers ({workers.data?.length ?? 0})</span>
        </div>
        {workers.isLoading ? (
          <div style={{ padding: '32px 16px', textAlign: 'center', color: 'var(--text-subtle)', fontSize: 13 }}>Loading...</div>
        ) : !workers.data?.length ? (
          <div style={{ padding: '32px 16px', textAlign: 'center', color: 'var(--text-subtle)', fontSize: 13 }}>
            No workers yet.{' '}
            <button onClick={() => setOpen(true)} style={{ color: 'var(--text)', background: 'none', border: 'none', cursor: 'pointer', textDecoration: 'underline', fontSize: 13 }}>
              Add the first one
            </button>
          </div>
        ) : (
          <div className="overflow-table">
            <table className="admin-table">
              <thead>
                <tr>
                  <th>Name</th><th>Phone</th><th>Village</th><th>Daily Wage</th><th>Status</th><th>Joined</th>
                </tr>
              </thead>
              <tbody>
                {workers.data.map(w => (
                  <tr key={w.id}>
                    <td style={{ fontWeight: 500 }}>{w.full_name}</td>
                    <td style={{ fontFamily: 'monospace', fontSize: 12, color: 'var(--text-muted)' }}>{w.phone || '—'}</td>
                    <td style={{ color: 'var(--text-muted)' }}>{w.village || '—'}</td>
                    <td style={{ fontWeight: 500 }}>₹{w.daily_wage.toLocaleString()}</td>
                    <td><Badge variant={w.status === 'Active' ? 'success' : 'warning'}>{w.status}</Badge></td>
                    <td style={{ fontSize: 12, color: 'var(--text-muted)' }}>
                      {w.joining_date ? format(new Date(w.joining_date), 'dd MMM yyyy') : '—'}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Add Worker Dialog */}
      <Dialog open={open} onClose={() => setOpen(false)} title="Add Worker">
        <form onSubmit={handleAddWorker} style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
          {formError && (
            <div style={{ padding: '10px 12px', background: 'rgba(220,38,38,0.08)', border: '1px solid rgba(220,38,38,0.2)', borderRadius: 6, fontSize: 12, color: '#dc2626' }}>
              {formError}
            </div>
          )}
          <p style={{ fontSize: 12, color: 'var(--text-muted)', margin: 0 }}>
            For contractor: <strong style={{ color: 'var(--text)' }}>{contractor?.full_name}</strong>
          </p>
          <Input label="Full Name *" placeholder="Worker full name" value={form.full_name} onChange={e => setForm(f => ({ ...f, full_name: e.target.value }))} required />
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
            <Input label="Phone" placeholder="+91 99999 88888" value={form.phone} onChange={e => setForm(f => ({ ...f, phone: e.target.value }))} />
            <Input label="Village / City" placeholder="Village or city" value={form.village} onChange={e => setForm(f => ({ ...f, village: e.target.value }))} />
          </div>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
            <Input label="Daily Wage (₹) *" type="number" placeholder="0" value={form.daily_wage} onChange={e => setForm(f => ({ ...f, daily_wage: e.target.value }))} required min="0" />
            <Input label="Joining Date" type="date" value={form.joining_date} onChange={e => setForm(f => ({ ...f, joining_date: e.target.value }))} />
          </div>
          <Select label="Status" value={form.status} onChange={e => setForm(f => ({ ...f, status: e.target.value }))}>
            <option value="Active">Active</option>
            <option value="Inactive">Inactive</option>
          </Select>
          <div style={{ display: 'flex', gap: 8, paddingTop: 4 }}>
            <button type="submit" disabled={addWorker.isPending} className="btn btn-primary" style={{ flex: 1 }}>
              {addWorker.isPending ? 'Adding...' : 'Add Worker'}
            </button>
            <button type="button" className="btn btn-outline" onClick={() => setOpen(false)}>Cancel</button>
          </div>
        </form>
      </Dialog>
    </div>
  );
};
