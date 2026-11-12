import React, { useState, useEffect } from 'react';
import { 
  Users, 
  Search, 
  Filter, 
  ShieldCheck, 
  UserCheck, 
  UserX, 
  Coins, 
  Edit3, 
  Trash2,
  Plus,
  CheckCircle2,
  XCircle,
  Building,
  Phone,
  Mail
} from 'lucide-react';
import { adminApi } from '../services/api';
import { User, UserRole } from '../types';

export const UsersPage: React.FC = () => {
  const [users, setUsers] = useState<User[]>([]);
  const [selectedRole, setSelectedRole] = useState<string>('all');
  const [searchQuery, setSearchQuery] = useState<string>('');
  const [isLoading, setIsLoading] = useState<boolean>(true);

  // Modals state
  const [editingUser, setEditingUser] = useState<User | null>(null);
  const [walletModalUser, setWalletModalUser] = useState<User | null>(null);
  const [walletAmount, setWalletAmount] = useState<number>(1000);
  const [walletAction, setWalletAction] = useState<'credit' | 'debit'>('credit');
  const [newRole, setNewRole] = useState<UserRole>('client');
  const [feedback, setFeedback] = useState<string | null>(null);

  useEffect(() => {
    loadUsers();
  }, [selectedRole, searchQuery]);

  const loadUsers = async () => {
    setIsLoading(true);
    try {
      const data = await adminApi.getUsers(selectedRole, searchQuery);
      setUsers(data);
    } catch (err) {
      console.error(err);
    } finally {
      setIsLoading(false);
    }
  };

  const handleToggleStatus = async (user: User) => {
    try {
      const updated = await adminApi.toggleUserStatus(user._id);
      setUsers(users.map(u => u._id === user._id ? { ...u, isVerified: updated } : u));
      showToast(updated ? 'تم توثيق وتفعيل حساب المستخدم' : 'تم إلغاء تفعيل الحساب');
    } catch {
      showToast('تعذر تغيير حالة الحساب');
    }
  };

  const handleSaveRole = async () => {
    if (!editingUser) return;
    try {
      const updated = await adminApi.updateUserRole(editingUser._id, newRole);
      setUsers(users.map(u => u._id === editingUser._id ? { ...u, role: updated.role } : u));
      setEditingUser(null);
      showToast('تم تحديث رتبة وصلاحيات المستخدم بنجاح');
    } catch {
      showToast('حدث خطأ أثناء تعديل الرتبة');
    }
  };

  const handleAdjustWallet = async () => {
    if (!walletModalUser || walletAmount <= 0) return;
    try {
      const updated = await adminApi.adjustWallet(walletModalUser._id, walletAmount, walletAction);
      setUsers(users.map(u => u._id === walletModalUser._id ? { ...u, walletBalance: updated.walletBalance } : u));
      setWalletModalUser(null);
      showToast(`تم ${walletAction === 'credit' ? 'إيداع' : 'خصم'} مبلغ ${walletAmount} ج.م بنجاح`);
    } catch {
      showToast('تعذر تعديل رصيد المحفظة');
    }
  };

  const showToast = (msg: string) => {
    setFeedback(msg);
    setTimeout(() => setFeedback(null), 3000);
  };

  const getRoleBadge = (role: UserRole) => {
    switch (role) {
      case 'super_admin':
        return <span className="bg-oqoody-gold/20 text-oqoody-gold border border-oqoody-gold/40 px-2.5 py-1 rounded-full text-xs font-bold">سوبر أدمن 👑</span>;
      case 'legal_director':
        return <span className="bg-blue-500/20 text-blue-400 border border-blue-500/40 px-2.5 py-1 rounded-full text-xs font-bold">مدير قانوني ⚖️</span>;
      case 'financial_director':
        return <span className="bg-purple-500/20 text-purple-400 border border-purple-500/40 px-2.5 py-1 rounded-full text-xs font-bold">مدير مالي 💼</span>;
      case 'dispute_agent':
        return <span className="bg-red-500/20 text-red-400 border border-red-500/40 px-2.5 py-1 rounded-full text-xs font-bold">محكّم نزاعات 🏛️</span>;
      case 'lawyer':
        return <span className="bg-emerald-500/20 text-emerald-400 border border-emerald-500/40 px-2.5 py-1 rounded-full text-xs font-bold">محامٍ مقيد 🎓</span>;
      default:
        return <span className="bg-oqoody-card text-oqoody-textMuted border border-oqoody-border px-2.5 py-1 rounded-full text-xs font-bold">عميل منصة 👤</span>;
    }
  };

  return (
    <div className="space-y-6">
      {/* Toast Feedback */}
      {feedback && (
        <div className="fixed bottom-6 left-6 z-50 bg-oqoody-dark border border-oqoody-gold/60 text-oqoody-gold px-4 py-3 rounded-xl shadow-2xl flex items-center gap-2 text-sm animate-in fade-in slide-in-from-bottom-2">
          <CheckCircle2 className="w-5 h-5 text-oqoody-gold" />
          <span>{feedback}</span>
        </div>
      )}

      {/* Header and Controls */}
      <div className="flex flex-col sm:flex-row items-stretch sm:items-center justify-between gap-4">
        <div className="relative flex-1 max-w-md">
          <Search className="w-4 h-4 text-oqoody-textMuted absolute right-3.5 top-3.5" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="البحث بالاسم، رقم الهاتف، أو البريد الإلكتروني..."
            className="w-full bg-oqoody-card border border-oqoody-border rounded-xl pr-10 pl-4 py-2.5 text-xs text-oqoody-textLight focus:outline-none focus:border-oqoody-gold transition-colors"
          />
        </div>

        {/* Role Filters */}
        <div className="flex items-center gap-2 overflow-x-auto pb-1 sm:pb-0">
          <Filter className="w-4 h-4 text-oqoody-gold flex-shrink-0" />
          {[
            { id: 'all', label: 'الكل' },
            { id: 'client', label: 'العملاء' },
            { id: 'lawyer', label: 'المحامين' },
            { id: 'dispute_agent', label: 'المحكّمين' },
            { id: 'super_admin', label: 'الإدارة العليا' }
          ].map((tab) => (
            <button
              key={tab.id}
              onClick={() => setSelectedRole(tab.id)}
              className={`px-3 py-1.5 rounded-xl text-xs font-semibold whitespace-nowrap transition-all ${
                selectedRole === tab.id 
                  ? 'bg-oqoody-gold text-oqoody-bg shadow-gold-glow' 
                  : 'bg-oqoody-card text-oqoody-textMuted hover:text-oqoody-textLight border border-oqoody-border'
              }`}
            >
              {tab.label}
            </button>
          ))}
        </div>
      </div>

      {/* Users Data Table */}
      <div className="oqoody-card overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-right text-xs">
            <thead className="bg-oqoody-dark/90 text-oqoody-textMuted uppercase font-semibold border-b border-oqoody-border">
              <tr>
                <th className="px-6 py-4">المستخدم</th>
                <th className="px-4 py-4">الرتبة والدور</th>
                <th className="px-4 py-4">بيانات التواصل</th>
                <th className="px-4 py-4">المدينة</th>
                <th className="px-4 py-4">رصيد المحفظة</th>
                <th className="px-4 py-4">حالة الحساب</th>
                <th className="px-6 py-4 text-center">إجراءات الإدارة</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-oqoody-border/60">
              {isLoading ? (
                <tr>
                  <td colSpan={7} className="text-center py-12 text-oqoody-textMuted">
                    <span className="inline-block w-6 h-6 border-2 border-oqoody-gold border-t-transparent rounded-full animate-spin mb-2" />
                    <div>جاري تحميل بيانات المستخدمين...</div>
                  </td>
                </tr>
              ) : users.length === 0 ? (
                <tr>
                  <td colSpan={7} className="text-center py-12 text-oqoody-textMuted">
                    لا يوجد مستخدمين يطابقون معايير البحث المحددة
                  </td>
                </tr>
              ) : (
                users.map((user) => (
                  <tr key={user._id} className="hover:bg-oqoody-dark/50 transition-colors">
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-3">
                        <div className="w-9 h-9 rounded-full bg-oqoody-card border border-oqoody-gold/30 flex items-center justify-center font-bold text-oqoody-gold text-sm flex-shrink-0">
                          {user.fullName ? user.fullName.charAt(0) : 'ع'}
                        </div>
                        <div>
                          <div className="font-bold text-sm text-oqoody-textLight">{user.fullName}</div>
                          <div className="text-[10px] text-oqoody-textMuted">
                            انضم: {new Date(user.createdAt).toLocaleDateString('ar-EG')}
                          </div>
                        </div>
                      </div>
                    </td>
                    <td className="px-4 py-4">
                      {getRoleBadge(user.role)}
                    </td>
                    <td className="px-4 py-4 space-y-0.5">
                      <div className="flex items-center gap-1.5 text-oqoody-textLight">
                        <Phone className="w-3 h-3 text-oqoody-gold" />
                        <span dir="ltr">{user.phone}</span>
                      </div>
                      <div className="flex items-center gap-1.5 text-oqoody-textMuted text-[11px]">
                        <Mail className="w-3 h-3" />
                        <span>{user.email}</span>
                      </div>
                    </td>
                    <td className="px-4 py-4 text-oqoody-textLight">
                      {user.city || 'القاهرة'}
                    </td>
                    <td className="px-4 py-4">
                      <span className="font-bold text-oqoody-gold text-sm">
                        {(user.walletBalance || 0).toLocaleString()} ج.م
                      </span>
                    </td>
                    <td className="px-4 py-4">
                      <button
                        onClick={() => handleToggleStatus(user)}
                        className={`inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11px] font-bold border transition-colors ${
                          user.isVerified 
                            ? 'bg-oqoody-success/10 text-oqoody-success border-oqoody-success/30 hover:bg-oqoody-success/20' 
                            : 'bg-oqoody-warning/10 text-oqoody-warning border-oqoody-warning/30 hover:bg-oqoody-warning/20'
                        }`}
                      >
                        {user.isVerified ? <CheckCircle2 className="w-3 h-3" /> : <XCircle className="w-3 h-3" />}
                        <span>{user.isVerified ? 'مفعل وموثق' : 'غير موثق'}</span>
                      </button>
                    </td>
                    <td className="px-6 py-4">
                      <div className="flex items-center justify-center gap-2">
                        {/* Edit Role Button */}
                        <button
                          onClick={() => {
                            setEditingUser(user);
                            setNewRole(user.role);
                          }}
                          title="تعديل الرتبة والصلاحيات"
                          className="p-1.5 rounded-lg bg-oqoody-dark hover:bg-oqoody-card border border-oqoody-border text-oqoody-gold transition-colors"
                        >
                          <Edit3 className="w-4 h-4" />
                        </button>
                        {/* Adjust Wallet Balance */}
                        <button
                          onClick={() => {
                            setWalletModalUser(user);
                            setWalletAmount(1000);
                          }}
                          title="شحن أو خصم من المحفظة"
                          className="p-1.5 rounded-lg bg-oqoody-dark hover:bg-oqoody-card border border-oqoody-border text-emerald-400 transition-colors"
                        >
                          <Coins className="w-4 h-4" />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Edit Role Modal */}
      {editingUser && (
        <div className="fixed inset-0 z-50 bg-black/80 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-oqoody-card border border-oqoody-border rounded-2xl p-6 w-full max-w-md shadow-2xl">
            <h3 className="text-base font-bold text-oqoody-textLight mb-2">
              تعديل رتبة وصلاحيات الحساب
            </h3>
            <p className="text-xs text-oqoody-textMuted mb-4">
              المستخدم: <span className="text-oqoody-gold font-bold">{editingUser.fullName}</span>
            </p>

            <div className="space-y-3 mb-6">
              {[
                { role: 'client', label: 'عميل عادي (مستخدم منصة)', desc: 'إنشاء عقود، طلب استشارات، وساطة' },
                { role: 'lawyer', label: 'محامٍ معتمد', desc: 'استقبال استشارات وتقديم استشارات قانونية' },
                { role: 'dispute_agent', label: 'محكّم ومسؤول نزاعات', desc: 'الفصل في النزاعات وإصدار أحكام تحكيم' },
                { role: 'financial_director', label: 'المدير المالي', desc: 'إدارة العمولات والتحويلات البنكية' },
                { role: 'legal_director', label: 'مدير الإدارة القانونية', desc: 'مراجعة نماذج العقود وتوثيق المحامين' },
                { role: 'super_admin', label: 'سوبر أدمن (صلاحيات كاملة)', desc: 'التحكم الإداري الكامل بكل وظائف النظام' },
              ].map((item) => (
                <label 
                  key={item.role} 
                  className={`flex items-start gap-3 p-3 rounded-xl border cursor-pointer transition-all ${
                    newRole === item.role 
                      ? 'bg-oqoody-dark border-oqoody-gold' 
                      : 'bg-oqoody-dark/40 border-oqoody-border hover:border-oqoody-gold/40'
                  }`}
                >
                  <input
                    type="radio"
                    name="roleSelection"
                    checked={newRole === item.role}
                    onChange={() => setNewRole(item.role as UserRole)}
                    className="mt-1 accent-oqoody-gold"
                  />
                  <div>
                    <div className="font-bold text-xs text-oqoody-textLight">{item.label}</div>
                    <div className="text-[11px] text-oqoody-textMuted">{item.desc}</div>
                  </div>
                </label>
              ))}
            </div>

            <div className="flex items-center justify-end gap-3">
              <button
                onClick={() => setEditingUser(null)}
                className="px-4 py-2 rounded-xl text-xs font-semibold bg-oqoody-dark hover:bg-oqoody-border text-oqoody-textMuted transition-colors"
              >
                إلغاء
              </button>
              <button
                onClick={handleSaveRole}
                className="px-5 py-2 rounded-xl text-xs font-bold bg-oqoody-gold hover:bg-oqoody-goldHover text-oqoody-bg shadow-gold-glow transition-all"
              >
                حفظ التعديلات
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Adjust Wallet Modal */}
      {walletModalUser && (
        <div className="fixed inset-0 z-50 bg-black/80 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-oqoody-card border border-oqoody-border rounded-2xl p-6 w-full max-w-sm shadow-2xl">
            <h3 className="text-base font-bold text-oqoody-textLight mb-2 flex items-center gap-2">
              <Coins className="w-5 h-5 text-oqoody-gold" />
              <span>تسوية رصيد المحفظة</span>
            </h3>
            <p className="text-xs text-oqoody-textMuted mb-4">
              الحساب: <span className="text-oqoody-gold font-bold">{walletModalUser.fullName}</span>
              <br />
              الرصيد الحالي: <span className="text-emerald-400 font-bold">{walletModalUser.walletBalance.toLocaleString()} ج.م</span>
            </p>

            <div className="grid grid-cols-2 gap-2 mb-4">
              <button
                type="button"
                onClick={() => setWalletAction('credit')}
                className={`py-2 rounded-xl text-xs font-bold transition-all ${
                  walletAction === 'credit'
                    ? 'bg-oqoody-success text-oqoody-bg shadow-md'
                    : 'bg-oqoody-dark text-oqoody-textMuted border border-oqoody-border'
                }`}
              >
                + شحن وإيداع
              </button>
              <button
                type="button"
                onClick={() => setWalletAction('debit')}
                className={`py-2 rounded-xl text-xs font-bold transition-all ${
                  walletAction === 'debit'
                    ? 'bg-oqoody-danger text-white shadow-md'
                    : 'bg-oqoody-dark text-oqoody-textMuted border border-oqoody-border'
                }`}
              >
                - خصم رصيد
              </button>
            </div>

            <div className="mb-6">
              <label className="block text-xs font-semibold text-oqoody-textMuted mb-1.5">
                المبلغ بالجنيه المصري (EGP)
              </label>
              <input
                type="number"
                min={1}
                value={walletAmount}
                onChange={(e) => setWalletAmount(Number(e.target.value))}
                className="w-full bg-oqoody-dark border border-oqoody-border rounded-xl px-4 py-2.5 text-sm text-oqoody-textLight focus:outline-none focus:border-oqoody-gold"
              />
            </div>

            <div className="flex items-center justify-end gap-3">
              <button
                onClick={() => setWalletModalUser(null)}
                className="px-4 py-2 rounded-xl text-xs font-semibold bg-oqoody-dark hover:bg-oqoody-border text-oqoody-textMuted transition-colors"
              >
                إلغاء
              </button>
              <button
                onClick={handleAdjustWallet}
                className="px-5 py-2 rounded-xl text-xs font-bold bg-oqoody-gold hover:bg-oqoody-goldHover text-oqoody-bg shadow-gold-glow transition-all"
              >
                تنفيذ المعاملة
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

