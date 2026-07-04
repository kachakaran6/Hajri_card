import React, { useState, useMemo } from 'react';
import { useNavigate } from 'react-router-dom';
import { Search, Building2, UserRound, Users, Plus } from 'lucide-react';
import { useAllContractors, useAllWorkers, useAddContractor } from '../hooks/useAdminData';
import { Badge, Dialog, Input } from '../components/ui';
import { format } from 'date-fns';

export const ContractorsPage: React.FC = () => {
  const navigate = useNavigate();
  const contractors = useAllContractors();
  const workers = useAllWorkers();
  const addContractor = useAddContractor();
  const [search, setSearch] = useState('');

  const [open, setOpen] = useState(false);
  const [form, setForm] = useState({
    full_name: '', email: '', password: '', company_name: '', phone: ''
  });
  const [formError, setFormError] = useState('');

  const handleAddContractor = async (e: React.FormEvent) => {
    e.preventDefault();
    setFormError('');
    if (!form.full_name || !form.email || !form.password) {
      setFormError('Name, email, and password are required.');
      return;
    }
    try {
      await addContractor.mutateAsync({
        full_name: form.full_name.trim(),
        email: form.email.trim(),
        password: form.password,
        company_name: form.company_name.trim() || undefined,
        phone: form.phone.trim() || undefined,
      });
      setOpen(false);
      setForm({ full_name: '', email: '', password: '', company_name: '', phone: '' });
    } catch (err: any) {
      setFormError(err.message || 'Failed to create contractor');
    }
  };

  const workerCountMap = useMemo(() => {
    const map: Record<string, number> = {};
    (workers.data || []).forEach(w => { map[w.contractor_id] = (map[w.contractor_id] || 0) + 1; });
    return map;
  }, [workers.data]);

  const filtered = useMemo(() => {
    const q = search.toLowerCase();
    return (contractors.data || []).filter(c =>
      c.full_name.toLowerCase().includes(q) ||
      (c.company_name ?? '').toLowerCase().includes(q) ||
      (c.phone ?? '').includes(q)
    );
  }, [contractors.data, search]);

  const avgWorkers = contractors.data?.length
    ? Math.round((workers.data?.length ?? 0) / contractors.data.length)
    : 0;

  return (
    <div>
      {/* <div className="page-header" style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', flexWrap: 'wrap', gap: 12 }}>
        <div>
          <h1 className="page-title">Contractors</h1>
          <p className="page-subtitle">{contractors.data?.length ?? 0} registered contractors</p>
        </div>
      </div> */}

      {/* Summary cards */}
      <div className="stats-grid" style={{ gridTemplateColumns: 'repeat(3, 1fr)' }}>
        <div className="stat-card">
          <div>
            <p className="stat-card-label">Total Contractors</p>
            <p className="stat-card-value">{contractors.data?.length ?? '—'}</p>
          </div>
          <div className="stat-card-icon"><Building2 size={16} /></div>
        </div>
        <div className="stat-card">
          <div>
            <p className="stat-card-label">Total Workers</p>
            <p className="stat-card-value">{workers.data?.length ?? '—'}</p>
          </div>
          <div className="stat-card-icon"><UserRound size={16} /></div>
        </div>
        <div className="stat-card">
          <div>
            <p className="stat-card-label">Avg Workers / Contractor</p>
            <p className="stat-card-value">{avgWorkers}</p>
          </div>
          <div className="stat-card-icon"><Users size={16} /></div>
        </div>
      </div>

      {/* Table card */}
      <div className="card">
        <div className="card-header">
          <span className="card-title">All Contractors</span>
          <div style={{ marginLeft: 'auto', display: 'flex', gap: '8px', alignItems: 'center' }}>
            <div style={{ position: 'relative' }}>
              <Search size={13} style={{ position: 'absolute', left: 9, top: '50%', transform: 'translateY(-50%)', color: 'var(--text-subtle)' }} />
              <input
                value={search}
                onChange={e => setSearch(e.target.value)}
                placeholder="Search..."
                className="form-input"
                style={{ paddingLeft: 30, paddingTop: 6, paddingBottom: 6, fontSize: 12, width: 180 }}
              />
            </div>
            <button className="btn btn-primary btn-sm" onClick={() => setOpen(true)}>
              <Plus size={13} /> Add Contractor
            </button>
          </div>
        </div>

        {contractors.isLoading ? (
          <div style={{ padding: '32px 16px', textAlign: 'center', color: 'var(--text-subtle)', fontSize: 13 }}>Loading...</div>
        ) : filtered.length === 0 ? (
          <div style={{ padding: '32px 16px', textAlign: 'center', color: 'var(--text-subtle)', fontSize: 13 }}>No contractors found</div>
        ) : (
          <div className="overflow-table">
            <table className="admin-table">
              <thead>
                <tr>
                  <th>Name</th>
                  <th>Company</th>
                  <th>Phone</th>
                  <th>Workers</th>
                  <th>Joined</th>
                </tr>
              </thead>
              <tbody>
                {filtered.map(c => (
                  <tr key={c.id} className="clickable" onClick={() => navigate(`/admin/contractors/${c.id}`)}>
                    <td>
                      <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                        <div className="avatar">{c.full_name[0]}</div>
                        <span style={{ fontWeight: 500 }}>{c.full_name}</span>
                      </div>
                    </td>
                    <td style={{ color: 'var(--text-muted)' }}>{c.company_name || '—'}</td>
                    <td style={{ fontFamily: 'monospace', fontSize: 12, color: 'var(--text-muted)' }}>{c.phone || '—'}</td>
                    <td>
                      <Badge variant={workerCountMap[c.id] > 0 ? 'success' : 'default'}>
                        {workerCountMap[c.id] ?? 0} workers
                      </Badge>
                    </td>
                    <td style={{ color: 'var(--text-muted)', fontSize: 12 }}>
                      {c.created_at ? format(new Date(c.created_at), 'dd MMM yyyy') : '—'}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Add Contractor Dialog */}
      <Dialog open={open} onClose={() => setOpen(false)} title="Add Contractor">
        <form onSubmit={handleAddContractor} style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
          {formError && (
            <div style={{ padding: '10px 12px', background: 'rgba(220,38,38,0.08)', border: '1px solid rgba(220,38,38,0.2)', borderRadius: 6, fontSize: 12, color: '#dc2626' }}>
              {formError}
            </div>
          )}
          <Input label="Full Name *" placeholder="Contractor full name" value={form.full_name} onChange={e => setForm(f => ({ ...f, full_name: e.target.value }))} required />
          <Input label="Email / Login ID *" type="email" placeholder="email@example.com" value={form.email} onChange={e => setForm(f => ({ ...f, email: e.target.value }))} required />
          <Input label="Password *" type="password" placeholder="Min 6 characters" value={form.password} onChange={e => setForm(f => ({ ...f, password: e.target.value }))} required minLength={6} />
          
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
            <Input label="Company Name" placeholder="Company" value={form.company_name} onChange={e => setForm(f => ({ ...f, company_name: e.target.value }))} />
            <Input label="Phone" placeholder="+91 99999 88888" value={form.phone} onChange={e => setForm(f => ({ ...f, phone: e.target.value }))} />
          </div>

          <div style={{ display: 'flex', gap: 8, paddingTop: 4 }}>
            <button type="submit" disabled={addContractor.isPending} className="btn btn-primary" style={{ flex: 1 }}>
              {addContractor.isPending ? 'Adding...' : 'Add Contractor'}
            </button>
            <button type="button" className="btn btn-outline" onClick={() => setOpen(false)}>Cancel</button>
          </div>
        </form>
      </Dialog>
    </div>
  );
};
