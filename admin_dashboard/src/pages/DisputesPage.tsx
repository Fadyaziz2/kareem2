import React, { useState, useEffect } from 'react';
import { 
  Scale, 
  Search, 
  AlertTriangle, 
  CheckCircle, 
  FileText, 
  ExternalLink, 
  Coins, 
  Gavel, 
  ShieldCheck, 
  Calendar,
  Layers,
  ArrowRightLeft,
  Percent
} from 'lucide-react';
import { adminApi } from '../services/api';
import { Dispute, ResolutionType } from '../types';
import { useAuth } from '../context/AuthContext';

export const DisputesPage: React.FC = () => {
  const { user } = useAuth();
  const [disputes, setDisputes] = useState<Dispute[]>([]);
  const [selectedDispute, setSelectedDispute] = useState<Dispute | null>(null);
  const [isLoading, setIsLoading] = useState<boolean>(true);

  // Executive Ruling State
  const [resolutionType, setResolutionType] = useState<ResolutionType>('full_refund_partyA');
  const [splitPartyA, setSplitPartyA] = useState<number>(0);
  const [splitPartyB, setSplitPartyB] = useState<number>(0);
  const [arbitrationNotes, setArbitrationNotes] = useState<string>('');
  const [isSubmitting, setIsSubmitting] = useState<boolean>(false);
  const [toast, setToast] = useState<string | null>(null);

  useEffect(() => {
    loadDisputes();
  }, []);

  const loadDisputes = async () => {
    setIsLoading(true);
    try {
      const data = await adminApi.getDisputes();
      setDisputes(data);
      if (data.length > 0) {
        selectDisputeItem(data[0]);
      }
    } catch (err) {
      console.error(err);
    } finally {
      setIsLoading(false);
    }
  };

  const selectDisputeItem = (dispute: Dispute) => {
    setSelectedDispute(dispute);
    const amount = getMilestoneAmount(dispute);
    setSplitPartyA(Math.round(amount / 2));
    setSplitPartyB(amount - Math.round(amount / 2));
    setArbitrationNotes('');
  };

  const getMilestoneAmount = (dispute: Dispute): number => {
    if (!dispute?.escrowId?.milestones) return 47500;
    const ms = dispute.escrowId.milestones.find(m => m._id === dispute.milestoneId);
    return ms?.amount || 47500;
  };

  const handleCustomSplitChange = (valPartyA: number) => {
    if (!selectedDispute) return;
    const total = getMilestoneAmount(selectedDispute);
    const safeA = Math.max(0, Math.min(total, valPartyA));
    setSplitPartyA(safeA);
    setSplitPartyB(total - safeA);
  };

  const handleExecuteRuling = async () => {
    if (!selectedDispute) return;
    if (!arbitrationNotes.trim()) {
      showToast('يرجى كتابة أسباب ومنطوق الحكم التحكيمي في حقل الملاحظات');
      return;
    }

    setIsSubmitting(true);
    try {
      const updated = await adminApi.resolveDispute(selectedDispute._id, {
        resolutionType,
        splitPartyA: resolutionType === 'custom_split' ? splitPartyA : undefined,
        splitPartyB: resolutionType === 'custom_split' ? splitPartyB : undefined,
        notes: arbitrationNotes,
        decidedBy: user?._id
      });

      setDisputes(disputes.map(d => d._id === selectedDispute._id ? updated : d));
      setSelectedDispute(updated);
      showToast('تم إصدار الحكم التحكيمي النهائي وتعديل أرصدة الضمان والمحافظ بنجاح ⚖️');
    } catch {
      showToast('فشل تنفيذ الحكم التحكيمي');
    } finally {
      setIsSubmitting(false);
    }
  };

  const showToast = (msg: string) => {
    setToast(msg);
    setTimeout(() => setToast(null), 3000);
  };

  const getPriorityBadge = (priority: string) => {
    switch (priority) {
      case 'urgent':
        return <span className="bg-oqoody-danger/20 text-oqoody-danger border border-oqoody-danger/40 px-2.5 py-0.5 rounded-full text-xs font-bold animate-pulse">عاجل جداً ⚡</span>;
      case 'high':
        return <span className="bg-oqoody-warning/20 text-oqoody-warning border border-oqoody-warning/40 px-2.5 py-0.5 rounded-full text-xs font-bold">أولوية مرتفعة</span>;
      default:
        return <span className="bg-oqoody-card text-oqoody-textMuted border border-oqoody-border px-2.5 py-0.5 rounded-full text-xs">عادي</span>;
    }
  };

  return (
    <div className="space-y-6">
      {toast && (
        <div className="fixed bottom-6 left-6 z-50 bg-oqoody-dark border border-oqoody-gold/60 text-oqoody-gold px-4 py-3 rounded-xl shadow-2xl flex items-center gap-2 text-sm animate-in fade-in slide-in-from-bottom-2">
          <Gavel className="w-5 h-5 text-oqoody-gold" />
          <span>{toast}</span>
        </div>
      )}

      {/* Top Banner */}
      <div className="oqoody-card p-6 border-oqoody-gold/40 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
        <div className="flex items-center gap-3">
          <div className="w-12 h-12 rounded-2xl bg-oqoody-gold/10 border border-oqoody-gold/40 flex items-center justify-center text-oqoody-gold flex-shrink-0">
            <Scale className="w-7 h-7" />
          </div>
          <div>
            <h2 className="text-base font-bold text-oqoody-textLight">
              غرفة التحكيم القانوني وفض النزاعات المالية
            </h2>
            <p className="text-xs text-oqoody-textMuted mt-0.5">
              الفصل في خلافات تسليم الدفعات ومطابقة المواصفات مع سلطة إصدار قرارات ملزمة للأطراف
            </p>
          </div>
        </div>

        <div className="flex items-center gap-2">
          <span className="text-xs text-oqoody-textMuted">النزاعات المفتوحة:</span>
          <span className="px-2.5 py-0.5 rounded-full bg-oqoody-danger text-white text-xs font-bold">
            {disputes.filter(d => d.status !== 'resolved').length} قضايا
          </span>
        </div>
      </div>

      {/* Split Screen Arbitration Room */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 min-h-[650px]">
        {/* Right Column: Disputes Queue (4 cols in RTL) */}
        <div className="lg:col-span-4 space-y-3">
          <div className="text-xs font-bold text-oqoody-textMuted px-1 uppercase tracking-wider flex items-center justify-between">
            <span>جدول قضايا التحكيم المعروضة</span>
            <span className="text-oqoody-gold font-normal">{disputes.length} إجمالي</span>
          </div>

          <div className="space-y-2.5 overflow-y-auto max-h-[700px]">
            {isLoading ? (
              <div className="text-center py-12 text-xs text-oqoody-textMuted">
                جاري جلب ملفات القضايا...
              </div>
            ) : disputes.length === 0 ? (
              <div className="oqoody-card p-8 text-center text-xs text-oqoody-textMuted">
                لا توجد نزاعات مفتوحة حالياً ✅
              </div>
            ) : (
              disputes.map((d) => {
                const isSelected = selectedDispute?._id === d._id;
                const isResolved = d.status === 'resolved';

                return (
                  <div
                    key={d._id}
                    onClick={() => selectDisputeItem(d)}
                    className={`p-4 rounded-2xl border transition-all cursor-pointer ${
                      isSelected 
                        ? 'bg-oqoody-card border-oqoody-gold shadow-gold-glow' 
                        : 'bg-oqoody-dark/70 border-oqoody-border hover:border-oqoody-gold/40'
                    }`}
                  >
                    <div className="flex items-center justify-between mb-2">
                      {getPriorityBadge(d.priority)}
                      {isResolved ? (
                        <span className="text-[11px] font-bold text-oqoody-success flex items-center gap-1">
                          <CheckCircle className="w-3 h-3" /> تم الفصل
                        </span>
                      ) : (
                        <span className="text-[11px] text-oqoody-danger font-bold animate-pulse">
                          مفتوح للمداولة
                        </span>
                      )}
                    </div>

                    <h4 className="font-bold text-xs text-oqoody-textLight line-clamp-1 mb-1">
                      {d.escrowId?.title || 'عقد وساطة تجاري'}
                    </h4>

                    <p className="text-[11px] text-oqoody-textMuted line-clamp-2 leading-relaxed mb-3">
                      {d.reason}
                    </p>

                    <div className="flex items-center justify-between text-[11px] pt-2 border-t border-oqoody-border/50 text-oqoody-textMuted">
                      <span>الشاكي: {d.raisedBy?.fullName?.split(' ')[0] || 'الطرف الأول'}</span>
                      <span className="font-bold text-emerald-400">
                        {getMilestoneAmount(d).toLocaleString()} ج.م
                      </span>
                    </div>
                  </div>
                );
              })
            )}
          </div>
        </div>

        {/* Main Column: Arbitration Chamber (8 cols) */}
        <div className="lg:col-span-8">
          {selectedDispute ? (
            <div className="oqoody-card p-6 sm:p-8 space-y-6">
              {/* Dispute Header */}
              <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3 pb-4 border-b border-oqoody-border">
                <div>
                  <div className="flex items-center gap-2 mb-1">
                    <span className="text-xs font-mono font-bold text-oqoody-gold">قضية #{selectedDispute._id.slice(-6)}</span>
                    {getPriorityBadge(selectedDispute.priority)}
                  </div>
                  <h3 className="text-lg font-bold text-oqoody-textLight">
                    {selectedDispute.escrowId?.title}
                  </h3>
                </div>

                <div className="text-right">
                  <span className="text-xs text-oqoody-textMuted block">المبلغ المتنازع عليه</span>
                  <span className="text-2xl font-black text-oqoody-gold">
                    {getMilestoneAmount(selectedDispute).toLocaleString()} ج.م
                  </span>
                </div>
              </div>

              {/* Dispute Facts & Reason */}
              <div className="space-y-2">
                <label className="text-xs font-bold text-oqoody-gold block">
                  سبب النزاع والطلب المقدم من الشاكي ({selectedDispute.raisedBy?.fullName}):
                </label>
                <div className="p-4 rounded-xl bg-oqoody-dark/90 border border-oqoody-border text-xs leading-relaxed text-oqoody-textLight">
                  <div className="font-bold mb-1.5 text-oqoody-danger">« {selectedDispute.reason} »</div>
                  <p className="text-oqoody-textMuted leading-relaxed">{selectedDispute.details}</p>
                </div>
              </div>

              {/* Evidence Attachments */}
              <div>
                <label className="text-xs font-bold text-oqoody-textMuted block mb-2">
                  الأدلة والمستندات والتقارير المرفقة بالفحص المعملي:
                </label>
                <div className="grid grid-cols-2 sm:grid-cols-3 gap-3">
                  {(selectedDispute.evidenceFiles || []).map((file, i) => (
                    <a
                      key={i}
                      href={file}
                      target="_blank"
                      rel="noreferrer"
                      className="group rounded-xl overflow-hidden border border-oqoody-border bg-oqoody-dark relative aspect-video flex items-center justify-center"
                    >
                      <img src={file} alt="مستند الدليل" className="w-full h-full object-cover group-hover:scale-105 transition-transform" />
                      <div className="absolute inset-0 bg-black/50 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center gap-1 text-oqoody-gold text-xs font-bold">
                        <ExternalLink className="w-3.5 h-3.5" />
                        <span>فحص المستند</span>
                      </div>
                    </a>
                  ))}
                </div>
              </div>

              {/* Parties Comparison in Case */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 text-xs">
                <div className="p-3.5 rounded-xl bg-oqoody-dark/60 border border-oqoody-border">
                  <span className="text-oqoody-gold font-bold block mb-1">الطرف الأول (المشتري):</span>
                  <div className="font-bold text-oqoody-textLight">{selectedDispute.escrowId?.partyA?.fullName || 'أحمد خالد'}</div>
                  <div className="text-oqoody-textMuted text-[11px]">المطالبة: استرداد مبلغ الدفعة بالكامل لوجود مخالفة مواصفات</div>
                </div>

                <div className="p-3.5 rounded-xl bg-oqoody-dark/60 border border-oqoody-border">
                  <span className="text-oqoody-success font-bold block mb-1">الطرف الثاني (المورد):</span>
                  <div className="font-bold text-oqoody-textLight">{selectedDispute.escrowId?.partyB?.fullName || 'شركة النيل'}</div>
                  <div className="text-oqoody-textMuted text-[11px]">الدفاع: تم شحن البضائع سليمة والضرر ناتج عن سوء التخزين</div>
                </div>
              </div>

              {/* Executive Ruling Decision Box */}
              {selectedDispute.status === 'resolved' ? (
                <div className="p-5 rounded-2xl bg-oqoody-success/10 border border-oqoody-success/40 space-y-2">
                  <div className="flex items-center gap-2 text-oqoody-success font-bold text-sm">
                    <CheckCircle className="w-5 h-5" />
                    <span>تم صدور الحكم التحكيمي البات في هذه القضية</span>
                  </div>
                  <p className="text-xs text-oqoody-textLight leading-relaxed">
                    منطوق الحكم: {selectedDispute.arbitrationVerdict?.notes}
                  </p>
                  <div className="text-xs text-oqoody-textMuted pt-2">
                    المبالغ المنفذة: للطرف الأول {selectedDispute.arbitrationVerdict?.splitPartyA?.toLocaleString()} ج.م • للطرف الثاني {selectedDispute.arbitrationVerdict?.splitPartyB?.toLocaleString()} ج.م
                  </div>
                </div>
              ) : (
                <div className="bg-oqoody-dark/95 p-5 rounded-2xl border-2 border-oqoody-gold/40 space-y-4">
                  <h4 className="text-sm font-bold text-oqoody-gold flex items-center gap-2">
                    <Gavel className="w-4 h-4" />
                    <span>منصة إصدار الحكم التحكيمي التنفيذي الملزم</span>
                  </h4>

                  {/* 3 Executive Ruling Radio Options */}
                  <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                    <button
                      type="button"
                      onClick={() => setResolutionType('full_refund_partyA')}
                      className={`p-3 rounded-xl border text-right transition-all ${
                        resolutionType === 'full_refund_partyA'
                          ? 'bg-oqoody-card border-oqoody-gold text-oqoody-gold shadow-md'
                          : 'bg-oqoody-dark border-oqoody-border text-oqoody-textMuted hover:border-oqoody-gold/40'
                      }`}
                    >
                      <div className="font-bold text-xs mb-1">استرداد 100% للطرف الأول</div>
                      <div className="text-[10px] leading-tight">إرجاع كامل المبلغ للمشتري</div>
                    </button>

                    <button
                      type="button"
                      onClick={() => setResolutionType('full_release_partyB')}
                      className={`p-3 rounded-xl border text-right transition-all ${
                        resolutionType === 'full_release_partyB'
                          ? 'bg-oqoody-card border-oqoody-gold text-oqoody-gold shadow-md'
                          : 'bg-oqoody-dark border-oqoody-border text-oqoody-textMuted hover:border-oqoody-gold/40'
                      }`}
                    >
                      <div className="font-bold text-xs mb-1">تحرير 100% للطرف الثاني</div>
                      <div className="text-[10px] leading-tight">إطلاق كامل الدفعة للمنفذ</div>
                    </button>

                    <button
                      type="button"
                      onClick={() => setResolutionType('custom_split')}
                      className={`p-3 rounded-xl border text-right transition-all ${
                        resolutionType === 'custom_split'
                          ? 'bg-oqoody-card border-oqoody-gold text-oqoody-gold shadow-md'
                          : 'bg-oqoody-dark border-oqoody-border text-oqoody-textMuted hover:border-oqoody-gold/40'
                      }`}
                    >
                      <div className="font-bold text-xs mb-1">تسوية وتقسيم مخصص</div>
                      <div className="text-[10px] leading-tight">توزيع نسبي بالتراضي أو الضرر</div>
                    </button>
                  </div>

                  {/* Custom Split Inputs */}
                  {resolutionType === 'custom_split' && (
                    <div className="p-4 rounded-xl bg-oqoody-card border border-oqoody-border space-y-3">
                      <div className="flex items-center justify-between text-xs">
                        <span className="font-bold text-oqoody-textLight">توزيع مبالغ التسوية بين الأطراف:</span>
                        <span className="text-oqoody-gold font-bold">الإجمالي: {getMilestoneAmount(selectedDispute).toLocaleString()} ج.م</span>
                      </div>

                      <div className="grid grid-cols-2 gap-4">
                        <div>
                          <label className="block text-[11px] text-oqoody-textMuted mb-1">مبلغ الطرف الأول (المشتري):</label>
                          <input
                            type="number"
                            value={splitPartyA}
                            onChange={(e) => handleCustomSplitChange(Number(e.target.value))}
                            className="w-full bg-oqoody-dark border border-oqoody-border rounded-xl px-3 py-2 text-xs font-bold text-oqoody-gold"
                          />
                        </div>
                        <div>
                          <label className="block text-[11px] text-oqoody-textMuted mb-1">مبلغ الطرف الثاني (المنفذ):</label>
                          <input
                            type="number"
                            readOnly
                            value={splitPartyB}
                            className="w-full bg-oqoody-dark/50 border border-oqoody-border rounded-xl px-3 py-2 text-xs font-bold text-emerald-400"
                          />
                        </div>
                      </div>
                    </div>
                  )}

                  {/* Arbitrator Legal Notes */}
                  <div>
                    <label className="block text-xs font-bold text-oqoody-textLight mb-1.5">
                      مذكرة ومنطوق الحكم التحكيمي وأسباب القرار *
                    </label>
                    <textarea
                      rows={3}
                      value={arbitrationNotes}
                      onChange={(e) => setArbitrationNotes(e.target.value)}
                      placeholder="استناداً إلى فحص وثيقة التعاقد رقم #8821 وما ثبت من فحص الأدلة المادية المقدمة، حكمت هيئة التحكيم بـ..."
                      className="w-full bg-oqoody-card border border-oqoody-border rounded-xl p-3 text-xs text-oqoody-textLight focus:outline-none focus:border-oqoody-gold leading-relaxed"
                    />
                  </div>

                  {/* Execute Button */}
                  <div className="flex justify-end pt-2">
                    <button
                      type="button"
                      disabled={isSubmitting}
                      onClick={handleExecuteRuling}
                      className="px-6 py-3 rounded-xl bg-oqoody-gold hover:bg-oqoody-goldHover text-oqoody-bg font-black text-xs shadow-gold-glow transition-all flex items-center gap-2"
                    >
                      <Gavel className="w-4 h-4" />
                      <span>إصدار الحكم وتنفيذ الحوالات المالية فوراً</span>
                    </button>
                  </div>
                </div>
              )}
            </div>
          ) : (
            <div className="oqoody-card p-16 text-center text-xs text-oqoody-textMuted">
              اختر ملف قضية من القائمة الجانبية لبدء جلسة التحكيم
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

