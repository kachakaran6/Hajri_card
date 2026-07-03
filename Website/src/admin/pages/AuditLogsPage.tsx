import React, { useMemo } from 'react';
import { Activity, RefreshCw } from 'lucide-react';
import { useRecentActivity, useAllContractors } from '../hooks/useAdminData';
import { Card, CardHeader, CardTitle, CardContent, Badge, Table, Thead, Tbody, Tr, Th, Td } from '../components/ui';
import { format, formatDistanceToNow } from 'date-fns';

const typeConfig = {
  attendance: { label: 'Attendance', variant: 'outline' as const },
  worker: { label: 'Worker', variant: 'success' as const },
  transaction: { label: 'Payment', variant: 'warning' as const },
};

export const AuditLogsPage: React.FC = () => {
  const activity = useRecentActivity();
  const contractors = useAllContractors();

  const contractorMap = useMemo(() => {
    const m: Record<string, string> = {};
    (contractors.data || []).forEach(c => { m[c.id] = c.full_name; });
    return m;
  }, [contractors.data]);

  return (
    <div className="flex flex-col gap-5">
      {/* <div className="flex items-center justify-between">
        <div>
          <h1 className="text-lg font-semibold">Audit Log</h1>
          <p className="text-sm text-zinc-500 dark:text-zinc-400">
            Recent platform activity — last 7 days
          </p>
        </div>
      </div> */}

      {/* Summary badges */}
      <div className="flex flex-wrap gap-2">
        <button
          onClick={() => activity.refetch()}
          disabled={activity.isFetching}
          className="flex items-center gap-1.5 px-3 py-1.5 text-xs border border-zinc-200 dark:border-zinc-700 rounded-[6px] text-zinc-600 dark:text-zinc-400 hover:bg-zinc-50 dark:hover:bg-zinc-800 transition-colors disabled:opacity-50"
        >
          <RefreshCw className={`w-3 h-3 ${activity.isFetching ? 'animate-spin' : ''}`} />
          Refresh
        </button>
        {(['attendance', 'worker', 'transaction'] as const).map(type => {
          const count = (activity.data || []).filter(a => a.type === type).length;
          const cfg = typeConfig[type];
          return (
            <div key={type} className="flex items-center gap-1.5 px-3 py-1.5 bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-[6px] text-xs">
              <Badge variant={cfg.variant}>{cfg.label}</Badge>
              <span className="font-semibold text-zinc-700 dark:text-zinc-300">{count} events</span>
            </div>
          );
        })}
        <div className="flex items-center gap-1.5 px-3 py-1.5 bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-[6px] text-xs">
          <Activity className="w-3 h-3 text-zinc-400" />
          <span className="font-semibold text-zinc-700 dark:text-zinc-300">
            {activity.data?.length ?? 0} total events
          </span>
        </div>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Activity Feed</CardTitle>
        </CardHeader>
        <CardContent className="p-0">
          {activity.isLoading ? (
            <div className="py-8 text-center text-sm text-zinc-400">Loading activity...</div>
          ) : !activity.data?.length ? (
            <div className="py-8 text-center text-sm text-zinc-400">No recent activity found</div>
          ) : (
            <Table>
              <Thead>
                <Tr>
                  <Th>Time</Th>
                  <Th>Type</Th>
                  <Th>Contractor</Th>
                  <Th>Action</Th>
                  <Th>Details</Th>
                </Tr>
              </Thead>
              <Tbody>
                {activity.data.map(a => {
                  const cfg = typeConfig[a.type];
                  return (
                    <Tr key={a.id + a.type}>
                      <Td className="text-xs text-zinc-500 whitespace-nowrap">
                        <div>{format(new Date(a.timestamp), 'dd MMM HH:mm')}</div>
                        <div className="text-zinc-400 text-[10px]">
                          {formatDistanceToNow(new Date(a.timestamp), { addSuffix: true })}
                        </div>
                      </Td>
                      <Td>
                        <Badge variant={cfg.variant}>{cfg.label}</Badge>
                      </Td>
                      <Td className="text-xs text-zinc-600 dark:text-zinc-400">
                        {contractorMap[a.contractor_id] ?? a.contractor_id?.slice(0, 8) ?? '—'}
                      </Td>
                      <Td className="font-medium text-xs">{a.action}</Td>
                      <Td className="text-xs text-zinc-500">{a.details}</Td>
                    </Tr>
                  );
                })}
              </Tbody>
            </Table>
          )}
        </CardContent>
      </Card>
    </div>
  );
};
