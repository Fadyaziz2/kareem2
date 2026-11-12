import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { 
  Users, 
  GraduationCap, 
  ShieldCheck, 
  Scale, 
  TrendingUp, 
  AlertTriangle, 
  ArrowUpRight, 
  FileText, 
  Coins,
  ChevronLeft,
  CheckCircle,
  Clock
} from 'lucide-react';
import { 
  AreaChart, 
  Area, 
  XAxis, 
  YAxis, 
  CartesianGrid, 
  Tooltip, 
  ResponsiveContainer,
  PieChart, 
  Pie, 
  Cell
} from 'recharts';
import { adminApi } from '../services/api';
import { DashboardStats } from '../types';

export const Dashboard: React.FC = () => {
  const [stats, setStats] = useState<DashboardStats | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    fetchStats();
  }, []);

  const fetchStats = async () => {
    setIsLoading(true);
    try {
      const data = await adminApi.getDashboardStats();
      setStats(data);
    } catch (err) {
      console.error(err);
    } finally {
      setIsLoading(false);
    }
  };

  const kpis = [
    {
      title: 'إجمالي الأعضاء والعملاء',
      value: stats?.totalUsers || 1480,
      sub: '+12% نمو شهري',
      icon: Users,
      color: 'text-oqoody-gold',
      border: 'border-oqoody-gold/30',
      link: '/users'
    },
    {
      title: 'المحامين المعتمدين بالنقابة',
      value: stats?.approvedLawyers || 142,
      sub: `${stats?.pendingLawyers || 2} طلبات قيد المراجعة`,
      icon: GraduationCap,
      color: 'text-oqoody-success',
      border: 'border-oqoody-success/30',
      link: '/lawyers'
    },
    {
      title: 'الوساطة ورصيد الضمان المحتجز',
      value: `${(stats?.totalHeldBalance || 2450000).toLocaleString()} ج.م`,
      sub: `${stats?.activeEscrows || 89} صفقة نشطة بالخزينة`,
      icon: ShieldCheck,
      color: 'text-emerald-400',
      border: 'border-emerald-500/30',
      link: '/escrow'
    },
    {
      title: 'النزاعات وجلسات التحكيم',
      value: stats?.openDisputes || 1,
      sub: 'تحت المداولة والتدقيق',
      icon: Scale,
      color: 'text-oqoody-danger',
      border: 'border-oqoody-danger/30',
      link: '/disputes'
    }
  ];

  return (
    <div className="space-y-8">
      {/* KPI Cards Row */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
        {kpis.map((kpi, idx) => {
          const Icon = kpi.icon;
          return (
            <Link
              key={idx}
              to={kpi.link}
              className={`oqoody-card p-6 block transition-all duration-300 hover:-translate-y-1 hover:shadow-gold-glow ${kpi.border}`}
            >
              <div className="flex items-center justify-between mb-4">
                <span className="text-xs font-semibold text-oqoody-textMuted">{kpi.title}</span>
                <div className={`p-2 rounded-xl bg-oqoody-card/80 border border-oqoody-border ${kpi.color}`}>
                  <Icon className="w-5 h-5" />
                </div>
              </div>
              <div className="text-2xl font-black text-oqoody-textLight tracking-tight mb-1">
                {kpi.value}
              </div>
              <div className="text-[11px] text-oqoody-textMuted flex items-center gap-1">
                <span className="text-oqoody-gold">●</span>
                <span>{kpi.sub}</span>
              </div>
            </Link>
          );
        })}
      </div>

      {/* Analytics Charts Row */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Revenue Performance Chart (2 cols) */}
        <div className="oqoody-card p-6 lg:col-span-2 flex flex-col justify-between">
          <div className="flex items-center justify-between mb-6">
            <div>
              <h3 className="text-base font-bold text-oqoody-textLight flex items-center gap-2">
                <TrendingUp className="w-5 h-5 text-oqoody-gold" />
                <span>نمو الإيرادات والسيولة المالية (شهرياً)</span>
              </h3>
              <p className="text-xs text-oqoody-textMuted mt-0.5">
                توزيع العائدات بين عمولات الوساطة (Escrow) والاستشارات وبيع النماذج
              </p>
            </div>
            <div className="flex items-center gap-4 text-xs">
              <span className="flex items-center gap-1.5 text-oqoody-gold">
                <span className="w-3 h-3 rounded-full bg-oqoody-gold" /> عمولات الوساطة
              </span>
              <span className="flex items-center gap-1.5 text-oqoody-success">
                <span className="w-3 h-3 rounded-full bg-oqoody-success" /> نماذج العقود
              </span>
            </div>
          </div>

          <div className="h-72 w-full">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={stats?.monthlyRevenue || []} margin={{ top: 10, right: 10, left: 0, bottom: 0 }}>
                <defs>
                  <linearGradient id="goldGradient" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#D4AF37" stopOpacity={0.4}/>
                    <stop offset="95%" stopColor="#D4AF37" stopOpacity={0}/>
                  </linearGradient>
                  <linearGradient id="emeraldGradient" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#10B981" stopOpacity={0.3}/>
                    <stop offset="95%" stopColor="#10B981" stopOpacity={0}/>
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" stroke="#1B4D3E" vertical={false} />
                <XAxis dataKey="month" stroke="#A0B2A6" fontSize={11} tickLine={false} />
                <YAxis stroke="#A0B2A6" fontSize={11} tickLine={false} axisLine={false} tickFormatter={(v) => `${v / 1000}k`} />
                <Tooltip 
                  contentStyle={{ backgroundColor: '#0D2818', borderColor: '#1B4D3E', borderRadius: '12px', fontSize: '12px' }}
                  itemStyle={{ color: '#F4F6F5' }}
                />
                <Area type="monotone" dataKey="escrowFees" stroke="#D4AF37" strokeWidth={2.5} fillOpacity={1} fill="url(#goldGradient)" name="رسوم الوساطة" />
                <Area type="monotone" dataKey="contracts" stroke="#10B981" strokeWidth={2} fillOpacity={1} fill="url(#emeraldGradient)" name="العقود والنماذج" />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Service Distribution Pie Chart (1 col) */}
        <div className="oqoody-card p-6 flex flex-col justify-between">
          <div>
            <h3 className="text-base font-bold text-oqoody-textLight mb-1">
              توزيع حجم العمليات والخدمات
            </h3>
            <p className="text-xs text-oqoody-textMuted mb-4">
              النسب المئوية لقطاعات منصة عقودي التشغيلية
            </p>
          </div>

          <div className="h-52 relative flex items-center justify-center">
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie
                  data={stats?.serviceDistribution || []}
                  cx="50%"
                  cy="50%"
                  innerRadius={60}
                  outerRadius={85}
                  paddingAngle={5}
                  dataKey="value"
                >
                  {(stats?.serviceDistribution || []).map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={entry.color} stroke="#0D2818" strokeWidth={2} />
                  ))}
                </Pie>
                <Tooltip 
                  contentStyle={{ backgroundColor: '#0D2818', borderColor: '#1B4D3E', borderRadius: '12px', fontSize: '12px' }}
                />
              </PieChart>
            </ResponsiveContainer>
            <div className="absolute text-center pointer-events-none">
              <span className="text-2xl font-black text-oqoody-textLight">100%</span>
              <span className="block text-[10px] text-oqoody-textMuted">نشاط المنصة</span>
            </div>
          </div>

          <div className="space-y-2 mt-4">
            {(stats?.serviceDistribution || []).map((s, i) => (
              <div key={i} className="flex items-center justify-between text-xs py-1 px-2 rounded-lg bg-oqoody-dark/50">
                <span className="flex items-center gap-2 text-oqoody-textMuted">
                  <span className="w-2.5 h-2.5 rounded-full" style={{ backgroundColor: s.color }} />
                  {s.name}
                </span>
                <span className="font-bold text-oqoody-textLight">{s.value}%</span>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Live Urgent Alerts & Fast Review Center */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Pending Lawyers Alert */}
        <div className="oqoody-card p-6 border-oqoody-warning/40">
          <div className="flex items-center justify-between pb-4 border-b border-oqoody-border mb-4">
            <div className="flex items-center gap-2.5">
              <div className="p-2 rounded-xl bg-oqoody-warning/10 text-oqoody-warning">
                <AlertTriangle className="w-5 h-5" />
              </div>
              <div>
                <h4 className="text-sm font-bold text-oqoody-textLight">طلبات اعتماد المحامين العاجلة</h4>
                <p className="text-xs text-oqoody-textMuted">تتطلب التحقق من القيد بجدول المحامين بالنقابة</p>
              </div>
            </div>
            <Link 
              to="/lawyers" 
              className="text-xs font-bold text-oqoody-gold hover:underline flex items-center gap-1"
            >
              <span>عرض الدليل</span>
              <ChevronLeft className="w-4 h-4" />
            </Link>
          </div>

          <div className="space-y-3">
            {(stats?.urgentAlerts?.pendingLawyers || []).length === 0 ? (
              <div className="text-center py-8 text-xs text-oqoody-textMuted">
                لا توجد طلبات اعتماد معلقة حالياً ✅
              </div>
            ) : (
              (stats?.urgentAlerts?.pendingLawyers || []).map((l) => (
                <div key={l._id} className="p-3.5 rounded-xl bg-oqoody-dark/80 border border-oqoody-border flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-full bg-oqoody-card border border-oqoody-gold/40 flex items-center justify-center text-oqoody-gold font-bold">
                      {l.userId?.fullName?.charAt(0) || 'م'}
                    </div>
                    <div>
                      <div className="text-sm font-bold text-oqoody-textLight">{l.userId?.fullName}</div>
                      <div className="text-xs text-oqoody-textMuted flex items-center gap-2">
                        <span>رقم القيد: {l.barNumber}</span>
                        <span>•</span>
                        <span className="text-oqoody-gold">درجة: {l.degree}</span>
                      </div>
                    </div>
                  </div>
                  <Link
                    to="/lawyers"
                    className="px-3 py-1.5 rounded-lg bg-oqoody-gold hover:bg-oqoody-goldHover text-oqoody-bg text-xs font-bold transition-colors"
                  >
                    فحص واعتماد
                  </Link>
                </div>
              ))
            )}
          </div>
        </div>

        {/* Urgent Disputes Alert */}
        <div className="oqoody-card p-6 border-oqoody-danger/40">
          <div className="flex items-center justify-between pb-4 border-b border-oqoody-border mb-4">
            <div className="flex items-center gap-2.5">
              <div className="p-2 rounded-xl bg-oqoody-danger/10 text-oqoody-danger">
                <Scale className="w-5 h-5 animate-pulse" />
              </div>
              <div>
                <h4 className="text-sm font-bold text-oqoody-textLight">نزاعات نشطة بغرفة التحكيم</h4>
                <p className="text-xs text-oqoody-textMuted">تتطلب تدقيق الأدلة وإصدار قرار تحكيمي ملزم</p>
              </div>
            </div>
            <Link 
              to="/disputes" 
              className="text-xs font-bold text-oqoody-gold hover:underline flex items-center gap-1"
            >
              <span>دخول الغرفة</span>
              <ChevronLeft className="w-4 h-4" />
            </Link>
          </div>

          <div className="space-y-3">
            {(stats?.urgentAlerts?.activeDisputes || []).length === 0 ? (
              <div className="text-center py-8 text-xs text-oqoody-textMuted">
                لا توجد نزاعات مفتوحة حالياً، كافة العمليات تسير بسلاسة ⚖️
              </div>
            ) : (
              (stats?.urgentAlerts?.activeDisputes || []).map((d) => (
                <div key={d._id} className="p-3.5 rounded-xl bg-oqoody-dark/80 border border-oqoody-border flex items-center justify-between">
                  <div className="overflow-hidden pr-1">
                    <div className="flex items-center gap-2 mb-1">
                      <span className="text-xs font-bold text-oqoody-danger bg-oqoody-danger/10 border border-oqoody-danger/30 px-2 py-0.5 rounded-md">
                        أولوية قصوى
                      </span>
                      <span className="text-xs font-semibold text-oqoody-textLight truncate">
                        {d.escrowId?.title || 'عقد وساطة رقمي'}
                      </span>
                    </div>
                    <p className="text-xs text-oqoody-textMuted truncate max-w-sm">
                      سبب النزاع: {d.reason}
                    </p>
                  </div>
                  <Link
                    to="/disputes"
                    className="px-3 py-1.5 rounded-lg bg-oqoody-danger hover:bg-red-600 text-white text-xs font-bold transition-colors whitespace-nowrap mr-3"
                  >
                    فصل النزاع
                  </Link>
                </div>
              ))
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

