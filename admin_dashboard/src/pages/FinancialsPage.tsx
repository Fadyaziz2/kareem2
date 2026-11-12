import React, { useState, useEffect } from 'react';
import { 
  Wallet, 
  TrendingUp, 
  ArrowDownLeft, 
  ArrowUpRight, 
  Download, 
  CheckCircle, 
  Clock, 
  Building2, 
  CreditCard,
  FileSpreadsheet,
  Coins,
  ShieldCheck,
  Search
} from 'lucide-react';
import { adminApi } from '../services/api';
import { FinancialStats, WithdrawalRequest, LedgerEntry } from '../types';

export const FinancialsPage: React.FC = () => {
  const [financials, setFinancials] = useState<FinancialStats | null>(null);
  const [isLoading, setIsLoading] = useState<boolean>(true);
  const [activeTab, setActiveTab] = useState<'withdrawals' | 'ledger'>('withdrawals');
  const [toast, setToast] = useState<string | null>(null);

  useEffect(() => {
    loadFinancials();
  }, []);

  const loadFinancials = async () => {
    setIsLoading(true);
    try {
      const data = await adminApi.getFinancials();
      setFinancials(data);
    } catch (err) {
      console.error(err);
    } finally {
      setIsLoading(false);
    }
  };

  const handleApproveWithdrawal = async (payoutId: string) => {
    try {
      await adminApi.approvePayout(payoutId);
      if (financials) {
        setFinancials({
          ...financials,
          withdrawals: financials.withdrawals.map(w => 
            w.id === payoutId ? { ...w, status: 'completed' } : w
          )
        });
      }
      showToast('تمت الموافقة على التحويل البنكي الفوري بنجاح 🏦');
    } catch {
      showToast('فشل تأكيد التحويل');
    }
  };

  const exportCSV = () => {
    if (!financials) return;
    const rows = financials.ledger.map(l => `${l.id},${l.type},"${l.title}",${l.amount},"${l.party}",${l.date}`);
    const csvContent = "data:text/csv;charset=utf-8,ID,Type,Title,Amount,Party,Date\n" + rows.join("\n");
    const encodedUri = encodeURI(csvContent);
    const link = document.createElement("a");
    link.setAttribute("href", encodedUri);
    link.setAttribute("download", `oqoody-financial-ledger-${new Date().toISOString().slice(0, 10)}.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    showToast('تم تصدير ملف الـ CSV بنجاح');
  };

  const showToast = (msg: string) => {
    setToast(msg);
    setTimeout(() => setToast(null), 3000);
  };

  return (
    <div className="space-y-6">
      {toast && (
        <div className="fixed bottom-6 left-6 z-50 bg-oqoody-dark border border-oqoody-gold/60 text-oqoody-gold px-4 py-3 rounded-xl shadow-2xl flex items-center gap-2 text-sm animate-in fade-in slide-in-from-bottom-2">
          <ShieldCheck className="w-5 h-5 text-oqoody-gold" />
          <span>{toast}</span>
        </div>
      )}

      {/* Top Financial Metric Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
        <div className="oqoody-card p-6 border-oqoody-gold/30">
          <div className="flex items-center justify-between mb-3">
            <span className="text-xs font-semibold text-oqoody-textMuted">صافي إيرادات وعمولات المنصة</span>
            <div className="p-2 rounded-xl bg-oqoody-gold/10 text-oqoody-gold">
              <TrendingUp className="w-5 h-5" />
            </div>
          </div>
          <div className="text-2xl font-black text-oqoody-textLight tracking-tight">
            {(financials?.platformNetRevenue || 684200).toLocaleString()} ج.م
          </div>
          <div className="text-[11px] text-oqoody-gold mt-1">
            عمولات الوساطة والاستشارات ونماذج العقود
          </div>
        </div>

        <div className="oqoody-card p-6 border-emerald-500/30">
          <div className="flex items-center justify-between mb-3">
            <span className="text-xs font-semibold text-oqoody-textMuted">إجمالي حجم صفقات الوساطة</span>
            <div className="p-2 rounded-xl bg-emerald-500/10 text-emerald-400">
              <Coins className="w-5 h-5" />
            </div>
          </div>
          <div className="text-2xl font-black text-emerald-400 tracking-tight">
            {(financials?.totalEscrowVolume || 8450000).toLocaleString()} ج.م
          </div>
          <div className="text-[11px] text-oqoody-textMuted mt-1">
            إجمالي الأموال المودعة والمحمية بحساب الضمان
          </div>
        </div>

        <div className="oqoody-card p-6 border-oqoody-warning/30">
          <div className="flex items-center justify-between mb-3">
            <span className="text-xs font-semibold text-oqoody-textMuted">طلبات سحب أرباح معلقة</span>
            <div className="p-2 rounded-xl bg-oqoody-warning/10 text-oqoody-warning">
              <Clock className="w-5 h-5" />
            </div>
          </div>
          <div className="text-2xl font-black text-oqoody-warning tracking-tight">
            {(financials?.pendingPayoutsAmount || 22700).toLocaleString()} ج.م
          </div>
          <div className="text-[11px] text-oqoody-textMuted mt-1">
            تتطلب التحويل البنكي لحسابات المحامين
          </div>
        </div>

        <div className="oqoody-card p-6 border-blue-500/30">
          <div className="flex items-center justify-between mb-3">
            <span className="text-xs font-semibold text-oqoody-textMuted">حوالات مكتملة ومسددة</span>
            <div className="p-2 rounded-xl bg-blue-500/10 text-blue-400">
              <CheckCircle className="w-5 h-5" />
            </div>
          </div>
          <div className="text-2xl font-black text-blue-400 tracking-tight">
            {(financials?.completedPayoutsAmount || 412000).toLocaleString()} ج.م
          </div>
          <div className="text-[11px] text-oqoody-textMuted mt-1">
            تمت تسويتها بنجاح عبر النظام المصرفي
          </div>
        </div>
      </div>

      {/* Tabs and Export Action */}
      <div className="flex flex-col sm:flex-row items-stretch sm:items-center justify-between gap-4">
        <div className="flex items-center gap-2">
          <button
            onClick={() => setActiveTab('withdrawals')}
            className={`px-4 py-2 rounded-xl text-xs font-bold transition-all ${
              activeTab === 'withdrawals'
                ? 'bg-oqoody-gold text-oqoody-bg shadow-gold-glow'
                : 'bg-oqoody-card text-oqoody-textMuted hover:text-white border border-oqoody-border'
            }`}
          >
            طلبات سحب أرباح المحامين ({financials?.withdrawals?.filter(w => w.status === 'pending').length || 0})
          </button>

          <button
            onClick={() => setActiveTab('ledger')}
            className={`px-4 py-2 rounded-xl text-xs font-bold transition-all ${
              activeTab === 'ledger'
                ? 'bg-oqoody-gold text-oqoody-bg shadow-gold-glow'
                : 'bg-oqoody-card text-oqoody-textMuted hover:text-white border border-oqoody-border'
            }`}
          >
            سجل قيود وعمولات المنصة (Ledger)
          </button>
        </div>

        <div className="flex items-center gap-2">
          <button
            onClick={exportCSV}
            className="px-4 py-2 rounded-xl bg-oqoody-card hover:bg-oqoody-border text-oqoody-textLight border border-oqoody-border text-xs font-semibold transition-colors flex items-center gap-2"
          >
            <FileSpreadsheet className="w-4 h-4 text-emerald-400" />
            <span>تصدير تقرير CSV</span>
          </button>
        </div>
      </div>

      {/* Tables Container */}
      <div className="oqoody-card overflow-hidden">
        {activeTab === 'withdrawals' ? (
          <div className="overflow-x-auto">
            <table className="w-full text-right text-xs">
              <thead className="bg-oqoody-dark/90 text-oqoody-textMuted uppercase font-semibold border-b border-oqoody-border">
                <tr>
                  <th className="px-6 py-4">رقم الطلب</th>
                  <th className="px-4 py-4">المحامي</th>
                  <th className="px-4 py-4">المبلغ المطلوب</th>
                  <th className="px-4 py-4">البنك والـ IBAN</th>
                  <th className="px-4 py-4">تاريخ الطلب</th>
                  <th className="px-4 py-4">الحالة</th>
                  <th className="px-6 py-4 text-center">الإجراء المالي</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-oqoody-border/60">
                {(financials?.withdrawals || []).map((w) => (
                  <tr key={w.id} className="hover:bg-oqoody-dark/50 transition-colors">
                    <td className="px-6 py-4 font-mono font-bold text-oqoody-gold">
                      #{w.id}
                    </td>
                    <td className="px-4 py-4 font-bold text-oqoody-textLight">
                      {w.lawyerName}
                    </td>
                    <td className="px-4 py-4 font-black text-emerald-400 text-sm">
                      {w.amount.toLocaleString()} ج.م
                    </td>
                    <td className="px-4 py-4 space-y-0.5">
                      <div className="font-bold text-oqoody-textLight flex items-center gap-1">
                        <Building2 className="w-3.5 h-3.5 text-oqoody-gold" />
                        <span>{w.bank}</span>
                      </div>
                      <div className="font-mono text-[11px] text-oqoody-textMuted" dir="ltr">
                        {w.iban}
                      </div>
                    </td>
                    <td className="px-4 py-4 text-oqoody-textMuted">
                      {w.date}
                    </td>
                    <td className="px-4 py-4">
                      {w.status === 'completed' ? (
                        <span className="bg-oqoody-success/10 text-oqoody-success border border-oqoody-success/30 px-2.5 py-1 rounded-full text-[11px] font-bold">
                          تم التحويل بنجاح ✓
                        </span>
                      ) : (
                        <span className="bg-oqoody-warning/10 text-oqoody-warning border border-oqoody-warning/30 px-2.5 py-1 rounded-full text-[11px] font-bold animate-pulse">
                          قيد المراجعة والمطابقة ⏳
                        </span>
                      )}
                    </td>
                    <td className="px-6 py-4 text-center">
                      {w.status === 'pending' ? (
                        <button
                          onClick={() => handleApproveWithdrawal(w.id)}
                          className="px-3.5 py-1.5 rounded-xl bg-oqoody-gold hover:bg-oqoody-goldHover text-oqoody-bg font-bold text-xs shadow-gold-glow transition-all"
                        >
                          الموافقة والتحويل
                        </button>
                      ) : (
                        <span className="text-xs text-oqoody-textMuted">مكتمل</span>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-right text-xs">
              <thead className="bg-oqoody-dark/90 text-oqoody-textMuted uppercase font-semibold border-b border-oqoody-border">
                <tr>
                  <th className="px-6 py-4">رقم القيد</th>
                  <th className="px-4 py-4">نوع العملية</th>
                  <th className="px-6 py-4">بيان المعاملة</th>
                  <th className="px-4 py-4">المبلغ المستحق</th>
                  <th className="px-4 py-4">الطرف المعني</th>
                  <th className="px-4 py-4">التاريخ</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-oqoody-border/60">
                {(financials?.ledger || []).map((entry) => (
                  <tr key={entry.id} className="hover:bg-oqoody-dark/50 transition-colors">
                    <td className="px-6 py-4 font-mono font-bold text-oqoody-gold">
                      #{entry.id}
                    </td>
                    <td className="px-4 py-4">
                      <span className="bg-oqoody-card border border-oqoody-border px-2.5 py-1 rounded-md text-[11px] font-semibold text-oqoody-textLight">
                        {entry.type === 'escrow_fee' ? 'عمولة وساطة' : entry.type === 'consultation_cut' ? 'نسبة استشارة' : 'بيع نموذج عقود'}
                      </span>
                    </td>
                    <td className="px-6 py-4 font-bold text-oqoody-textLight">
                      {entry.title}
                    </td>
                    <td className="px-4 py-4 font-black text-emerald-400 text-sm">
                      +{entry.amount.toLocaleString()} ج.م
                    </td>
                    <td className="px-4 py-4 text-oqoody-textMuted">
                      {entry.party}
                    </td>
                    <td className="px-4 py-4 text-oqoody-textMuted">
                      {entry.date}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
};

