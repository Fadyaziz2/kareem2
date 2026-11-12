const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const path = require('path');
const bcrypt = require('bcryptjs');
require('dotenv').config();

const authRoutes = require('./routes/auth.routes');
const lawyerRoutes = require('./routes/lawyer.routes');
const templateRoutes = require('./routes/template.routes');
const contractRoutes = require('./routes/contract.routes');
const consultationRoutes = require('./routes/consultation.routes');
const escrowRoutes = require('./routes/escrow.routes');
const disputeRoutes = require('./routes/dispute.routes');
const paymentRoutes = require('./routes/payment.routes');
const walletRoutes = require('./routes/wallet.routes');
const adminRoutes = require('./routes/admin.routes');

const User = require('./models/User');
const Template = require('./models/Template');
const Lawyer = require('./models/Lawyer');

const app = express();
app.use(cors());
app.use(express.json());
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// Register Routes
app.use('/api/auth', authRoutes);
app.use('/api/lawyers', lawyerRoutes);
app.use('/api/templates', templateRoutes);
app.use('/api/contracts', contractRoutes);
app.use('/api/consultations', consultationRoutes);
app.use('/api/escrow', escrowRoutes);
app.use('/api/disputes', disputeRoutes);
app.use('/api/payments', paymentRoutes);
app.use('/api/wallet', walletRoutes);
app.use('/api/admin', adminRoutes);

app.get('/', (req, res) => res.json({ 
  status: 'OK', 
  platform: 'Oqoody - عقودي للوساطة والتوثيق القانوني',
  version: '2.0.0'
}));

