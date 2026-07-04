import React, { useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import {
  ArrowLeft, Plus, Building2, Phone, UserRound, IndianRupee,
  TrendingUp, FolderKanban, MapPin, CalendarDays, ClipboardList,
} from 'lucide-react';
import {
  useAllContractors, useAllWorkers, useGlobalAttendanceToday,
  useAddWorkerForContractor, useProjectsForContractor, useAddProjectForContractor,
} from '../hooks/useAdminData';
import { Badge, Dialog, Input, Select } from '../components/ui';
import { format } from 'date-fns';

// ── Status badge colour maps ─────────────────────────────────────────────────
const projectStatusVariant = (status: string) => {
  switch (status) {
    case 'Active':    return 'success';
    case 'Completed': return 'outline';
    case 'On Hold':   return 'warning';
    case 'Cancelled': return 'danger';
    default:          return 'default';
  }
};

// ─── Main Component ──────────────────────────────────────────────────────────
export const ContractorDetail: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();

  // ── Data hooks ──────────────────────────────────────────────────────────────
  const contractors   = useAllContractors();
  const workers       = useAllWorkers(id);
  const todayAtt      = useGlobalAttendanceToday();
  const projects      = useProjectsForContractor(id);
  const addWorker     = useAddWorkerForContractor();
  const addProject    = useAddProjectForContractor();

  const contractor    = contractors.data?.find(c => c.id === id);
  const todayPresent  = (todayAtt.data || []).filter(a =>
    a.contractor_id === id && (a.status === 'Present' || a.status === 'Overtime')
  ).length;
  const totalDailyWage = (workers.data || []).reduce((s, w) => s + (w.daily_wage || 0), 0);

  // ── Tab state ───────────────────────────────────────────────────────────────
  const [tab, setTab] = useState<'workers' | 'projects'>('workers');

  // ── Worker form state ────────────────────────────────────────────────────────
  const [workerOpen, setWorkerOpen]   = useState(false);
  const [workerForm, setWorkerForm]   = useState({
    full_name: '', phone: '', village: '', daily_wage: '',
    joining_date: new Date().toISOString().split('T')[0], status: 'Active',
  });
  const [workerError, setWorkerError] = useState('');

  const handleAddWorker = async (e: React.FormEvent) => {
    e.preventDefault();
    setWorkerError('');
    if (!workerForm.full_name || !workerForm.daily_wage || !id) {
      setWorkerError('Name and daily wage are required.'); return;
    }
    try {
      await addWorker.mutateAsync({
        contractor_id: id, full_name: workerForm.full_name.trim(),
        phone: workerForm.phone || undefined, village: workerForm.village || undefined,
        daily_wage: Number(workerForm.daily_wage), joining_date: workerForm.joining_date,
        status: workerForm.status,
      });
      setWorkerOpen(false);
      setWorkerForm({ full_name: '', phone: '', village: '', daily_wage: '', joining_date: new Date().toISOString().split('T')[0], status: 'Active' });
    } catch (err: any) { setWorkerError(err.message || 'Failed to add worker'); }
  };

  // ── Project form state ───────────────────────────────────────────────────────
  const [projectOpen, setProjectOpen]   = useState(false);
  const [projectForm, setProjectForm]   = useState({
    name: '', location: '', status: 'Active',
    start_date: new Date().toISOString().split('T')[0],
    end_date: '', notes: '',
  });
  const [projectError, setProjectError] = useState('');

  const handleAddProject = async (e: React.FormEvent) => {
    e.preventDefault();
    setProjectError('');
    if (!projectForm.name || !id) { setProjectError('Project name is required.'); return; }
    try {
      await addProject.mutateAsync({
        contractor_id: id,
        name: projectForm.name.trim(),
        location: projectForm.location.trim() || undefined,
        status: projectForm.status,
        start_date: projectForm.start_date || undefined,
        end_date: projectForm.end_date || undefined,
        notes: projectForm.notes.trim() || undefined,
      });
      setProjectOpen(false);
      setProjectForm({ name: '', location: '', status: 'Active', start_date: new Date().toISOString().split('T')[0], end_date: '', notes: '' });
    } catch (err: any) { setProjectError(err.message || 'Failed to add project'); }
  };

  // ── Not found guard ──────────────────────────────────────────────────────────
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
      {/* ── Page Header ─────────────────────────────────────────────────────── */}
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
        {/* Action buttons — change based on active tab */}
        {tab === 'workers' ? (
          <button className="btn btn-primary btn-sm" onClick={() => setWorkerOpen(true)}>
            <Plus size={13} /> Add Worker
          </button>
        ) : (
          <button className="btn btn-primary btn-sm" onClick={() => setProjectOpen(true)}>
            <Plus size={13} /> Add Project
          </button>
        )}
      </div>

      {/* ── Stats Row ────────────────────────────────────────────────────────── */}
      <div className="stats-grid" style={{ gridTemplateColumns: 'repeat(4, 1fr)', marginBottom: 20 }}>
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
        <div className="stat-card">
          <div>
            <p className="stat-card-label">Total Projects</p>
            <p className="stat-card-value">{projects.data?.length ?? '—'}</p>
            <p className="stat-card-sub">{projects.data?.filter(p => p.status === 'Active').length ?? 0} active</p>
          </div>
          <div className="stat-card-icon"><FolderKanban size={16} /></div>
        </div>
      </div>

      {/* ── Tab Bar ──────────────────────────────────────────────────────────── */}
      <div style={{
        display: 'flex', borderBottom: '1px solid var(--border)', marginBottom: 16, gap: 0,
      }}>
        {(['workers', 'projects'] as const).map(t => (
          <button
            key={t}
            onClick={() => setTab(t)}
            style={{
              padding: '9px 18px', fontSize: 13, fontWeight: 500, cursor: 'pointer',
              background: 'none', border: 'none', borderBottom: tab === t ? '2px solid var(--accent)' : '2px solid transparent',
              color: tab === t ? 'var(--text)' : 'var(--text-muted)',
              display: 'flex', alignItems: 'center', gap: 6, marginBottom: -1, transition: 'color 0.15s',
            }}
          >
            {t === 'workers' ? <UserRound size={13} /> : <FolderKanban size={13} />}
            {t === 'workers' ? `Workers (${workers.data?.length ?? 0})` : `Projects (${projects.data?.length ?? 0})`}
          </button>
        ))}
      </div>

      {/* ── Workers Tab ──────────────────────────────────────────────────────── */}
      {tab === 'workers' && (
        <div className="card">
          <div className="card-header">
            <span className="card-title"><UserRound size={13} /> Workers</span>
          </div>
          {workers.isLoading ? (
            <div style={{ padding: '32px 16px', textAlign: 'center', color: 'var(--text-subtle)', fontSize: 13 }}>Loading...</div>
          ) : !workers.data?.length ? (
            <div style={{ padding: '40px 16px', textAlign: 'center', color: 'var(--text-subtle)', fontSize: 13 }}>
              <UserRound size={28} style={{ marginBottom: 8, opacity: 0.3 }} />
              <p style={{ margin: '0 0 8px' }}>No workers yet.</p>
              <button onClick={() => setWorkerOpen(true)} style={{ color: 'var(--accent)', background: 'none', border: 'none', cursor: 'pointer', textDecoration: 'underline', fontSize: 13 }}>
                Add the first worker
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
                      <td style={{ fontWeight: 500 }}>
                        <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                          <div className="avatar">{w.full_name[0]}</div>
                          {w.full_name}
                        </div>
                      </td>
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
      )}

      {/* ── Projects Tab ─────────────────────────────────────────────────────── */}
      {tab === 'projects' && (
        <div>
          {projects.isLoading ? (
            <div style={{ padding: '32px 16px', textAlign: 'center', color: 'var(--text-subtle)', fontSize: 13 }}>Loading...</div>
          ) : !projects.data?.length ? (
            <div style={{ padding: '60px 16px', textAlign: 'center', color: 'var(--text-subtle)', fontSize: 13 }}>
              <FolderKanban size={32} style={{ marginBottom: 10, opacity: 0.3 }} />
              <p style={{ margin: '0 0 8px', fontWeight: 500, color: 'var(--text-muted)' }}>No projects yet</p>
              <p style={{ margin: '0 0 16px', fontSize: 12 }}>Add the first project for {contractor?.full_name}</p>
              <button onClick={() => setProjectOpen(true)} className="btn btn-primary btn-sm">
                <Plus size={13} /> Add First Project
              </button>
            </div>
          ) : (
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(300px, 1fr))', gap: 14 }}>
              {projects.data.map(p => (
                <div key={p.id} className="card" style={{ padding: 0, overflow: 'hidden' }}>
                  {/* Card top accent bar by status */}
                  <div style={{
                    height: 4,
                    background: p.status === 'Active' ? 'var(--accent)' :
                      p.status === 'Completed' ? '#22c55e' :
                      p.status === 'On Hold' ? '#f59e0b' : '#ef4444',
                  }} />
                  <div style={{ padding: '14px 16px' }}>
                    <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', gap: 8, marginBottom: 10 }}>
                      <div>
                        <p style={{ margin: 0, fontWeight: 600, fontSize: 14, color: 'var(--text)' }}>{p.name}</p>
                        {p.location && (
                          <span style={{ display: 'flex', alignItems: 'center', gap: 4, fontSize: 12, color: 'var(--text-muted)', marginTop: 3 }}>
                            <MapPin size={11} />{p.location}
                          </span>
                        )}
                      </div>
                      <Badge variant={projectStatusVariant(p.status) as any}>{p.status}</Badge>
                    </div>

                    {/* Dates */}
                    {(p.start_date || p.end_date) && (
                      <div style={{ display: 'flex', gap: 12, fontSize: 11, color: 'var(--text-subtle)', marginBottom: 8 }}>
                        {p.start_date && (
                          <span style={{ display: 'flex', alignItems: 'center', gap: 4 }}>
                            <CalendarDays size={10} />
                            Start: {format(new Date(p.start_date), 'dd MMM yyyy')}
                          </span>
                        )}
                        {p.end_date && (
                          <span style={{ display: 'flex', alignItems: 'center', gap: 4 }}>
                            <CalendarDays size={10} />
                            End: {format(new Date(p.end_date), 'dd MMM yyyy')}
                          </span>
                        )}
                      </div>
                    )}

                    {/* Notes */}
                    {p.notes && (
                      <p style={{
                        margin: 0, fontSize: 12, color: 'var(--text-muted)',
                        borderTop: '1px solid var(--border)', paddingTop: 8,
                        display: '-webkit-box', WebkitLineClamp: 2, WebkitBoxOrient: 'vertical', overflow: 'hidden',
                      }}>
                        <ClipboardList size={10} style={{ marginRight: 4, verticalAlign: 'middle' }} />
                        {p.notes}
                      </p>
                    )}

                    <p style={{ margin: '8px 0 0', fontSize: 11, color: 'var(--text-subtle)' }}>
                      Added {format(new Date(p.created_at), 'dd MMM yyyy')}
                    </p>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      )}

      {/* ── Add Worker Dialog ─────────────────────────────────────────────────── */}
      <Dialog open={workerOpen} onClose={() => setWorkerOpen(false)} title="Add Worker">
        <form onSubmit={handleAddWorker} style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
          {workerError && (
            <div style={{ padding: '10px 12px', background: 'rgba(220,38,38,0.08)', border: '1px solid rgba(220,38,38,0.2)', borderRadius: 6, fontSize: 12, color: '#dc2626' }}>
              {workerError}
            </div>
          )}
          <p style={{ fontSize: 12, color: 'var(--text-muted)', margin: 0 }}>
            For contractor: <strong style={{ color: 'var(--text)' }}>{contractor?.full_name}</strong>
          </p>
          <Input label="Full Name *" placeholder="Worker full name" value={workerForm.full_name} onChange={e => setWorkerForm(f => ({ ...f, full_name: e.target.value }))} required />
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
            <Input label="Phone" placeholder="+91 99999 88888" value={workerForm.phone} onChange={e => setWorkerForm(f => ({ ...f, phone: e.target.value }))} />
            <Input label="Village / City" placeholder="Village or city" value={workerForm.village} onChange={e => setWorkerForm(f => ({ ...f, village: e.target.value }))} />
          </div>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
            <Input label="Daily Wage (₹) *" type="number" placeholder="0" value={workerForm.daily_wage} onChange={e => setWorkerForm(f => ({ ...f, daily_wage: e.target.value }))} required min="0" />
            <Input label="Joining Date" type="date" value={workerForm.joining_date} onChange={e => setWorkerForm(f => ({ ...f, joining_date: e.target.value }))} />
          </div>
          <Select label="Status" value={workerForm.status} onChange={e => setWorkerForm(f => ({ ...f, status: e.target.value }))}>
            <option value="Active">Active</option>
            <option value="Inactive">Inactive</option>
          </Select>
          <div style={{ display: 'flex', gap: 8, paddingTop: 4 }}>
            <button type="submit" disabled={addWorker.isPending} className="btn btn-primary" style={{ flex: 1 }}>
              {addWorker.isPending ? 'Adding...' : 'Add Worker'}
            </button>
            <button type="button" className="btn btn-outline" onClick={() => setWorkerOpen(false)}>Cancel</button>
          </div>
        </form>
      </Dialog>

      {/* ── Add Project Dialog ────────────────────────────────────────────────── */}
      <Dialog open={projectOpen} onClose={() => setProjectOpen(false)} title="Add Project">
        <form onSubmit={handleAddProject} style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
          {projectError && (
            <div style={{ padding: '10px 12px', background: 'rgba(220,38,38,0.08)', border: '1px solid rgba(220,38,38,0.2)', borderRadius: 6, fontSize: 12, color: '#dc2626' }}>
              {projectError}
            </div>
          )}
          <p style={{ fontSize: 12, color: 'var(--text-muted)', margin: 0 }}>
            For contractor: <strong style={{ color: 'var(--text)' }}>{contractor?.full_name}</strong>
          </p>
          <Input
            label="Project Name *"
            placeholder="e.g. HDFC Bank Building Renovation"
            value={projectForm.name}
            onChange={e => setProjectForm(f => ({ ...f, name: e.target.value }))}
            required
          />
          <Input
            label="Location / Site"
            placeholder="e.g. Ahmedabad, Gujarat"
            value={projectForm.location}
            onChange={e => setProjectForm(f => ({ ...f, location: e.target.value }))}
          />
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
            <Input label="Start Date" type="date" value={projectForm.start_date} onChange={e => setProjectForm(f => ({ ...f, start_date: e.target.value }))} />
            <Input label="End Date (Expected)" type="date" value={projectForm.end_date} onChange={e => setProjectForm(f => ({ ...f, end_date: e.target.value }))} />
          </div>
          <Select label="Status" value={projectForm.status} onChange={e => setProjectForm(f => ({ ...f, status: e.target.value }))}>
            <option value="Active">Active</option>
            <option value="On Hold">On Hold</option>
            <option value="Completed">Completed</option>
            <option value="Cancelled">Cancelled</option>
          </Select>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
            <label className="form-label">Notes / Description</label>
            <textarea
              placeholder="Any additional details about the project..."
              value={projectForm.notes}
              onChange={e => setProjectForm(f => ({ ...f, notes: e.target.value }))}
              rows={3}
              style={{
                width: '100%', padding: '8px 10px', fontSize: 13, resize: 'vertical',
                background: 'var(--input-bg)', border: '1px solid var(--input-border)',
                borderRadius: 6, color: 'var(--text)', outline: 'none',
                fontFamily: 'inherit', boxSizing: 'border-box',
              }}
            />
          </div>
          <div style={{ display: 'flex', gap: 8, paddingTop: 4 }}>
            <button type="submit" disabled={addProject.isPending} className="btn btn-primary" style={{ flex: 1 }}>
              {addProject.isPending ? 'Saving...' : 'Add Project'}
            </button>
            <button type="button" className="btn btn-outline" onClick={() => setProjectOpen(false)}>Cancel</button>
          </div>
        </form>
      </Dialog>
    </div>
  );
};
