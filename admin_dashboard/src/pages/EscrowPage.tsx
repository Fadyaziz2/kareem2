import React, { useState, useEffect } from 'react';
import { 
  ShieldCheck, 
  Search, 
  Filter, 
  Lock, 
  Unlock, 
  CheckCircle, 
  AlertTriangle, 
  Clock, 
  ExternalLink, 
  ChevronDown, 
  ChevronUp, 
  Coins, 
  FileText,
  PauseCircle,
  PlayCircle
} from 'lucide-react';
import { adminApi } from '../services/api';
import { Escrow, Milestone, MilestoneStatus, EscrowStatus } from '../types';

export const EscrowPage: React.FC = () => {
  const [escrows, setEscrows] = useState<Escrow[]>([]);
  const [filterStatus, setFilterStatus] = useState<string>('all');
  const [searchQuery, setSearchQuery] = useState<string>('');
  const [isLoading, setIsLoading] = useState<boolean>(true);

  // Selected Escrow for Drawer / Details
  const [activeEscrowDrawer, setActiveEscrowDrawer] = useState<Escrow | null>(null);
  const [toast, setToast] = useState<string | null>(null);

  useEffect(() => {
    loadEscrows();
  }, []);

  const loadEscrows = async () => {
    setIsLoading(true);
    try {
      const data = await adminApi.getEscrows();
      setEscrows(data);
    } catch (err) {
      console.error(err);
    } finally {
      setIsLoading(false);
    }
  };

  const handleForceReleaseMilestone = async (escrowId: string, milestoneId: string) => {
    if (!window.confirm('تحذير إداري: هل أنت متأكد من فرض تحرير وإطلاق هذه الدفعة المالية من حساب الضمان إلى الطرف الثاني؟')) {
      return;
    }

    try {
      const updated = await adminApi.releaseMilestone(escrowId, milestoneId);
      setEscrows(escrows.map(e => e._id === escrowId ? updated : e));
      if (activeEscrowDrawer && activeEscrowDrawer._id === escrowId) {
        setActiveEscrowDrawer(updated);
      }
      showToast('تم تحرير الدفعة ونقل المبلغ لمحفظة المنفذ بنجاح');
    } catch {
      showToast('فشل تحرير الدفعة المالية');
    }
  };

  const handleToggleFreeze = async (escrowId: string) => {
    try {
      const updated = await adminApi.toggleFreezeEscrow(escrowId);
      setEscrows(escrows.map(e => e._id === escrowId ? updated : e));
      if (activeEscrowDrawer && activeEscrowDrawer._id === escrowId) {
        setActiveEscrowDrawer(updated);
      }
      showToast(updated.status === 'frozen' ? 'تم تجميد العملية بالكامل إدارياً' : 'تم استئناف العملية وفك التجميد');
    } catch {
      showToast('تعذر تغيير حالة تجميد العملية');
    }
  };

  const showToast = (msg: string) => {
    setToast(msg);
    setTimeout(() => setToast(null), 3000);
  };

  const getStatusBadge = (status: EscrowStatus) => {
    switch (status) {
      case 'active':
        return (
          <span className="px-2.5 py-1 rounded-full text-xs font-bold bg-oqoody-gold/10 text-oqoody-gold border border-oqoody-gold/30 flex items-center gap-1">
            <Lock className="w-3.5 h-3.5" />
            <span>نشط (الضمان محتجز)</span>
          </span>
        );
      case 'completed':
        return (
          <span className="px-2.5 py-1 rounded-full text-xs font-bold bg-oqoody-success/10 text-oqoody-success border border-oqoody-success/30 flex items-center gap-1">
            <CheckCircle className="w-3.5 h-3.5" />
            <span>مكتمل ومحرر بالكامل</span>
          </span>
        );
      case 'disputed':
        return (
          <span className="px-2.5 py-1 rounded-full text-xs font-bold bg-oqoody-danger/10 text-oqoody-danger border border-oqoody-danger/30 flex items-center gap-1 animate-pulse">
            <AlertTriangle className="w-3.5 h-3.5" />
            <span>متنازع عليه (مجمّد للتحكيم)</span>
          </span>
        );
      case 'frozen':
        return (
          <span className="px-2.5 py-1 rounded-full text-xs font-bold bg-red-900/30 text-red-300 border border-red-500/40 flex items-center gap-1">
            <PauseCircle className="w-3.5 h-3.5" />
            <span>مجمّد بقرار إداري</span>
          </span>
        );
      default:
        return <span className="text-xs text-oqoody-textMuted">{status}</span>;
    }
  };

  const getMilestoneBadge = (status: MilestoneStatus) => {
    switch (status) {
      case 'released':
        return <span className="bg-oqoody-success/20 text-oqoody-success border border-oqoody-success/30 px-2 py-0.5 rounded text-[11px] font-bold">تم التحرير ✓</span>;
      case 'held_in_escrow':
        return <span className="bg-oqoody-gold/20 text-oqoody-gold border border-oqoody-gold/30 px-2 py-0.5 rounded text-[11px] font-bold">محتجزة بالخزينة 🔒</span>;
      case 'submitted':
        return <span className="bg-blue-500/20 text-blue-400 border border-blue-500/30 px-2 py-0.5 rounded text-[11px] font-bold">تم التسليم للمراجعة 📤</span>;
      case 'disputed':
        return <span className="bg-oqoody-danger/20 text-oqoody-danger border border-oqoody-danger/30 px-2 py-0.5 rounded text-[11px] font-bold animate-pulse">نزاع مفتوح ⚠️</span>;
      default:
        return <span className="bg-oqoody-card text-oqoody-textMuted border border-oqoody-border px-2 py-0.5 rounded text-[11px]">بانتظار الإيداع</span>;
    }
  };

  const filteredEscrows = escrows.filter(e => {
    const matchStatus = filterStatus === 'all' || e.status === filterStatus;
    const matchQuery = e.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
                       (e.partyA?.fullName && e.partyA.fullName.toLowerCase().includes(searchQuery.toLowerCase())) ||
                       (e.partyB?.fullName && e.partyB.fullName.toLowerCase().includes(searchQuery.toLowerCase()));
    return matchStatus && matchQuery;
  });

  return (
    <div className="space-y-6">
      {toast && (
        <div className="fixed bottom-6 left-6 z-50 bg-oqoody-dark border border-oqoody-gold/60 text-oqoody-gold px-4 py-3 rounded-xl shadow-2xl flex items-center gap-2 text-sm animate-in fade-in slide-in-from-bottom-2">
          <ShieldCheck className="w-5 h-5 text-oqoody-gold" />
          <span>{toast}</span>
        </div>
      )}

      {/* Top Filter and Search Bar */}
      <div className="flex flex-col sm:flex-row items-stretch sm:items-center justify-between gap-4">
        <div className="relative flex-1 max-w-md">
          <Search className="w-4 h-4 text-oqoody-textMuted absolute right-3.5 top-3.5" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="البحث باسم العقد، الطرف الأول، أو الطرف الثاني..."
            className="w-full bg-oqoody-card border border-oqoody-border rounded-xl pr-10 pl-4 py-2.5 text-xs text-oqoody-textLight focus:outline-none focus:border-oqoody-gold transition-colors"
          />
        </div>

        {/* Status Filters */}
        <div className="flex items-center gap-2 overflow-x-auto pb-1">
          <Filter className="w-4 h-4 text-oqoody-gold flex-shrink-0" />
          {[
            { id: 'all', label: 'كافة الصفقات' },
            { id: 'active', label: 'نشطة ومحتجزة' },
            { id: 'disputed', label: 'تحت النزاع ⚠️' },
            { id: 'completed', label: 'مكتملة ومحررة' },
            { id: 'frozen', label: 'مجمّدة' }
          ].map((tab) => (
            <button
              key={tab.id}
              onClick={() => setFilterStatus(tab.id)}
              className={`px-3 py-1.5 rounded-xl text-xs font-semibold whitespace-nowrap transition-all ${
                filterStatus === tab.id 
                  ? 'bg-oqoody-gold text-oqoody-bg shadow-gold-glow' 
                  : 'bg-oqoody-card text-oqoody-textMuted hover:text-oqoody-textLight border border-oqoody-border'
              }`}
            >
              {tab.label}
            </button>
          ))}
        </div>
      </div>

      {/* Escrow Operations Grid */}
      <div className="space-y-4">
        {isLoading ? (
          <div className="text-center py-16 text-oqoody-textMuted">
            <span className="inline-block w-6 h-6 border-2 border-oqoody-gold border-t-transparent rounded-full animate-spin mb-2" />
            <div>جاري جلب عمليات وساطة الضمان...</div>
          </div>
        ) : filteredEscrows.length === 0 ? (
          <div className="oqoody-card p-12 text-center text-xs text-oqoody-textMuted">
            لا توجد عمليات وساطة مطابقة للتصفية الحالية
          </div>
        ) : (
          filteredEscrows.map((escrow) => (
            <div
              key={escrow._id}
              className="oqoody-card p-6 border-oqoody-border hover:border-oqoody-gold/40 transition-all duration-200"
            >
              {/* Header Info */}
              <div className="flex flex-col lg:flex-row items-start lg:items-center justify-between gap-4 mb-4 pb-4 border-b border-oqoody-border/60">
                <div>
                  <div className="flex items-center gap-3 mb-1.5">
                    {getStatusBadge(escrow.status)}
                    <span className="text-xs text-oqoody-textMuted">
                      رقم العملية: <span className="font-mono text-oqoody-textLight">#{escrow._id.slice(-6)}</span>
                    </span>
                  </div>
                  <h3 className="text-base font-bold text-oqoody-textLight">
                    {escrow.title}
                  </h3>
                  <p className="text-xs text-oqoody-textMuted mt-0.5">{escrow.description}</p>
                </div>

                <div className="text-right flex items-center lg:flex-col lg:items-end justify-between w-full lg:w-auto">
                  <span className="text-xs text-oqoody-textMuted">إجمالي قيمة الصفقة الضامنة</span>
                  <span className="text-xl font-black text-oqoody-gold">
                    {escrow.totalAmount.toLocaleString()} ج.م
                  </span>
                </div>
              </div>

              {/* Parties and Progress */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6 text-xs">
                {/* Party A */}
                <div className="bg-oqoody-dark/70 p-3.5 rounded-xl border border-oqoody-border">
                  <span className="text-[11px] text-oqoody-gold font-bold block mb-1">الطرف الأول (المشتري / صاحب العمل):</span>
                  <div className="font-bold text-oqoody-textLight text-sm">{escrow.partyA?.fullName || 'غير محدد'}</div>
                  <div className="text-oqoody-textMuted text-[11px] mt-0.5">{escrow.partyA?.email} • {escrow.partyA?.phone}</div>
                </div>

                {/* Party B */}
                <div className="bg-oqoody-dark/70 p-3.5 rounded-xl border border-oqoody-border">
                  <span className="text-[11px] text-oqoody-success font-bold block mb-1">الطرف الثاني (المورد / المنفذ):</span>
                  <div className="font-bold text-oqoody-textLight text-sm">{escrow.partyB?.fullName || 'غير محدد'}</div>
                  <div className="text-oqoody-textMuted text-[11px] mt-0.5">{escrow.partyB?.email} • {escrow.partyB?.phone}</div>
                </div>
              </div>

              {/* Milestones Compact Overview */}
              <div className="mb-4">
                <div className="flex items-center justify-between text-xs font-semibold text-oqoody-textMuted mb-2">
                  <span>مراحل الدفع والإنجاز ({escrow.milestones?.length || 0} مراحل)</span>
                  <span className="text-oqoody-gold">
                    المحرر: {escrow.milestones?.filter(m => m.status === 'released').length} / {escrow.milestones?.length}
                  </span>
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-3 gap-2">
                  {(escrow.milestones || []).map((ms, idx) => (
                    <div key={ms._id || idx} className="p-2.5 rounded-lg bg-oqoody-dark/50 border border-oqoody-border/80 text-xs">
                      <div className="flex items-center justify-between mb-1">
                        <span className="font-bold text-oqoody-textLight truncate">{ms.title}</span>
                        {getMilestoneBadge(ms.status)}
                      </div>
                      <div className="flex items-center justify-between text-[11px] text-oqoody-textMuted">
                        <span>نسبة {ms.percentage}%</span>
                        <span className="font-bold text-emerald-400">{ms.amount?.toLocaleString()} ج.م</span>
                      </div>
                    </div>
                  ))}
                </div>
              </div>

              {/* Action Buttons Row */}
              <div className="flex flex-wrap items-center justify-between gap-3 pt-3 border-t border-oqoody-border/60">
                <div className="flex items-center gap-2">
                  {escrow.contractDocument && (
                    <a
                      href={escrow.contractDocument}
                      target="_blank"
                      rel="noreferrer"
                      className="px-3 py-1.5 rounded-lg bg-oqoody-dark hover:bg-oqoody-card border border-oqoody-border text-oqoody-textLight text-xs flex items-center gap-1.5 transition-colors"
                    >
                      <FileText className="w-3.5 h-3.5 text-oqoody-gold" />
                      <span>وثيقة العقد الموقعة</span>
                      <ExternalLink className="w-3 h-3 text-oqoody-textMuted" />
                    </a>
                  )}

                  <button
                    onClick={() => handleToggleFreeze(escrow._id)}
                    className={`px-3 py-1.5 rounded-lg text-xs font-bold border transition-colors flex items-center gap-1.5 ${
                      escrow.status === 'frozen'
                        ? 'bg-emerald-500/10 text-emerald-400 border-emerald-500/30 hover:bg-emerald-500/20'
                        : 'bg-oqoody-danger/10 text-oqoody-danger border-oqoody-danger/30 hover:bg-oqoody-danger/20'
                    }`}
                  >
                    {escrow.status === 'frozen' ? <PlayCircle className="w-3.5 h-3.5" /> : <PauseCircle className="w-3.5 h-3.5" />}
                    <span>{escrow.status === 'frozen' ? 'إلغاء التجميد واستئناف' : 'تجميد العملية إدارياً'}</span>
                  </button>
                </div>

                <button
                  onClick={() => setActiveEscrowDrawer(escrow)}
                  className="px-4 py-2 rounded-xl bg-oqoody-gold hover:bg-oqoody-goldHover text-oqoody-bg text-xs font-bold shadow-gold-glow transition-all flex items-center gap-1.5"
                >
                  <Coins className="w-3.5 h-3.5" />
                  <span>إدارة وتحرير الدفعات (Milestones)</span>
                </button>
              </div>
            </div>
          ))
        )}
      </div>

      {/* Milestones Drawer / Modal */}
      {activeEscrowDrawer && (
        <div className="fixed inset-0 z-50 bg-black/85 backdrop-blur-md flex items-center justify-center p-4">
          <div className="bg-oqoody-dark border border-oqoody-border rounded-3xl w-full max-w-2xl max-h-[90vh] overflow-y-auto shadow-2xl p-6 sm:p-8">
            <div className="flex items-start justify-between pb-4 border-b border-oqoody-border mb-6">
              <div>
                <h3 className="text-base font-bold text-oqoody-textLight flex items-center gap-2">
                  <ShieldCheck className="w-5 h-5 text-oqoody-gold" />
                  <span>إدارة دفعات الضمان: {activeEscrowDrawer.title}</span>
                </h3>
                <p className="text-xs text-oqoody-textMuted mt-1">
                  إجمالي المبلغ: <span className="text-oqoody-gold font-bold">{activeEscrowDrawer.totalAmount.toLocaleString()} ج.م</span>
                </p>
              </div>
              <button onClick={() => setActiveEscrowDrawer(null)} className="text-oqoody-textMuted hover:text-white p-1">
                ✕
              </button>
            </div>

            <div className="space-y-4 mb-6">
              {activeEscrowDrawer.milestones?.map((m, idx) => (
                <div
                  key={m._id || idx}
                  className="p-4 rounded-2xl bg-oqoody-card border border-oqoody-border space-y-3"
                >
                  <div className="flex items-start justify-between gap-3">
                    <div>
                      <div className="flex items-center gap-2 mb-1">
                        <span className="w-5 h-5 rounded-full bg-oqoody-dark text-oqoody-gold text-xs font-bold flex items-center justify-center">
                          {idx + 1}
                        </span>
                        <h4 className="font-bold text-sm text-oqoody-textLight">{m.title}</h4>
                      </div>
                      <p className="text-xs text-oqoody-textMuted">{m.terms}</p>
                    </div>
                    <div className="text-right flex-shrink-0">
                      <div className="font-black text-sm text-oqoody-gold">{m.amount?.toLocaleString()} ج.م</div>
                      <div className="text-[10px] text-oqoody-textMuted">({m.percentage}% من الإجمالي)</div>
                    </div>
                  </div>

                  {m.submissionNotes && (
                    <div className="bg-oqoody-dark/70 p-2.5 rounded-lg text-xs text-oqoody-textLight border border-oqoody-border/50">
                      <span className="text-oqoody-gold font-bold">ملاحظات التسليم: </span>
                      <span>{m.submissionNotes}</span>
                    </div>
                  )}

                  <div className="flex items-center justify-between pt-2 border-t border-oqoody-border/50">
                    <div className="flex items-center gap-2">
                      <span className="text-xs text-oqoody-textMuted">حالة الدفعة:</span>
                      {getMilestoneBadge(m.status)}
                    </div>

                    {m.status !== 'released' && (
                      <button
                        onClick={() => handleForceReleaseMilestone(activeEscrowDrawer._id, m._id)}
                        className="px-3 py-1.5 rounded-lg bg-oqoody-gold hover:bg-oqoody-goldHover text-oqoody-bg font-bold text-xs shadow-gold-glow transition-all flex items-center gap-1"
                      >
                        <Unlock className="w-3.5 h-3.5" />
                        <span>تحرير إداري فوري للمبلغ</span>
                      </button>
                    )}
                  </div>
                </div>
              ))}
            </div>

            <div className="flex justify-end">
              <button
                onClick={() => setActiveEscrowDrawer(null)}
                className="px-6 py-2.5 rounded-xl text-xs font-bold bg-oqoody-card hover:bg-oqoody-border text-oqoody-textLight"
              >
                إغلاق النافذة
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

