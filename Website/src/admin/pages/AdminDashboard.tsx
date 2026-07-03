import React, { useMemo } from 'react';
import {
  LineChart, Line, BarChart, Bar, PieChart, Pie, Cell,
  XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer,
} from 'recharts';
import { format, parseISO, subDays } from 'date-fns';
import { Users, UserRound, IndianRupee, TrendingUp, Activity } from 'lucide-react';
import {
  useAllContractors, useAllWorkers, useGlobalAttendanceToday,
  useAttendanceLast30Days, useGlobalTransactions, useRecentActivity,
} from '../hooks/useAdminData';
import { StatCard, Badge } from '../components/ui';

const PIE_COLORS = ['#18181b', '#71717a', '#d4d4d8'];

export const AdminDashboard: React.FC = () => {
  const contractors = useAllContractors();
  const workers = useAllWorkers();
  const todayAtt = useGlobalAttendanceToday();
  const last30 = useAttendanceLast30Days();
  const transactions = useGlobalTransactions();
  const activity = useRecentActivity();

  const totalWagesPaid = useMemo(() =>
    (transactions.data || []).filter(t => t.transaction_type === 'Salary').reduce((s, t) => s + Number(t.amount), 0),
    [transactions.data]
  );

  const todayPresent = (todayAtt.data || []).filter(a => a.status === 'Present' || a.status === 'Overtime').length;
  const todayAbsent = (todayAtt.data || []).filter(a => a.status === 'Absent').length;
  const todayHalf = (todayAtt.data || []).filter(a => a.status === 'Half Day').length;

  const attendancePie = [
    { name: 'Present', value: todayPresent },
    { name: 'Absent', value: todayAbsent },
    { name: 'Half Day', value: todayHalf },
  ].filter(d => d.value > 0);

  const dailyLine = useMemo(() => {
    const grouped: Record<string, number> = {};
    for (let i = 29; i >= 0; i--) {
      const d = format(subDays(new Date(), i), 'yyyy-MM-dd');
      grouped[d] = 0;
    }
    (last30.data || []).forEach(a => { if (grouped[a.date] !== undefined) grouped[a.date]++; });
    return Object.entries(grouped).map(([date, count]) => ({
      date: format(parseISO(date), 'MMM d'), count,
    }));
  }, [last30.data]);

  const contractorBar = useMemo(() => {
    const map: Record<string, number> = {};
    (workers.data || []).forEach(w => { map[w.contractor_id] = (map[w.contractor_id] || 0) + 1; });
    return (contractors.data || [])
      .map(c => ({ name: c.full_name.split(' ')[0], workers: map[c.id] || 0 }))
      .sort((a, b) => b.workers - a.workers).slice(0, 6);
  }, [workers.data, contractors.data]);

  const contractorMap = useMemo(() => {
    const m: Record<string, string> = {};
    (contractors.data || []).forEach(c => { m[c.id] = c.full_name; });
    return m;
  }, [contractors.data]);

  const ttStyle = { background: 'var(--card-bg)', border: '1px solid var(--border)', borderRadius: 6, fontSize: 12, color: 'var(--text)' };
  const axisStyle = { fontSize: 11, fill: 'var(--text-muted)' };

  return (
    <div>
      {/* Page header */}
      {/* <div className="page-header">
        <h1 className="page-title">Dashboard</h1>
        <p className="page-subtitle">{format(new Date(), 'EEEE, d MMMM yyyy')} — Platform overview</p>
      </div> */}

      {/* Stats */}
      <div className="stats-grid">
        <StatCard label="Total Contractors" value={contractors.data?.length ?? '—'} icon={<Users size={16} />} />
        <StatCard label="Total Workers" value={workers.data?.length ?? '—'} icon={<UserRound size={16} />} />
        <StatCard
          label="Present Today"
          value={todayPresent}
          sub={`${todayAbsent} absent · ${todayHalf} half day`}
          icon={<TrendingUp size={16} />}
        />
        <StatCard label="Total Wages Paid" value={`₹${(totalWagesPaid / 1000).toFixed(1)}k`} icon={<IndianRupee size={16} />} />
      </div>

      {/* Charts row 1 */}
      <div className="charts-grid">
        <div className="card">
          <div className="card-header">
            <span className="card-title">Daily Active Workers — Last 30 Days</span>
          </div>
          <div className="card-content">
            <ResponsiveContainer width="100%" height={200}>
              <LineChart data={dailyLine} margin={{ top: 4, right: 8, left: -24, bottom: 0 }}>
                <CartesianGrid strokeDasharray="3 3" stroke="var(--border)" />
                <XAxis dataKey="date" tick={axisStyle} interval={4} tickLine={false} axisLine={false} />
                <YAxis tick={axisStyle} tickLine={false} axisLine={false} />
                <Tooltip contentStyle={ttStyle} />
                <Line type="monotone" dataKey="count" stroke="var(--text)" strokeWidth={1.5} dot={false} name="Workers" />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </div>

        <div className="card">
          <div className="card-header">
            <span className="card-title">Today's Attendance</span>
          </div>
          <div className="card-content" style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 12 }}>
            {attendancePie.length > 0 ? (
              <>
                <ResponsiveContainer width="100%" height={150}>
                  <PieChart>
                    <Pie data={attendancePie} cx="50%" cy="50%" innerRadius={45} outerRadius={65} paddingAngle={3} dataKey="value">
                      {attendancePie.map((_, i) => <Cell key={i} fill={PIE_COLORS[i % PIE_COLORS.length]} />)}
                    </Pie>
                    <Tooltip contentStyle={ttStyle} />
                  </PieChart>
                </ResponsiveContainer>
                <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8, justifyContent: 'center' }}>
                  {attendancePie.map((d, i) => (
                    <div key={d.name} style={{ display: 'flex', alignItems: 'center', gap: 5, fontSize: 11, color: 'var(--text-muted)' }}>
                      <span style={{ width: 8, height: 8, borderRadius: '50%', background: PIE_COLORS[i], display: 'inline-block' }} />
                      {d.name} ({d.value})
                    </div>
                  ))}
                </div>
              </>
            ) : (
              <div style={{ height: 150, display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--text-subtle)', fontSize: 13 }}>
                No data yet today
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Charts row 2 */}
      <div className="charts-grid-2" style={{ marginTop: 12 }}>
        <div className="card">
          <div className="card-header">
            <span className="card-title">Workers per Contractor</span>
          </div>
          <div className="card-content">
            <ResponsiveContainer width="100%" height={180}>
              <BarChart data={contractorBar} margin={{ top: 4, right: 8, left: -24, bottom: 0 }}>
                <CartesianGrid strokeDasharray="3 3" stroke="var(--border)" vertical={false} />
                <XAxis dataKey="name" tick={axisStyle} tickLine={false} axisLine={false} />
                <YAxis tick={axisStyle} tickLine={false} axisLine={false} />
                <Tooltip contentStyle={ttStyle} />
                <Bar dataKey="workers" fill="var(--text)" radius={[4, 4, 0, 0]} name="Workers" maxBarSize={36} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>

        <div className="card">
          <div className="card-header">
            <span className="card-title" style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
              <Activity size={13} /> Recent Activity
            </span>
          </div>
          <div style={{ maxHeight: 220, overflowY: 'auto' }}>
            {(activity.data || []).slice(0, 10).map(a => (
              <div key={a.id} style={{ padding: '10px 16px', borderBottom: '1px solid var(--border)' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 2 }}>
                  <Badge variant={a.type === 'worker' ? 'success' : a.type === 'transaction' ? 'warning' : 'outline'}>
                    {a.type}
                  </Badge>
                  <span style={{ fontSize: 12, fontWeight: 500, color: 'var(--text)' }}>{a.action}</span>
                </div>
                <p style={{ fontSize: 11, color: 'var(--text-muted)', margin: 0 }}>
                  {contractorMap[a.contractor_id]?.split(' ')[0] ?? a.contractor_id?.slice(0, 8)} · {a.details}
                </p>
                <p style={{ fontSize: 10, color: 'var(--text-subtle)', margin: '2px 0 0' }}>
                  {format(new Date(a.timestamp), 'MMM d, HH:mm')}
                </p>
              </div>
            ))}
            {(!activity.data || activity.data.length === 0) && (
              <div style={{ padding: '24px 16px', textAlign: 'center', fontSize: 13, color: 'var(--text-subtle)' }}>
                No recent activity
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};
