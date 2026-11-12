import React, { useState } from 'react';
import { 
  Bell, 
  Search, 
  ShieldAlert, 
  CheckCircle2, 
  ExternalLink,
  Clock,
  Sparkles
} from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import { Link } from 'react-router-dom';

interface HeaderProps {
  title?: string;
  subtitle?: string;
}

export const Header: React.FC<HeaderProps> = ({ 
  title = 'لوحة التحكم المركزية', 
  subtitle = 'نظام المراقبة والتحكيم المالي والقانوني لمنصة عقودي' 
}) => {
  const { user } = useAuth();
  const [showNotifications, setShowNotifications] = useState(false);

  const notifications = [
    {
      id: 1,
      title: 'نزاع عاجل جديد #DSP-01',
      desc: 'طلب تحكيم على دفعة بقيمة 47,500 ج.م في عقد توريد خوادم.',
      time: 'منذ 15 دقيقة',
      type: 'danger',
      link: '/disputes'
    },
    {
      id: 2,
      title: 'طلب اعتماد محامٍ مقيد بالنقض',
      desc: 'د. هشام الفاسي قدم بطاقة القيد بالنقض للمراجعة.',
      time: 'منذ ساعتين',
      type: 'warning',
      link: '/lawyers'
    },
    {
      id: 3,
      title: 'اكتمال دفعة وساطة #8821',
      desc: 'تم تحرير مبلغ 54,000 ج.م تلقائياً بعد مصادقة الطرفين.',
      time: 'منذ 4 ساعات',
      type: 'success',
      link: '/escrow'
    }
  ];

  return (
    <header className="h-20 bg-oqoody-dark/90 backdrop-blur-md border-b border-oqoody-border px-8 flex items-center justify-between sticky top-0 z-20">
      {/* Title & Path */}
      <div>
        <h2 className="text-xl font-bold text-oqoody-textLight flex items-center gap-2">
          {title}
        </h2>
        <p className="text-xs text-oqoody-textMuted mt-0.5">{subtitle}</p>
      </div>

      {/* Right Controls */}
      <div className="flex items-center gap-4">
        {/* Live Escrow Vault Indicator */}
        <div className="hidden lg:flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-oqoody-card border border-oqoody-border text-xs text-oqoody-textMuted">
          <span className="w-2 h-2 rounded-full bg-oqoody-success animate-ping" />
          <span className="font-medium text-oqoody-textLight">خزينة الضمان Escrow:</span>
          <span className="text-oqoody-gold font-bold">2,450,000 ج.م</span>
        </div>

        {/* Live System Time */}
        <div className="hidden sm:flex items-center gap-1.5 text-xs text-oqoody-textMuted px-3 py-1.5 bg-oqoody-bg/80 rounded-lg border border-oqoody-border/50">
          <Clock className="w-3.5 h-3.5 text-oqoody-gold" />
          <span>{new Date().toLocaleDateString('ar-EG', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}</span>
        </div>

        {/* Notifications Dropdown */}
        <div className="relative">
          <button 
            onClick={() => setShowNotifications(!showNotifications)}
            className="relative p-2.5 rounded-xl bg-oqoody-card border border-oqoody-border text-oqoody-textMuted hover:text-oqoody-gold hover:border-oqoody-gold/40 transition-all"
            title="الإشعارات والتنبيهات العاجلة"
          >
            <Bell className="w-5 h-5" />
            <span className="absolute top-2 right-2 w-2.5 h-2.5 bg-oqoody-danger rounded-full ring-2 ring-oqoody-dark" />
          </button>

          {showNotifications && (
            <div className="absolute left-0 mt-3 w-80 bg-oqoody-card border border-oqoody-border rounded-2xl shadow-2xl p-4 z-50 animate-in fade-in slide-in-from-top-2">
              <div className="flex items-center justify-between pb-3 border-b border-oqoody-border mb-3">
                <span className="font-bold text-sm text-oqoody-textLight">التنبيهات العاجلة</span>
                <span className="text-[11px] bg-oqoody-gold/20 text-oqoody-gold font-bold px-2 py-0.5 rounded-full">
                  3 جديدة
                </span>
              </div>
              <div className="space-y-2.5 max-h-72 overflow-y-auto">
                {notifications.map((n) => (
                  <Link
                    key={n.id}
                    to={n.link}
                    onClick={() => setShowNotifications(false)}
                    className="block p-2.5 rounded-xl bg-oqoody-dark/60 hover:bg-oqoody-dark border border-oqoody-border/40 hover:border-oqoody-gold/30 transition-all text-xs"
                  >
                    <div className="font-bold text-oqoody-textLight mb-1 flex items-center justify-between">
                      <span>{n.title}</span>
                      <span className="text-[10px] text-oqoody-textMuted">{n.time}</span>
                    </div>
                    <p className="text-oqoody-textMuted text-[11px] leading-relaxed">{n.desc}</p>
                  </Link>
                ))}
              </div>
            </div>
          )}
        </div>
      </div>
    </header>
  );
};

