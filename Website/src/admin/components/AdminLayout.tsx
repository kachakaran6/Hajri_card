import React, { useState, useEffect } from 'react';
import { Link, useLocation } from 'react-router-dom';
import {
  LayoutDashboard, Users, UserRound, Activity,
  Menu, X, Moon, Sun, LogOut, Shield,
} from 'lucide-react';
import { supabase } from '../../utils/supabaseClient';

const navLinks = [
  { to: '/admin', label: 'Dashboard', icon: LayoutDashboard },
  { to: '/admin/contractors', label: 'Contractors', icon: Users },
  { to: '/admin/workers', label: 'Workers', icon: UserRound },
  { to: '/admin/activity', label: 'Audit Log', icon: Activity },
];

export const AdminLayout = ({ children }: { children: React.ReactNode }) => {
  const location = useLocation();
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [dark, setDark] = useState(() =>
    document.documentElement.classList.contains('dark')
  );

  useEffect(() => {
    document.documentElement.classList.toggle('dark', dark);
    localStorage.setItem('admin-theme', dark ? 'dark' : 'light');
  }, [dark]);

  useEffect(() => setSidebarOpen(false), [location.pathname]);

  const handleSignOut = async () => {
    await supabase.auth.signOut();
    window.location.reload();
  };

  return (
    <div className="admin-shell">
      {/* Mobile overlay */}
      <div
        className={`admin-overlay${sidebarOpen ? ' visible' : ''}`}
        onClick={() => setSidebarOpen(false)}
      />

      {/* Sidebar */}
      <aside className={`admin-sidebar${sidebarOpen ? ' open' : ''}`}>
        {/* Logo */}
        <div className="admin-sidebar-logo">
          <div className="admin-sidebar-logo-icon">
            <Shield size={15} />
          </div>
          <div className="admin-sidebar-logo-text">
            <p>Hajri Admin</p>
            <p>Master Control</p>
          </div>
          <button
            onClick={() => setSidebarOpen(false)}
            style={{ marginLeft: 'auto', background: 'none', border: 'none', cursor: 'pointer', color: 'var(--text-muted)', display: 'none' }}
            className="lg-hidden-close"
          >
            <X size={16} />
          </button>
        </div>

        {/* Nav */}
        <nav className="admin-sidebar-nav">
          {navLinks.map(({ to, label, icon: Icon }) => {
            const active = location.pathname === to ||
              (to !== '/admin' && location.pathname.startsWith(to));
            return (
              <Link key={to} to={to} className={`admin-sidebar-link${active ? ' active' : ''}`}>
                <Icon size={15} />
                {label}
              </Link>
            );
          })}
        </nav>

        {/* Bottom */}
        <div className="admin-sidebar-bottom">
          <button className="admin-sidebar-btn" onClick={() => setDark(d => !d)}>
            {dark ? <Sun size={14} /> : <Moon size={14} />}
            {dark ? 'Light mode' : 'Dark mode'}
          </button>
          <button className="admin-sidebar-btn danger" onClick={handleSignOut}>
            <LogOut size={14} />
            Sign out
          </button>
        </div>
      </aside>

      {/* Main */}
      <div className="admin-main">
        {/* Topbar */}
        <header className="admin-header">
          <button className="admin-hamburger" onClick={() => setSidebarOpen(true)}>
            <Menu size={16} />
          </button>
          <span className="admin-header-breadcrumb">
            {navLinks.find(l =>
              l.to === location.pathname ||
              (l.to !== '/admin' && location.pathname.startsWith(l.to))
            )?.label ?? 'Admin'}
          </span>
          <div className="admin-header-avatar">A</div>
        </header>

        {/* Page content */}
        <main className="admin-content">
          {children}
        </main>
      </div>
    </div>
  );
};
