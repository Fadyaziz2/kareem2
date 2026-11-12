import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { Lock, Mail, ShieldAlert, Sparkles, Scale, ArrowLeft } from 'lucide-react';

export const Login: React.FC = () => {
  const [emailOrPhone, setEmailOrPhone] = useState('admin@oqoody.com');
  const [password, setPassword] = useState('Oqoody@2026');
  const [error, setError] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const { login } = useAuth();
  const navigate = useNavigate();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setIsLoading(true);

    try {
      await login(emailOrPhone, password);
      navigate('/');
    } catch (err: any) {
      setError(err?.response?.data?.error || err.message || 'بيانات الدخول غير صحيحة');
    } finally {
      setIsLoading(false);
    }
  };

  const handleQuickDemo = (email: string, pass: string) => {
    setEmailOrPhone(email);
    setPassword(pass);
  };

  return (
    <div className="min-h-screen bg-oqoody-bg flex items-center justify-center p-6 relative overflow-hidden">
      {/* Background ambient luxury glow */}
      <div className="absolute top-1/4 -right-20 w-96 h-96 bg-oqoody-card/60 rounded-full blur-3xl pointer-events-none" />
      <div className="absolute bottom-1/4 -left-20 w-96 h-96 bg-oqoody-gold/10 rounded-full blur-3xl pointer-events-none" />

      <div className="w-full max-w-md bg-oqoody-dark/95 border border-oqoody-border rounded-3xl p-8 shadow-2xl backdrop-blur-xl relative z-10">
        {/* Emblem & Branding */}
        <div className="text-center mb-8">
          <div className="w-20 h-20 mx-auto mb-4 rounded-2xl bg-oqoody-card border-2 border-oqoody-gold/40 flex items-center justify-center shadow-gold-glow">
            <svg className="w-12 h-12" viewBox="0 0 200 200">
              <rect width="200" height="200" rx="40" fill="#0D2818"/>
              <path d="M100 35 L100 155 M60 155 L140 155 M50 70 L150 70 M50 70 L35 110 C35 120 65 120 65 110 Z M150 70 L135 110 C135 120 165 120 165 110 Z" 
                    stroke="#D4AF37" strokeWidth="8" fill="none" strokeLinecap="round" strokeLinejoin="round"/>
            </svg>
          </div>
          <h1 className="text-2xl font-black text-oqoody-textLight tracking-tight">
            عقودي <span className="text-oqoody-gold">Oqoody</span>
          </h1>
          <p className="text-xs text-oqoody-textMuted mt-1">بوابة الإدارة والتحكيم القانوني المشفر</p>
        </div>

        {error && (
          <div className="mb-6 p-3.5 rounded-xl bg-oqoody-danger/10 border border-oqoody-danger/30 text-oqoody-danger text-xs flex items-center gap-2">
            <ShieldAlert className="w-4 h-4 flex-shrink-0" />
            <span>{error}</span>
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-xs font-semibold text-oqoody-textMuted mb-1.5">
              البريد الإلكتروني أو الهاتف المسجل
            </label>
            <div className="relative">
              <input
                type="text"
                required
                value={emailOrPhone}
                onChange={(e) => setEmailOrPhone(e.target.value)}
                placeholder="admin@oqoody.com"
                className="w-full bg-oqoody-card border border-oqoody-border rounded-xl px-4 py-3 pl-10 text-sm text-oqoody-textLight focus:outline-none focus:border-oqoody-gold transition-colors"
              />
              <Mail className="w-4 h-4 text-oqoody-textMuted absolute left-3 top-3.5" />
            </div>
          </div>

          <div>
            <label className="block text-xs font-semibold text-oqoody-textMuted mb-1.5">
              كلمة المرور
            </label>
            <div className="relative">
              <input
                type="password"
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="••••••••"
                className="w-full bg-oqoody-card border border-oqoody-border rounded-xl px-4 py-3 pl-10 text-sm text-oqoody-textLight focus:outline-none focus:border-oqoody-gold transition-colors"
              />
              <Lock className="w-4 h-4 text-oqoody-textMuted absolute left-3 top-3.5" />
            </div>
          </div>

          <button
            type="submit"
            disabled={isLoading}
            className="w-full mt-2 py-3.5 px-4 rounded-xl font-bold text-sm bg-oqoody-gold hover:bg-oqoody-goldHover text-oqoody-bg shadow-gold-glow transition-all duration-200 flex items-center justify-center gap-2 disabled:opacity-50"
          >
            {isLoading ? (
              <span className="w-5 h-5 border-2 border-oqoody-bg border-t-transparent rounded-full animate-spin" />
            ) : (
              <>
                <span>تسجيل الدخول الآمن</span>
                <ArrowLeft className="w-4 h-4" />
              </>
            )}
          </button>
        </form>

        {/* Quick Demo Access Bar */}
        <div className="mt-8 pt-6 border-t border-oqoody-border">
          <div className="text-[11px] font-semibold text-oqoody-textMuted text-center mb-3 flex items-center justify-center gap-1">
            <Sparkles className="w-3 h-3 text-oqoody-gold" />
            <span>حسابات تجريبية سريعة للاختبار:</span>
          </div>
          <div className="grid grid-cols-2 gap-2">
            <button
              type="button"
              onClick={() => handleQuickDemo('admin@oqoody.com', 'Oqoody@2026')}
              className="px-2.5 py-1.5 rounded-lg bg-oqoody-card hover:bg-oqoody-border text-oqoody-textLight text-[11px] border border-oqoody-border transition-colors text-right"
            >
              👑 سوبر أدمن (مدير عام)
            </button>
            <button
              type="button"
              onClick={() => handleQuickDemo('disputes@oqoody.com', 'Oqoody@2026')}
              className="px-2.5 py-1.5 rounded-lg bg-oqoody-card hover:bg-oqoody-border text-oqoody-textLight text-[11px] border border-oqoody-border transition-colors text-right"
            >
              ⚖️ مسؤول غرفة التحكيم
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

