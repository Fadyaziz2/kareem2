import React, { useState, useEffect } from 'react';
import { Outlet, useLocation } from 'react-router-dom';
import { Sidebar } from './Sidebar';
import { Header } from './Header';
import { adminApi } from '../services/api';

export const Layout: React.FC = () => {
  const location = useLocation();
  const [urgentLawyers, setUrgentLawyers] = useState(2);
  const [openDisputes, setOpenDisputes] = useState(1);

  useEffect(() => {
    adminApi.getDashboardStats().then(stats => {
      setUrgentLawyers(stats.pendingLawyers || 0);
      setOpenDisputes(stats.openDisputes || 0);
    }).catch(() => {});
  }, [location.pathname]);

  const getPageMeta = (pathname: string) => {
    switch (pathname) {
      case '/': 
        return { title: 'الرئيسية والتحليلات الشاملة', subtitle: 'مؤشرات الأداء الرئيسية والعمليات النشطة على منصة عقودي' };
      case '/users': 
        return { title: 'إدارة المستخدمين والأعضاء', subtitle: 'سجل العملاء، المحامين، وتعديل الرتب وصلاحيات الإدارة' };
      case '/lawyers': 
        return { title: 'دليل وتوثيق المحامين', subtitle: 'فحص بطاقات القيد بالنقابة والدرجات القضائية واعتماد الطلبات' };
      case '/templates': 
        return { title: 'محرر ونماذج العقود الذكية', subtitle: 'إدارة بنود العقود، الحقول المتغيرة {{placeholders}} والتسعير' };
      case '/consultations': 
        return { title: 'مراقبة الاستشارات القانونية', subtitle: 'متابعة الاستشارات المكتوبة والمكالمات وإعادة تعيين المحامين' };
      case '/escrow': 
        return { title: 'إدارة الوساطة وحساب الضمان Escrow', subtitle: 'مراقبة صفقات الدفع المشروط، تحرير الدفعات وتجميد العمليات' };
      case '/disputes': 
        return { title: 'غرفة التحكيم وفض النزاعات', subtitle: 'جلسات التحكيم الرقمية، فحص الأدلة وإصدار الأحكام التنفيذية' };
      case '/financials': 
        return { title: 'المالية وعمولات المنصة', subtitle: 'سجل العمولات، إدارة أرصدة المحافظ، والموافقة على سحب الأرباح' };
      default: 
        return { title: 'لوحة التحكم الإدارية', subtitle: 'منصة عقودي الرقمية' };
    }
  };

  const meta = getPageMeta(location.pathname);

  return (
    <div className="flex min-h-screen bg-oqoody-bg text-oqoody-textLight">
      {/* Right Sidebar for RTL */}
      <Sidebar urgentLawyersCount={urgentLawyers} openDisputesCount={openDisputes} />

      {/* Main Content Area */}
      <div className="flex-1 flex flex-col min-w-0">
        <Header title={meta.title} subtitle={meta.subtitle} />
        <main className="flex-1 p-8 overflow-y-auto">
          <Outlet />
        </main>
      </div>
    </div>
  );
};