// Automatic Seeder Function
async function autoSeedDatabase() {
  try {
    // 1. Seed Super Admin if no user exists
    const adminExists = await User.findOne({ email: 'admin@oqoody.com' });
    if (!adminExists) {
      const hashedPass = await bcrypt.hash('Admin@123456', 10);
      await User.create({
        fullName: 'المستشار العام (مدير المنصة)',
        phone: '01000000001',
        email: 'admin@oqoody.com',
        password: hashedPass,
        role: 'super_admin',
        walletBalance: 250000,
        city: 'القاهرة',
        isVerified: true
      });
      console.log('✅ Auto-seeded Default Super Admin: admin@oqoody.com / Admin@123456');
    }

    // 2. Seed Sample Lawyers if empty
    const lawyersCount = await Lawyer.countDocuments();
    if (lawyersCount === 0) {
      const hashedPass = await bcrypt.hash('Oqoody@2026', 10);
      const lawyerUser1 = await User.create({
        fullName: 'د. هشام الفاسي',
        phone: '01233334444',
        email: 'hisham.law@oqoody.com',
        password: hashedPass,
        role: 'lawyer',
        walletBalance: 45000,
        city: 'القاهرة',
        isVerified: true
      });

      await Lawyer.create({
        userId: lawyerUser1._id,
        barNumber: 'EGY-BAR-19948',
        degree: 'نقض',
        specializations: ['قضايا الشركات', 'الملكية الفكرية', 'التحكيم التجاري'],
        bio: 'محامٍ ومحكّم معتمد مقيد أمام محكمة النقض بخبرة تزيد عن 18 عاماً في العقود الاستثمارية.',
        consultationRate: 500,
        commissionRate: 15,
        rating: 4.9,
        totalConsultations: 48,
        verificationStatus: 'approved'
      });

      const lawyerUser2 = await User.create({
        fullName: 'أ. منى زهران',
        phone: '01544445555',
        email: 'mona.law@oqoody.com',
        password: hashedPass,
        role: 'lawyer',
        walletBalance: 28000,
        city: 'الإسكندرية',
        isVerified: true
      });

      await Lawyer.create({
        userId: lawyerUser2._id,
        barNumber: 'EGY-BAR-25510',
        degree: 'استئناف',
        specializations: ['صياغة العقود التجارية', 'قانون العمل', 'النزاعات العقارية'],
        bio: 'مستشارة قانونية متخصصة في عقود التوريد والمقاولات والوساطة التجارية.',
        consultationRate: 350,
        commissionRate: 15,
        rating: 4.8,
        totalConsultations: 32,
        verificationStatus: 'approved'
      });
      console.log('✅ Auto-seeded 2 Sample Verified Lawyers');
    }

    // 3. Seed 3 Sample Arabic Contract Templates with full Variables
    const templatesCount = await Template.countDocuments();
    if (templatesCount === 0) {
      await Template.create([
        {
          title: 'عقد وساطة وإيداع أمانة وضمان مالي (Escrow Agreement)',
          category: 'عقود مالية وتجارية',
          description: 'النموذج القانوني المعتمد لمنصة عقودي لتنظيم عمليات الوساطة والدفع المشروط بين الأطراف.',
          content: `إنه في يوم {{تاريخ_اليوم}} تم الاتفاق والتراضي بين كل من:
الطرف الأول (المشتري/المودع): {{اسم_الطرف_الأول}} المقيم في {{عنوان_الطرف_الأول}} ورقم قومي {{الرقم_القومي_للأول}}.
الطرف الثاني (المورد/المنفذ): {{اسم_الطرف_الثاني}} المقيم في {{عنوان_الطرف_الثاني}} ورقم قومي {{الرقم_القومي_للثاني}}.

البند الأول: موضوع التعاقد والضمان
اتفق الطرفان على قيام منصة عقودي بدور الوسيط الضامن لتسليم قيمة الأعمال المتفق عليها وقدرها {{قيمة_العقد}} جنيه مصري، على أن تصرف الدفعات وفق مراحل الإنجاز المحددة بنظام الوساطة.

البند الثاني: الاختصاص القضائي وفض النزاعات
يخضع هذا العقد لأحكام القانون المصري، وفي حالة نشوء أي خلاف يتم اللجوء إلى غرفة التحكيم الرقمية لمنصة عقودي ويكون حكمها باتاً وملزماً للطرفين.`,
          autoGeneratePrice: 150,
          lawyerReviewPrice: 450,
          price: 150,
          requiresReview: true,
          variables: [
            { name: 'تاريخ_اليوم', label: 'تاريخ إبرام العقد', type: 'date', required: true, defaultValue: '2026-11-12' },
            { name: 'اسم_الطرف_الأول', label: 'اسم الطرف الأول (المشتري/المودع)', type: 'text', required: true, defaultValue: '' },
            { name: 'عنوان_الطرف_الأول', label: 'عنوان الطرف الأول', type: 'text', required: true, defaultValue: 'القاهرة' },
            { name: 'الرقم_القومي_للأول', label: 'الرقم القومي للطرف الأول', type: 'text', required: true, defaultValue: '' },
            { name: 'اسم_الطرف_الثاني', label: 'اسم الطرف الثاني (المورد/المنفذ)', type: 'text', required: true, defaultValue: '' },
            { name: 'عنوان_الطرف_الثاني', label: 'عنوان الطرف الثاني', type: 'text', required: true, defaultValue: 'الإسكندرية' },
            { name: 'الرقم_القومي_للثاني', label: 'الرقم القومي للطرف الثاني', type: 'text', required: true, defaultValue: '' },
            { name: 'قيمة_العقد', label: 'إجمالي قيمة العقد (بالجنيه المصري)', type: 'number', required: true, defaultValue: '50000' }
          ]
        },
        {
          title: 'عقد تطوير منصة وبرمجيات تقنية وتسليم دفعات مرحلية',
          category: 'تكنولوجيا وبرمجيات',
          description: 'عقد مفصل لحماية حقوق المطور والعميل مع تحديد مراحل الـ Milestones والملكية الفكرية.',
          content: `تم الاتفاق في يوم {{تاريخ_اليوم}} بين العميل {{اسم_الطرف_الأول}} ورقم قومي {{الرقم_القومي_للأول}}، والشركة المنفذة {{اسم_الطرف_الثاني}}، على تطوير وتنفيذ النظام البرمجي بنوع تقنية {{نوع_التطبيق}}، بإجمالي أتعاب {{قيمة_العقد}} جنيه مصري ومدة تنفيذ قدرها {{مدة_التنفيذ_بالأيام}} يوماً.

البند الأول: مراحل التسليم والدفع المشروط
تودع قيمة العقد في حساب وساطة عقودي، ولا تحرر أي دفعة إلا بعد اجتياز فحص ومصادقة الطرف الأول.

البند الثاني: الملكية الفكرية
تؤول كافة حقوق الملكية الفكرية والأكواد المصدرية للطرف الأول بمجرد تحرير الدفعة المالية النهائية.`,
          autoGeneratePrice: 200,
          lawyerReviewPrice: 500,
          price: 200,
          requiresReview: true,
          variables: [
            { name: 'تاريخ_اليوم', label: 'تاريخ التوقيع', type: 'date', required: true, defaultValue: '2026-11-12' },
            { name: 'اسم_الطرف_الأول', label: 'اسم العميل / طالب الخدمة', type: 'text', required: true, defaultValue: '' },
            { name: 'الرقم_القومي_للأول', label: 'الرقم القومي للعميل', type: 'text', required: true, defaultValue: '' },
            { name: 'اسم_الطرف_الثاني', label: 'اسم المطور أو الشركة المنفذة', type: 'text', required: true, defaultValue: '' },
            { name: 'نوع_التطبيق', label: 'نوع النظام التقني', type: 'select', options: ['تطبيق هاتف (iOS & Android)', 'منصة ويب متكاملة (Web Platform)', 'نظام إدارة موارد الشركات (ERP)'], required: true, defaultValue: 'تطبيق هاتف (iOS & Android)' },
            { name: 'قيمة_العقد', label: 'القيمة الإجمالية للمشروع (ج.م)', type: 'number', required: true, defaultValue: '80000' },
            { name: 'مدة_التنفيذ_بالأيام', label: 'مدة التنفيذ الكلية (بالأيام)', type: 'number', required: true, defaultValue: '60' }
          ]
        },
        {
          title: 'عقد إيجار عقار تجاري وإداري مشروط بوديعة صيانة',
          category: 'عقارات وإيجارات',
          description: 'عقد إيجار تجاري يضمن حق المالك والمستأجر مع شروط جزائية واضحة لحفظ الحقوق.',
          content: `أجر المؤجر {{اسم_الطرف_الأول}} بطاقة قومية {{الرقم_القومي_للأول}} للمستأجر {{اسم_الطرف_الثاني}} بطاقة قومية {{الرقم_القومي_للثاني}} العين الكائنة في: {{عنوان_العقار}}، لاستخدامها في الغرض التجاري المحدد، بقيمة إيجارية شهرية قدرها {{القيمة_الإيجارية}} جنيه مصري ولمدة {{مدة_الإيجار_بالسنوات}} سنوات تبدأ من تاريخ {{تاريخ_اليوم}}.

البند الأول: التأمين والوديعة
يلتزم المستأجر بسداد مبلغ تأمين يعادل شهرين يودع في حساب الضمان المشروط.`,
          autoGeneratePrice: 150,
          lawyerReviewPrice: 350,
          price: 150,
          requiresReview: false,
          variables: [
            { name: 'تاريخ_اليوم', label: 'تاريخ بدء الإيجار', type: 'date', required: true, defaultValue: '2026-11-12' },
            { name: 'اسم_الطرف_الأول', label: 'اسم المالك المؤجر', type: 'text', required: true, defaultValue: '' },
            { name: 'الرقم_القومي_للأول', label: 'الرقم القومي للمؤجر', type: 'text', required: true, defaultValue: '' },
            { name: 'اسم_الطرف_الثاني', label: 'اسم المستأجر', type: 'text', required: true, defaultValue: '' },
            { name: 'الرقم_القومي_للثاني', label: 'الرقم القومي للمستأجر', type: 'text', required: true, defaultValue: '' },
            { name: 'عنوان_العقار', label: 'عنوان ووصف العين المؤجرة بالتفصيل', type: 'text', required: true, defaultValue: 'ش النيل - الدقي - الجيزة' },
            { name: 'القيمة_الإيجارية', label: 'القيمة الإيجارية الشهرية (ج.م)', type: 'number', required: true, defaultValue: '12000' },
            { name: 'مدة_الإيجار_بالسنوات', label: 'مدة العقد بالسنوات', type: 'select', options: ['سنة واحدة', 'سنتان', '3 سنوات', '5 سنوات'], required: true, defaultValue: 'سنتان' }
          ]
        }
      ]);
      console.log('✅ Auto-seeded 3 Arabic Dynamic Contract Templates with Form Variables');
    }
  } catch (err) {
    console.error('Auto-seed error:', err.message);
  }
}

const PORT = process.env.PORT || 5003;
const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/oqoody_db';

mongoose.connect(MONGO_URI)
  .then(() => {
    console.log('MongoDB Connected to Oqoody Database');
    autoSeedDatabase();
    app.listen(PORT, () => console.log(`Oqoody Server running on port ${PORT}`));
  })
  .catch(err => {
    console.warn('MongoDB connection note (fallback available if DB offline):', err.message);
    app.listen(PORT, () => console.log(`Oqoody Server running on port ${PORT} (Offline DB mode)`));
  });
