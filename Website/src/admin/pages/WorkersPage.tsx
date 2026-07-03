import React, { useState, useMemo } from 'react';
import { useNavigate } from 'react-router-dom';
import { Search } from 'lucide-react';
import { useAllWorkers, useAllContractors } from '../hooks/useAdminData';
import { Badge } from '../components/ui';
import { format } from 'date-fns';

export const WorkersPage: React.FC = () => {
  const navigate = useNavigate();
  const workers = useAllWorkers();
  const contractors = useAllContractors();
  const [search, setSearch] = useState('');
  const [filterContractor, setFilterContractor] = useState('');
  const [filterStatus, setFilterStatus] = useState('');

  const contractorMap = useMemo(() => {
    const m: Record<string, string> = {};
    (contractors.data || []).forEach(c => { m[c.id] = c.full_name; });
    return m;
  }, [contractors.data]);

  const filtered = useMemo(() => {
    const q = search.toLowerCase();
    return (workers.data || []).filter(w => {
      if (filterContractor && w.contractor_id !== filterContractor) return false;
      if (filterStatus && w.status !== filterStatus) return false;
      return (
        w.full_name.toLowerCase().includes(q) ||
        (w.phone || '').includes(q) ||
        (w.village || '').toLowerCase().includes(q)
      );
    });
  }, [workers.data, search, filterContractor, filterStatus]);

  const selectStyle: React.CSSProperties = {
    padding: '6px 10px', fontSize: 12,
    background: 'var(--input-bg)', border: '1px solid var(--input-border)',
    borderRadius: 6, color: 'var(--text)', outline: 'none', cursor: 'pointer',
  };

  return (
    <div>
      {/* <div className="page-header">
        <h1 className="page-title">Workers</h1>
        <p className="page-subtitle">{workers.data?.length ?? 0} workers across all contractors</p>
      </div> */}

      <div className="card">
        <div className="card-header" style={{ flexWrap: 'wrap', gap: 8 }}>
          <span className="card-title">All Workers</span>
          <div style={{ marginLeft: 'auto', display: 'flex', alignItems: 'center', gap: 8, flexWrap: 'wrap' }}>
            {/* Search */}
            <div style={{ position: 'relative' }}>
              <Search size={13} style={{ position: 'absolute', left: 9, top: '50%', transform: 'translateY(-50%)', color: 'var(--text-subtle)' }} />
              <input
                value={search}
                onChange={e => setSearch(e.target.value)}
                placeholder="Search workers..."
                className="form-input"
                style={{ paddingLeft: 30, paddingTop: 6, paddingBottom: 6, fontSize: 12, width: 170 }}
              />
            </div>
            {/* Contractor filter */}
            <select value={filterContractor} onChange={e => setFilterContractor(e.target.value)} style={selectStyle}>
              <option value="">All Contractors</option>
              {(contractors.data || []).map(c => <option key={c.id} value={c.id}>{c.full_name}</option>)}
            </select>
            {/* Status filter */}
            <select value={filterStatus} onChange={e => setFilterStatus(e.target.value)} style={selectStyle}>
              <option value="">All Status</option>
              <option value="Active">Active</option>
              <option value="Inactive">Inactive</option>
            </select>
          </div>
        </div>

        {workers.isLoading ? (
          <div style={{ padding: '32px 16px', textAlign: 'center', color: 'var(--text-subtle)', fontSize: 13 }}>Loading...</div>
        ) : filtered.length === 0 ? (
          <div style={{ padding: '32px 16px', textAlign: 'center', color: 'var(--text-subtle)', fontSize: 13 }}>No workers match your filters</div>
        ) : (
          <div className="overflow-table">
            <table className="admin-table">
              <thead>
                <tr>
                  <th>Name</th>
                  <th>Contractor</th>
                  <th>Phone</th>
                  <th>Village</th>
                  <th>Daily Wage</th>
                  <th>Status</th>
                  <th>Joined</th>
                </tr>
              </thead>
              <tbody>
                {filtered.map(w => (
                  <tr key={w.id} className="clickable" onClick={() => navigate(`/admin/contractors/${w.contractor_id}`)}>
                    <td>
                      <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                        <div className="avatar">{w.full_name[0]}</div>
                        <span style={{ fontWeight: 500 }}>{w.full_name}</span>
                      </div>
                    </td>
                    <td style={{ fontSize: 12, color: 'var(--text-muted)' }}>
                      {contractorMap[w.contractor_id] ?? w.contractor_id?.slice(0, 8)}
                    </td>
                    <td style={{ fontFamily: 'monospace', fontSize: 12, color: 'var(--text-muted)' }}>{w.phone || '—'}</td>
                    <td style={{ color: 'var(--text-muted)' }}>{w.village || '—'}</td>
                    <td style={{ fontWeight: 500 }}>₹{w.daily_wage?.toLocaleString()}</td>
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

        {filtered.length > 0 && (
          <div style={{ padding: '10px 16px', borderTop: '1px solid var(--border)', fontSize: 11, color: 'var(--text-subtle)' }}>
            Showing {filtered.length} of {workers.data?.length} workers
          </div>
        )}
      </div>
    </div>
  );
};
