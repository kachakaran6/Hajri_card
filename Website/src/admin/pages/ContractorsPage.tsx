import React, { useState, useMemo } from 'react';
import { useNavigate } from 'react-router-dom';
import { Search, Building2, UserRound, Users } from 'lucide-react';
import { useAllContractors, useAllWorkers } from '../hooks/useAdminData';
import { Badge } from '../components/ui';
import { format } from 'date-fns';

export const ContractorsPage: React.FC = () => {
  const navigate = useNavigate();
  const contractors = useAllContractors();
  const workers = useAllWorkers();
  const [search, setSearch] = useState('');

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
          <div style={{ marginLeft: 'auto', position: 'relative' }}>
            <Search size={13} style={{ position: 'absolute', left: 9, top: '50%', transform: 'translateY(-50%)', color: 'var(--text-subtle)' }} />
            <input
              value={search}
              onChange={e => setSearch(e.target.value)}
              placeholder="Search..."
              className="form-input"
              style={{ paddingLeft: 30, paddingTop: 6, paddingBottom: 6, fontSize: 12, width: 180 }}
            />
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
    </div>
  );
};
