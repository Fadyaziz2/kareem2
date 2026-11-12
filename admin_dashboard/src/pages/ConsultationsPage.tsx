import React, { useState, useEffect } from 'react';
import { 
  MessageSquare, 
  PhoneCall, 
  Building, 
  Filter, 
  Search, 
  UserCheck, 
  Clock, 
  CheckCircle2, 
  AlertCircle, 
  Calendar, 
  Paperclip,
  Share2,
  ChevronLeft
} from 'lucide-react';
import { adminApi } from '../services/api';
import { Consultation, Lawyer, ConsultationType, ConsultationStatus } from '../types';

export const ConsultationsPage: React.FC = () => {
  const [consultations, setConsultations] = useState<Consultation[]>([]);
  const [lawyers, setLawyers] = useState<Lawyer[]>([]);
  const [filterType, setFilterType] = useState<string>('all');
  const [filterStatus, setFilterStatus] = useState<string>('all');
  const [searchQuery, setSearchQuery] = useState<string>('');
  const [isLoading, setIsLoading] = useState<boolean>(true);

  // Reassign Modal State
  const [selectedConsultation, setSelectedConsultation] = useState<Consultation | null>(null);
  const [reassignLawyerId, setReassignLawyerId] = useState<string>('');
  const [detailsModalItem, setDetailsModalItem] = useState<Consultation | null>(null);
  const [toast, setToast] = useState<string | null>(null);

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    setIsLoading(true);
    try {
      const [cData, lData] = await Promise.all([
        adminApi.getConsultations(),
        adminApi.getLawyers('approved')
      ]);
      setConsultations(cData);
      setLawyers(lData);
    } catch (err) {
      console.error(err);
    } finally {
      setIsLoading(false);
    }
  };

  const handleReassign = async () => {
    if (!selectedConsultation || !reassignLawyerId) return;
    try {
      const updated = await adminApi.reassignConsultation(selectedConsultation._id, reassignLawyerId);
      setConsultations(consultations.map(c => c._id === selectedConsultation._id ? updated : c));
      setSelectedConsultation(null);
      showToast('تم إعادة توجيه الاستشارة للمحامي بنجاح');
    } catch {
      showToast('فشل إعادة تعيين المحامي');
    }
  };

  const showToast = (msg: string) => {
    setToast(msg);
    setTimeout(() => setToast(null), 3000);
  };

  const getTypeBadge = (type: ConsultationType) => {
    switch (type) {
      case 'written':
        return (
          <span className="flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-bold bg-blue-500/10 text-blue-400 border border-blue-500/30">
            <MessageSquare className="w-3.5 h-3.5" />
            <span>استشارة مكتوبة</span>
          </span>
        );
      case 'audio_call':
        return (
          <span className="flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-bold bg-purple-500/10 text-purple-400 border border-purple-500/30">
            <PhoneCall className="w-3.5 h-3.5" />
            <span>مكالمة هاتفية</span>
          </span>
        );
      case 'office_visit':
        return (
          <span className="flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-bold bg-emerald-500/10 text-emerald-400 border border-emerald-500/30">
            <Building className="w-3.5 h-3.5" />
            <span>مقابلة بمكتب المحامي</span>
          </span>
        );
    }
  };

  const getStatusBadge = (status: ConsultationStatus) => {
    switch (status) {
      case 'completed':
        return (
          <span className="px-2.5 py-1 rounded-full text-xs font-bold bg-oqoody-success/10 text-oqoody-success border border-oqoody-success/30 flex items-center gap-1">
            <CheckCircle2 className="w-3.5 h-3.5" />
            <span>مكتملة ومغلقة</span>
          </span>
        );
      case 'in_progress':
        return (
          <span className="px-2.5 py-1 rounded-full text-xs font-bold bg-oqoody-gold/10 text-oqoody-gold border border-oqoody-gold/30 flex items-center gap-1">
            <Clock className="w-3.5 h-3.5" />
            <span>قيد المعالجة من المحامي</span>
          </span>
        );
      case 'pending':
        return (
          <span className="px-2.5 py-1 rounded-full text-xs font-bold bg-oqoody-warning/10 text-oqoody-warning border border-oqoody-warning/30 flex items-center gap-1 animate-pulse">
            <AlertCircle className="w-3.5 h-3.5" />
            <span>بانتظار قبول المحامي</span>
          </span>
        );
      default:
        return (
          <span className="px-2.5 py-1 rounded-full text-xs font-bold bg-oqoody-danger/10 text-oqoody-danger border border-oqoody-danger/30">
            ملغاة
          </span>
        );
    }
  };

  const filteredConsultations = consultations.filter(c => {
    const matchType = filterType === 'all' || c.type === filterType;
    const matchStatus = filterStatus === 'all' || c.status === filterStatus;
    const matchQuery = c.subject.toLowerCase().includes(searchQuery.toLowerCase()) || 
                       c.description.toLowerCase().includes(searchQuery.toLowerCase()) ||
                       (c.clientId?.fullName && c.clientId.fullName.toLowerCase().includes(searchQuery.toLowerCase()));
    return matchType && matchStatus && matchQuery;
  });

  return (
    <div className="space-y-6">
      {toast && (
        <div className="fixed bottom-6 left-6 z-50 bg-oqoody-dark border border-oqoody-gold/60 text-oqoody-gold px-4 py-3 rounded-xl shadow-2xl flex items-center gap-2 text-sm animate-in fade-in slide-in-from-bottom-2">
          <CheckCircle2 className="w-5 h-5 text-oqoody-gold" />
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
            placeholder="البحث بموضوع الاستشارة، اسم العميل، أو التفاصيل..."
            className="w-full bg-oqoody-card border border-oqoody-border rounded-xl pr-10 pl-4 py-2.5 text-xs text-oqoody-textLight focus:outline-none focus:border-oqoody-gold transition-colors"
          />
        </div>

        {/* Status Filters */}
        <div className="flex items-center gap-2 overflow-x-auto pb-1">
          <Filter className="w-4 h-4 text-oqoody-gold flex-shrink-0" />
          {[
            { id: 'all', label: 'كافة الحالات' },
            { id: 'pending', label: 'معلقة' },
            { id: 'in_progress', label: 'قيد التنفيذ' },
            { id: 'completed', label: 'مكتملة' }
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

      {/* Consultations List */}
      <div className="space-y-4">
        {isLoading ? (
          <div className="text-center py-16 text-oqoody-textMuted">
            <span className="inline-block w-6 h-6 border-2 border-oqoody-gold border-t-transparent rounded-full animate-spin mb-2" />
            <div>جاري تحميل الاستشارات القانونية...</div>
          </div>
        ) : filteredConsultations.length === 0 ? (
          <div className="oqoody-card p-12 text-center text-xs text-oqoody-textMuted">
            لا توجد استشارات قانونية تطابق التصفية الحالية
          </div>
        ) : (
          filteredConsultations.map((c) => (
            <div
              key={c._id}
              className="oqoody-card p-6 flex flex-col lg:flex-row items-start lg:items-center justify-between gap-4 hover:border-oqoody-gold/40 transition-all duration-200"
            >
              {/* Left Details */}
              <div className="space-y-2 flex-1">
                <div className="flex flex-wrap items-center gap-2">
                  {getTypeBadge(c.type)}
                  {getStatusBadge(c.status)}
                  <span className="text-xs text-oqoody-textMuted flex items-center gap-1">
                    <Calendar className="w-3.5 h-3.5" />
                    <span>{new Date(c.createdAt).toLocaleDateString('ar-EG', { dateStyle: 'medium' })}</span>
                  </span>
                </div>

                <h3 className="text-base font-bold text-oqoody-textLight">
                  {c.subject}
                </h3>

                <p className="text-xs text-oqoody-textMuted line-clamp-2 leading-relaxed">
                  {c.description}
                </p>

                {/* Parties info */}
                <div className="flex flex-wrap items-center gap-6 pt-2 text-xs">
                  <div>
                    <span className="text-oqoody-textMuted">العميل الطالب: </span>
                    <span className="font-bold text-oqoody-textLight">{c.clientId?.fullName || 'عميل مسجل'}</span>
                    <span className="text-[11px] text-oqoody-textMuted mr-1.5" dir="ltr">({c.clientId?.phone})</span>
                  </div>

                  <div>
                    <span className="text-oqoody-textMuted">المحامي المسؤول: </span>
                    <span className="font-bold text-oqoody-gold">
                      {c.lawyerId?.fullName ? `أ. ${c.lawyerId.fullName}` : 'غير معين بعد'}
                    </span>
                  </div>

                  <div>
                    <span className="text-oqoody-textMuted">الأتعاب المحصلة: </span>
                    <span className="font-black text-emerald-400">{c.price} ج.م</span>
                  </div>
                </div>
              </div>

              {/* Action Buttons */}
              <div className="flex items-center gap-2.5 self-end lg:self-center">
                <button
                  onClick={() => setDetailsModalItem(c)}
                  className="px-4 py-2 rounded-xl bg-oqoody-card hover:bg-oqoody-border text-oqoody-textLight border border-oqoody-border text-xs font-semibold transition-colors"
                >
                  التفاصيل والمرفقات
                </button>

                <button
                  onClick={() => {
                    setSelectedConsultation(c);
                    setReassignLawyerId(c.lawyerId?._id || '');
                  }}
                  className="px-4 py-2 rounded-xl bg-oqoody-gold hover:bg-oqoody-goldHover text-oqoody-bg text-xs font-bold shadow-gold-glow transition-all flex items-center gap-1.5"
                >
                  <Share2 className="w-3.5 h-3.5" />
                  <span>إعادة توجيه لمحامٍ</span>
                </button>
              </div>
            </div>
          ))
        )}
      </div>

      {/* Details Modal */}
      {detailsModalItem && (
        <div className="fixed inset-0 z-50 bg-black/80 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-oqoody-dark border border-oqoody-border rounded-3xl w-full max-w-lg p-6 shadow-2xl space-y-4">
            <div className="flex items-start justify-between pb-3 border-b border-oqoody-border">
              <h3 className="font-bold text-base text-oqoody-textLight">{detailsModalItem.subject}</h3>
              <button onClick={() => setDetailsModalItem(null)} className="text-oqoody-textMuted hover:text-white">✕</button>
            </div>
            <div>
              <label className="text-xs font-bold text-oqoody-gold block mb-1">تفاصيل طلب الاستشارة والوقائع:</label>
              <div className="bg-oqoody-card p-3 rounded-xl text-xs text-oqoody-textLight leading-relaxed">
                {detailsModalItem.description}
              </div>
            </div>
            {detailsModalItem.responseNotes && (
              <div>
                <label className="text-xs font-bold text-emerald-400 block mb-1">الرأي القانوني ومذكرة المحامي:</label>
                <div className="bg-oqoody-card p-3 rounded-xl text-xs text-oqoody-textLight leading-relaxed">
                  {detailsModalItem.responseNotes}
                </div>
              </div>
            )}
            <div className="flex justify-end pt-2">
              <button
                onClick={() => setDetailsModalItem(null)}
                className="px-5 py-2 rounded-xl text-xs font-bold bg-oqoody-gold text-oqoody-bg"
              >
                إغلاق
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Reassign Lawyer Modal */}
      {selectedConsultation && (
        <div className="fixed inset-0 z-50 bg-black/80 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-oqoody-dark border border-oqoody-border rounded-3xl w-full max-w-md p-6 shadow-2xl">
            <h3 className="text-base font-bold text-oqoody-textLight mb-2">
              إعادة تعيين المحامي المسؤول
            </h3>
            <p className="text-xs text-oqoody-textMuted mb-4">
              الاستشارة: <span className="text-oqoody-gold font-bold">{selectedConsultation.subject}</span>
            </p>

            <div className="mb-6">
              <label className="block text-xs font-semibold text-oqoody-textMuted mb-1.5">
                اختر المحامي المعتمد من القائمة:
              </label>
              <select
                value={reassignLawyerId}
                onChange={(e) => setReassignLawyerId(e.target.value)}
                className="w-full bg-oqoody-card border border-oqoody-border rounded-xl px-4 py-3 text-xs text-oqoody-textLight focus:outline-none focus:border-oqoody-gold"
              >
                <option value="">-- اضغط لاختيار المحامي المعتمد --</option>
                {lawyers.map((l) => (
                  <option key={l._id} value={l.userId?._id}>
                    {l.userId?.fullName} (درجة: {l.degree} - قيد: {l.barNumber})
                  </option>
                ))}
              </select>
            </div>

            <div className="flex items-center justify-end gap-3">
              <button
                onClick={() => setSelectedConsultation(null)}
                className="px-4 py-2 rounded-xl text-xs font-semibold bg-oqoody-card hover:bg-oqoody-border text-oqoody-textMuted transition-colors"
              >
                إلغاء
              </button>
              <button
                onClick={handleReassign}
                disabled={!reassignLawyerId}
                className="px-5 py-2 rounded-xl text-xs font-bold bg-oqoody-gold hover:bg-oqoody-goldHover text-oqoody-bg shadow-gold-glow transition-all disabled:opacity-40"
              >
                تأكيد الإسناد
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

