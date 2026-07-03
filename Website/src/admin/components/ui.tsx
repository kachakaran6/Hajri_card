import React from 'react';

// ─── CARD ───────────────────────────────────────────────────────────────────

export const Card = ({ children, className = '' }: { children: React.ReactNode; className?: string }) => (
  <div className={`card ${className}`}>{children}</div>
);

export const CardHeader = ({ children, className = '' }: { children: React.ReactNode; className?: string }) => (
  <div className={`card-header ${className}`}>{children}</div>
);

export const CardTitle = ({ children }: { children: React.ReactNode }) => (
  <span className="card-title">{children}</span>
);

export const CardContent = ({ children, className = '' }: { children: React.ReactNode; className?: string }) => (
  <div className={`card-content ${className}`}>{children}</div>
);

// ─── BADGE ──────────────────────────────────────────────────────────────────

type BadgeVariant = 'default' | 'success' | 'warning' | 'danger' | 'outline';

export const Badge = ({
  children, variant = 'default', className = '',
}: { children: React.ReactNode; variant?: BadgeVariant; className?: string }) => (
  <span className={`badge badge-${variant} ${className}`}>{children}</span>
);

// ─── BUTTON ─────────────────────────────────────────────────────────────────

type ButtonVariant = 'default' | 'outline' | 'ghost' | 'danger';
type ButtonSize = 'sm' | 'md' | 'lg';

export const Button = ({
  children, variant = 'default', size = 'md', className = '',
  disabled, onClick, type = 'button',
}: {
  children: React.ReactNode; variant?: ButtonVariant; size?: ButtonSize;
  className?: string; disabled?: boolean; onClick?: () => void; type?: 'button' | 'submit' | 'reset';
}) => {
  const varClass = variant === 'default' ? 'btn-primary' : variant === 'outline' ? 'btn-outline' : 'btn-ghost';
  const sizeClass = size === 'sm' ? 'btn-sm' : size === 'lg' ? 'btn-lg' : '';
  return (
    <button type={type} disabled={disabled} onClick={onClick}
      className={`btn ${varClass} ${sizeClass} ${className}`}>
      {children}
    </button>
  );
};

// ─── FORM INPUTS ─────────────────────────────────────────────────────────────

export const Input = React.forwardRef<
  HTMLInputElement, React.InputHTMLAttributes<HTMLInputElement> & { label?: string }
>(({ label, className = '', style, ...props }, ref) => (
  <div style={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
    {label && <label className="form-label">{label}</label>}
    <input ref={ref} className={`form-input ${className}`} style={style} {...props} />
  </div>
));
Input.displayName = 'Input';

export const Select = React.forwardRef<
  HTMLSelectElement, React.SelectHTMLAttributes<HTMLSelectElement> & { label?: string }
>(({ label, className = '', children, ...props }, ref) => (
  <div style={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
    {label && <label className="form-label">{label}</label>}
    <select ref={ref} className={`form-select ${className}`} {...props}>{children}</select>
  </div>
));
Select.displayName = 'Select';

// ─── TABLE ──────────────────────────────────────────────────────────────────

export const Table = ({ children }: { children: React.ReactNode }) => (
  <div className="overflow-table">
    <table className="admin-table">{children}</table>
  </div>
);
export const Thead = ({ children }: { children: React.ReactNode }) => <thead>{children}</thead>;
export const Tbody = ({ children }: { children: React.ReactNode }) => <tbody>{children}</tbody>;
export const Tr = ({
  children, className = '', onClick,
}: { children: React.ReactNode; className?: string; onClick?: () => void }) => (
  <tr className={`${onClick ? 'clickable' : ''} ${className}`} onClick={onClick}>{children}</tr>
);
export const Th = ({ children, className = '' }: { children: React.ReactNode; className?: string }) => (
  <th className={className}>{children}</th>
);
export const Td = ({ children, className = '' }: { children: React.ReactNode; className?: string }) => (
  <td className={className}>{children}</td>
);

// ─── DIALOG ─────────────────────────────────────────────────────────────────

export const Dialog = ({
  open, onClose, title, children,
}: { open: boolean; onClose: () => void; title: string; children: React.ReactNode }) => {
  if (!open) return null;
  return (
    <div className="dialog-overlay" onClick={e => { if (e.target === e.currentTarget) onClose(); }}>
      <div className="dialog-box">
        <div className="dialog-header">
          <span className="dialog-title">{title}</span>
          <button onClick={onClose} style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'var(--text-muted)', display: 'flex', alignItems: 'center' }}>
            <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
              <path d="M12 4L4 12M4 4l8 8" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
            </svg>
          </button>
        </div>
        <div className="dialog-body">{children}</div>
      </div>
    </div>
  );
};

// ─── STAT CARD ───────────────────────────────────────────────────────────────

export const StatCard = ({
  label, value, sub, icon,
}: { label: string; value: string | number; sub?: string; icon?: React.ReactNode }) => (
  <div className="stat-card">
    <div>
      <p className="stat-card-label">{label}</p>
      <p className="stat-card-value">{value}</p>
      {sub && <p className="stat-card-sub">{sub}</p>}
    </div>
    {icon && <div className="stat-card-icon">{icon}</div>}
  </div>
);
