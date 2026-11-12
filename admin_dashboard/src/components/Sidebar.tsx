import React from 'react';
import { NavLink, useNavigate } from 'react-router-dom';
import { 
  LayoutDashboard, 
  Users, 
  GraduationCap, 
  FileText, 
  MessageSquare, 
  ShieldCheck, 
  Scale, 
  Wallet, 
  LogOut,
  ChevronLeft
} from 'lucide-react';
import { useAuth } from '../context/AuthContext';

interface SidebarProps {
  urgentLawyersCount?: number;
  openDisputesCount?: number;
}

export const Sidebar: React.FC<SidebarProps> = ({ 
  urgentLawyersCount = 2, 
  openDisputesCount = 1 
}) => {
  const { user, logout } = useAuth();
  const navigate = useNavigate();

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  const navItems = [
    { 
      to: '/', 
      label: 'الرئيسية والتحليلات', 
      icon: LayoutDashboard,
      badge: null 
    },
    { 
      to: '/users', 
      label: 'إدارة المستخدمين', 
      icon: Users,
      badge: null 
    },
    { 
      to: '/lawyers', 
      label: 'توثيق المحامين', 
      icon: GraduationCap,
      badge: urgentLawyersCount > 0 ? urgentLawyersCount : null,
      badgeColor: 'bg-oqoody-warning text-oqoody-bg' 
    },
    { 
      to: '/templates', 
      label: 'نماذج العقود الذكية', 
      icon: FileText,
      badge: null 
    },
    { 
      to: '/consultations', 
      label: 'الاستشارات القانونية', 
      icon: MessageSquare,
      badge: null 
    },
    { 
      to: '/escrow', 
      label: 'الوساطة وحساب الضمان', 
      icon: ShieldCheck,
      badge: null 
    },
    { 
      to: '/disputes', 
      label: 'غرفة التحكيم والنزاعات', 
      icon: Scale,
      badge: openDisputesCount > 0 ? openDisputesCount : null,
      badgeColor: 'bg-oqoody-danger text-white animate-pulse' 
    },
    { 
      to: '/financials', 
      label: 'المالية وسجل العمولات', 
      icon: Wallet,
      badge: null 
    },
  ];

  const getRoleArabic = (role?: string) => {
    switch (role) {
      case 'super_admin': return 'سوبر أدمن (المدير العام)';
      case 'legal_director': return 'مدير الإدارة القانونية';
      case 'financial_director': return 'المدير المالي';
      case 'dispute_agent': return 'محكّم ومسؤول نزاعات';
      default: return 'مشرف منصة';
    }
  };

  return (
    <aside className="w-72 bg-oqoody-dark border-l border-oqoody-border flex flex-col h-screen sticky top-0 select-none z-30">
      {/* Brand Header */}
      <div className="p-6 border-b border-oqoody-border flex items-center gap-3">
        <div className="w-12 h-12 rounded-xl bg-oqoody-card border border-oqoody-gold/40 flex items-center justify-center shadow-gold-glow flex-shrink-0">
          <svg className="w-8 h-8" viewBox="0 0 200 200">
            <rect width="200" height="200" rx="35" fill="#0D2818"/>
            <path d="M100 35 L100 155 M60 155 L140 155 M50 70 L150 70 M50 70 L35 110 C35 120 65 120 65 110 Z M150 70 L135 110 C135 120 165 120 165 110 Z" 
                  stroke="#D4AF37" strokeWidth="10" fill="none" strokeLinecap="round" strokeLinejoin="round"/>
          </svg>
        </div>
        <div>
          <h1 className="text-xl font-bold tracking-tight text-oqoody-textLight flex items-center gap-1.5">
            عقودي <span className="text-oqoody-gold text-xs font-normal px-1.5 py-0.5 rounded border border-oqoody-gold/30 bg-oqoody-gold/10">إداري</span>
          </h1>
          <p className="text-xs text-oqoody-textMuted font-medium">منصة توثيق العقود والوساطة</p>
        </div>
      </div>

      {/* Navigation List */}
      <nav className="flex-1 px-4 py-5 space-y-1.5 overflow-y-auto">
        <div className="text-[11px] font-semibold text-oqoody-textMuted/70 px-3 pb-2 uppercase tracking-wider">
          الوحدات التشغيلية
        </div>
        {navItems.map((item) => {
          const Icon = item.icon;
          return (
            <NavLink
              key={item.to}
              to={item.to}
              className={({ isActive }) => `
                flex items-center justify-between px-3.5 py-3 rounded-xl text-sm font-medium transition-all duration-200 group
                ${isActive 
                  ? 'bg-gradient-to-l from-oqoody-card to-oqoody-dark border-r-4 border-oqoody-gold text-oqoody-gold font-semibold shadow-inner' 
                  : 'text-oqoody-textMuted hover:text-oqoody-textLight hover:bg-oqoody-card/60'
                }
              `}
            >
              <div className="flex items-center gap-3">
                <Icon className="w-5 h-5 transition-transform group-hover:scale-110" />
                <span>{item.label}</span>
              </div>
              {item.badge !== null && (
                <span className={`text-[11px] font-bold px-2 py-0.5 rounded-full ${item.badgeColor || 'bg-oqoody-border text-oqoody-gold'}`}>
                  {item.badge}
                </span>
              )}
            </NavLink>
          );
        })}
      </nav>

      {/* User Footer Profile */}
      <div className="p-4 border-t border-oqoody-border bg-oqoody-bg/50">
        <div className="flex items-center justify-between p-2 rounded-xl bg-oqoody-card border border-oqoody-border">
          <div className="flex items-center gap-2.5 overflow-hidden">
            <div className="w-10 h-10 rounded-lg bg-oqoody-gold/20 border border-oqoody-gold/40 flex items-center justify-center text-oqoody-gold font-bold text-base flex-shrink-0">
              {user?.fullName ? user.fullName.charAt(0) : 'أ'}
            </div>
            <div className="overflow-hidden">
              <div className="text-sm font-bold text-oqoody-textLight truncate">
                {user?.fullName || 'المستشار فادي جميل'}
              </div>
              <div className="text-[10px] text-oqoody-gold truncate">
                {getRoleArabic(user?.role)}
              </div>
            </div>
          </div>
          <button
            onClick={handleLogout}
            title="تسجيل الخروج"
            className="p-2 rounded-lg text-oqoody-textMuted hover:text-oqoody-danger hover:bg-oqoody-danger/10 transition-colors"
          >
            <LogOut className="w-4 h-4" />
          </button>
        </div>
      </div>
    </aside>
  );
};

