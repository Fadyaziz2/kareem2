import React, { useState, useEffect } from 'react';
import { 
  GraduationCap, 
  Search, 
  Filter, 
  CheckCircle, 
  XCircle, 
  Clock, 
  Eye, 
  Star, 
  FileText, 
  Percent, 
  AlertCircle,
  ExternalLink,
  ShieldCheck,
  Building2
} from 'lucide-react';
import { adminApi } from '../services/api';
import { Lawyer, VerificationStatus } from '../types';

export const LawyersPage: React.FC = () => {
  const [lawyers, setLawyers] = useState<Lawyer[]>([]);
  const [filterStatus, setFilterStatus] = useState<string>('all');
  const [searchQuery, setSearchQuery] = useState<string>('');
  const [isLoading, setIsLoading] = useState<boolean>(true);

  // Review Modal State
  const [selectedLawyer, setSelectedLawyer] = useState<Lawyer | null>(null);
  const [editCommission, setEditCommission] = useState<number>(15);
  const [rejectionReason, setRejectionReason] = useState<string>('');
  const [isSubmitting, setIsSubmitting] = useState<boolean>(false);
  const [toast, setToast] = useState<string | null>(null);

  useEffect(() => {
    loadLawyers();
  }, [filterStatus]);

  const loadLawyers = async () => {
    setIsLoading(true);
    try {
      const data = await adminApi.getLawyers(filterStatus);
      setLawyers(data);
    } catch (err) {
      console.error(err);
    } finally {
      setIsLoading(false);
    }
  };

  const handleOpenReview = (lawyer: Lawyer) => {
    setSelectedLawyer(lawyer);
    setEditCommission(lawyer.commissionRate || 15);
    setRejectionReason(lawyer.rejectionReason || '');
  };

  const handleVerify = async (status: 'approved' | 'rejected') => {
    if (!selectedLawyer) return;
    if (status === 'rejected' && !rejectionReason.trim()) {
      showToast('يرجى كتابة سبب الرفض لتبليغ المحامي به');
      return;
    }

    setIsSubmitting(true);
    try {
      const updated = await adminApi.verifyLawyer(
        selectedLawyer._id,
        status,
        editCommission,
        status === 'rejected' ? rejectionReason : undefined
      );

      setLawyers(lawyers.map(l => l._id === selectedLawyer._id ? updated : l));
      setSelectedLawyer(null);
      showToast(status === 'approved' ? 'تم اعتماد المحامي بنجاح وإرسال إشعار التفعيل' : 'تم رفض طلب القيد وحفظ الأسباب');
    } catch {
      showToast('حدث خطأ أثناء معالجة الطلب');
    } finally {
      setIsSubmitting(false);
    }
  };

  const showToast = (msg: string) => {
    setToast(msg);
    setTimeout(() => setToast(null), 3000);
  };

  const filteredLawyers = lawyers.filter(l => {
    const q = searchQuery.toLowerCase();
    const nameMatch = l.userId?.fullName?.toLowerCase().includes(q);
    const barMatch = l.barNumber?.toLowerCase().includes(q);
    const degreeMatch = l.degree?.toLowerCase().includes(q);
    return nameMatch || barMatch || degreeMatch;
  });

  const getStatusBadge = (status: VerificationStatus) => {
    switch (status) {
      case 'approved':
        return (
          <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-bold bg-oqoody-success/10 text-oqoody-success border border-oqoody-success/30">
            <CheckCircle className="w-3.5 h-3.5" />
            <span>معتمد بنقابة المحامين</span>
          </span>
        );
      case 'rejected':
        return (
          <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-bold bg-oqoody-danger/10 text-oqoody-danger border border-oqoody-danger/30">
            <XCircle className="w-3.5 h-3.5" />
            <span>طلب مرفوض</span>
          </span>
        );
      default:
        return (
          <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-bold bg-oqoody-warning/10 text-oqoody-warning border border-oqoody-warning/30 animate-pulse">
            <Clock className="w-3.5 h-3.5" />
            <span>قيد التدقيق والفحص</span>
          </span>
        );
    }
  };

  return (
    <div className="space-y-6">
      {toast && (
        <div className="fixed bottom-6 left-6 z-50 bg-oqoody-dark border border-oqoody-gold/60 text-oqoody-gold px-4 py-3 rounded-xl shadow-2xl flex items-center gap-2 text-sm animate-in fade-in slide-in-from-bottom-2">
          <ShieldCheck className="w-5 h-5 text-oqoody-gold" />
          <span>{toast}</span>
        </div>
      )}

      {/* Filter and Search Bar */}
      <div className="flex flex-col sm:flex-row items-stretch sm:items-center justify-between gap-4">
        <div className="relative flex-1 max-w-md">
          <Search className="w-4 h-4 text-oqoody-textMuted absolute right-3.5 top-3.5" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="البحث باسم المحامي، رقم القيد بالنقابة، أو الدرجة..."
            className="w-full bg-oqoody-card border border-oqoody-border rounded-xl pr-10 pl-4 py-2.5 text-xs text-oqoody-textLight focus:outline-none focus:border-oqoody-gold transition-colors"
          />
        </div>

        <div className="flex items-center gap-2 overflow-x-auto">
          <Filter className="w-4 h-4 text-oqoody-gold flex-shrink-0" />
          {[
            { id: 'all', label: 'كافة المحامين' },
            { id: 'pending', label: 'قيد الانتظار ⏳' },
            { id: 'approved', label: 'المعتمدين ✅' },
            { id: 'rejected', label: 'المرفوضين ❌' }
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

      {/* Lawyers Table */}
      <div className="oqoody-card overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-right text-xs">
            <thead className="bg-oqoody-dark/90 text-oqoody-textMuted uppercase font-semibold border-b border-oqoody-border">
              <tr>
                <th className="px-6 py-4">المحامي</th>
                <th className="px-4 py-4">رقم القيد بالنقابة</th>
                <th className="px-4 py-4">الدرجة القضائية</th>
                <th className="px-4 py-4">التخصصات القانونية</th>
                <th className="px-4 py-4">نسبة عمولة المنصة</th>
                <th className="px-4 py-4">التقييم والاستشارات</th>
                <th className="px-4 py-4">الحالة</th>
                <th className="px-6 py-4 text-center">إجراءات الفحص</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-oqoody-border/60">
              {isLoading ? (
                <tr>
                  <td colSpan={8} className="text-center py-12 text-oqoody-textMuted">
                    <span className="inline-block w-6 h-6 border-2 border-oqoody-gold border-t-transparent rounded-full animate-spin mb-2" />
                    <div>جاري جلب سجلات المحامين...</div>
                  </td>
                </tr>
              ) : filteredLawyers.length === 0 ? (
                <tr>
                  <td colSpan={8} className="text-center py-12 text-oqoody-textMuted">
                    لا توجد طلبات محامين مطابقة للمعايير المحددة
                  </td>
                </tr>
              ) : (
                filteredLawyers.map((lawyer) => (
                  <tr key={lawyer._id} className="hover:bg-oqoody-dark/50 transition-colors">
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-xl bg-oqoody-dark border border-oqoody-gold/40 flex items-center justify-center font-bold text-oqoody-gold text-base flex-shrink-0">
                          {lawyer.userId?.fullName?.charAt(0) || 'م'}
                        </div>
                        <div>
                          <div className="font-bold text-sm text-oqoody-textLight">{lawyer.userId?.fullName}</div>
                          <div className="text-[11px] text-oqoody-textMuted">{lawyer.userId?.city || 'القاهرة'} • {lawyer.userId?.phone}</div>
                        </div>
                      </div>
                    </td>
                    <td className="px-4 py-4 font-mono font-bold text-oqoody-textLight">
                      {lawyer.barNumber}
                    </td>
                    <td className="px-4 py-4">
                      <span className="font-bold text-oqoody-gold bg-oqoody-gold/10 border border-oqoody-gold/30 px-2.5 py-0.5 rounded-md">
                        محامٍ أمام {lawyer.degree}
                      </span>
                    </td>
                    <td className="px-4 py-4">
                      <div className="flex flex-wrap gap-1 max-w-xs">
                        {(lawyer.specializations || []).slice(0, 2).map((s, idx) => (
                          <span key={idx} className="bg-oqoody-card border border-oqoody-border px-2 py-0.5 rounded text-[10px] text-oqoody-textMuted">
                            {s}
                          </span>
                        ))}
                        {(lawyer.specializations || []).length > 2 && (
                          <span className="text-[10px] text-oqoody-gold">+{lawyer.specializations.length - 2}</span>
                        )}
                      </div>
                    </td>
                    <td className="px-4 py-4 font-bold text-oqoody-textLight">
                      {lawyer.commissionRate || 15}%
                    </td>
                    <td className="px-4 py-4">
                      <div className="flex items-center gap-1 text-oqoody-gold font-bold">
                        <Star className="w-3.5 h-3.5 fill-oqoody-gold" />
                        <span>{lawyer.rating?.toFixed(1) || '5.0'}</span>
                        <span className="text-[10px] text-oqoody-textMuted font-normal">({lawyer.totalConsultations || 0} استشارة)</span>
                      </div>
                    </td>
                    <td className="px-4 py-4">
                      {getStatusBadge(lawyer.verificationStatus)}
                    </td>
                    <td className="px-6 py-4 text-center">
                      <button
                        onClick={() => handleOpenReview(lawyer)}
                        className="px-3.5 py-1.5 rounded-xl bg-oqoody-gold hover:bg-oqoody-goldHover text-oqoody-bg font-bold text-xs shadow-gold-glow transition-all flex items-center justify-center gap-1.5 mx-auto"
                      >
                        <Eye className="w-3.5 h-3.5" />
                        <span>مراجعة الوثائق</span>
                      </button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Review & Verification Modal */}
      {selectedLawyer && (
        <div className="fixed inset-0 z-50 bg-black/80 backdrop-blur-md flex items-center justify-center p-4">
          <div className="bg-oqoody-dark border border-oqoody-border rounded-3xl w-full max-w-2xl max-h-[90vh] overflow-y-auto shadow-2xl p-6 sm:p-8">
            <div className="flex items-start justify-between pb-4 border-b border-oqoody-border mb-6">
              <div>
                <h3 className="text-lg font-bold text-oqoody-textLight flex items-center gap-2">
                  <GraduationCap className="w-6 h-6 text-oqoody-gold" />
                  <span>ملف اعتماد المحامي: {selectedLawyer.userId?.fullName}</span>
                </h3>
                <p className="text-xs text-oqoody-textMuted mt-1">
                  رقم القيد النقابي: <span className="text-oqoody-gold font-mono font-bold">{selectedLawyer.barNumber}</span> • درجة التقاضي: <span className="font-bold text-oqoody-textLight">{selectedLawyer.degree}</span>
                </p>
              </div>
              <button
                onClick={() => setSelectedLawyer(null)}
                className="text-oqoody-textMuted hover:text-white p-1 rounded-lg"
              >
                ✕
              </button>
            </div>

            {/* Document Image Previews */}
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 mb-6">
              <div>
                <label className="block text-xs font-semibold text-oqoody-textMuted mb-2">
                  بطاقة عضوية نقابة المحامين (كارنيه النقابة)
                </label>
                <div className="rounded-xl overflow-hidden border border-oqoody-border bg-oqoody-card relative group aspect-video flex items-center justify-center">
                  <img
                    src={selectedLawyer.barCardImage || 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=600&q=80'}
                    alt="كارنيه النقابة"
                    className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                  />
                  <a
                    href={selectedLawyer.barCardImage || '#'}
                    target="_blank"
                    rel="noreferrer"
                    className="absolute inset-0 bg-black/60 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center gap-2 text-oqoody-gold text-xs font-bold"
                  >
                    <ExternalLink className="w-4 h-4" />
                    <span>تكبير الصورة</span>
                  </a>
                </div>
              </div>

              <div>
                <label className="block text-xs font-semibold text-oqoody-textMuted mb-2">
                  بطاقة الرقم القومي المصرية
                </label>
                <div className="rounded-xl overflow-hidden border border-oqoody-border bg-oqoody-card relative group aspect-video flex items-center justify-center">
                  <img
                    src={selectedLawyer.idCardImage || 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?auto=format&fit=crop&w=600&q=80'}
                    alt="الرقم القومي"
                    className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                  />
                  <a
                    href={selectedLawyer.idCardImage || '#'}
                    target="_blank"
                    rel="noreferrer"
                    className="absolute inset-0 bg-black/60 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center gap-2 text-oqoody-gold text-xs font-bold"
                  >
                    <ExternalLink className="w-4 h-4" />
                    <span>تكبير الصورة</span>
                  </a>
                </div>
              </div>
            </div>

            {/* Specializations Tags */}
            <div className="mb-6">
              <label className="block text-xs font-semibold text-oqoody-textMuted mb-2">
                مجالات الاختصاص والخبرة القانونية
              </label>
              <div className="flex flex-wrap gap-2">
                {(selectedLawyer.specializations || []).map((spec, i) => (
                  <span key={i} className="px-3 py-1 rounded-lg bg-oqoody-card border border-oqoody-gold/30 text-xs text-oqoody-textLight">
                    ⚖️ {spec}
                  </span>
                ))}
              </div>
            </div>

            {/* Commission Rate Control */}
            <div className="mb-6 bg-oqoody-card/60 p-4 rounded-2xl border border-oqoody-border">
              <label className="block text-xs font-bold text-oqoody-textLight mb-1.5 flex items-center gap-2">
                <Percent className="w-4 h-4 text-oqoody-gold" />
                <span>تحديد نسبة عمولة المنصة من أتعاب المحامي (%)</span>
              </label>
              <div className="flex items-center gap-3">
                <input
                  type="number"
                  min={5}
                  max={50}
                  value={editCommission}
                  onChange={(e) => setEditCommission(Number(e.target.value))}
                  className="w-32 bg-oqoody-dark border border-oqoody-border rounded-xl px-4 py-2 text-sm text-oqoody-textLight focus:outline-none focus:border-oqoody-gold font-bold"
                />
                <span className="text-xs text-oqoody-textMuted">
                  النسبة الافتراضية لمنصة عقودي هي 15% وتطبق على الاستشارات وعقود الوساطة.
                </span>
              </div>
            </div>

            {/* Rejection Reason (Required if Rejecting) */}
            <div className="mb-6">
              <label className="block text-xs font-semibold text-oqoody-textMuted mb-1.5">
                سبب الرفض (في حالة عدم استيفاء الشروط أو انتهاء صلاحية الكارنيه)
              </label>
              <textarea
                rows={2}
                value={rejectionReason}
                onChange={(e) => setRejectionReason(e.target.value)}
                placeholder="مثال: الصورة المرفقة غير واضحة، أو انتهاء سريان القيد للعام الحالي..."
                className="w-full bg-oqoody-card border border-oqoody-border rounded-xl p-3 text-xs text-oqoody-textLight focus:outline-none focus:border-oqoody-gold"
              />
            </div>

            {/* Action Buttons */}
            <div className="flex items-center justify-between gap-3 pt-4 border-t border-oqoody-border">
              <button
                type="button"
                onClick={() => setSelectedLawyer(null)}
                className="px-5 py-2.5 rounded-xl text-xs font-semibold bg-oqoody-card hover:bg-oqoody-border text-oqoody-textMuted transition-colors"
              >
                إغلاق
              </button>

              <div className="flex items-center gap-3">
                <button
                  type="button"
                  disabled={isSubmitting}
                  onClick={() => handleVerify('rejected')}
                  className="px-5 py-2.5 rounded-xl text-xs font-bold bg-oqoody-danger/20 hover:bg-oqoody-danger text-oqoody-danger hover:text-white border border-oqoody-danger/40 transition-all flex items-center gap-1.5"
                >
                  <XCircle className="w-4 h-4" />
                  <span>رفض الطلب</span>
                </button>

                <button
                  type="button"
                  disabled={isSubmitting}
                  onClick={() => handleVerify('approved')}
                  className="px-6 py-2.5 rounded-xl text-xs font-bold bg-oqoody-gold hover:bg-oqoody-goldHover text-oqoody-bg shadow-gold-glow transition-all flex items-center gap-1.5"
                >
                  <CheckCircle className="w-4 h-4" />
                  <span>اعتماد المحامي وتفعيل حسابه</span>
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

