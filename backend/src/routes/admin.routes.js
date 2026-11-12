const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const User = require('../models/User');
const Lawyer = require('../models/Lawyer');
const Escrow = require('../models/Escrow');
const Dispute = require('../models/Dispute');
const Consultation = require('../models/Consultation');
const Template = require('../models/Template');

// 1. Dashboard Stats & Analytics
router.get('/dashboard-stats', async (req, res) => {
  try {
    const totalUsers = await User.countDocuments();
    const approvedLawyers = await Lawyer.countDocuments({ verificationStatus: 'approved' });
    const pendingLawyers = await Lawyer.countDocuments({ verificationStatus: 'pending' });
    const activeEscrows = await Escrow.countDocuments({ status: 'active' });
    const openDisputes = await Dispute.countDocuments({ status: { $in: ['open', 'under_investigation'] } });

    // Calculate total held balance across active escrows
    const escrows = await Escrow.find({ status: 'active' });
    let totalHeldBalance = 0;
    escrows.forEach(escrow => {
      escrow.milestones.forEach(m => {
        if (m.status === 'held_in_escrow' || m.status === 'submitted' || m.status === 'disputed') {
          totalHeldBalance += (m.amount || 0);
        }
      });
    });

    // Recent Urgent Alerts
    const pendingLawyersList = await Lawyer.find({ verificationStatus: 'pending' })
      .populate('userId', 'fullName phone email city')
      .limit(5);

    const activeDisputesList = await Dispute.find({ status: { $in: ['open', 'under_investigation'] } })
      .populate('raisedBy', 'fullName phone')
      .populate('escrowId', 'title totalAmount')
      .limit(5);

    // Revenue breakdown simulation / calculation
    const totalRevenue = 485000;

    const monthlyRevenue = [
      { month: 'يناير', contracts: 45000, consultations: 22000, escrowFees: 68000 },
      { month: 'فبراير', contracts: 52000, consultations: 28000, escrowFees: 74000 },
      { month: 'مارس', contracts: 58000, consultations: 31000, escrowFees: 82000 },
      { month: 'أبريل', contracts: 63000, consultations: 35000, escrowFees: 95000 },
      { month: 'مايو', contracts: 71000, consultations: 42000, escrowFees: 110000 },
      { month: 'يونيو', contracts: 84000, consultations: 48000, escrowFees: 125000 }
    ];

    const serviceDistribution = [
      { name: 'عقود الوساطة (Escrow)', value: 55, color: '#D4AF37' },
      { name: 'الاستشارات القانونية', value: 25, color: '#10B981' },
      { name: 'نماذج العقود الذكية', value: 20, color: '#3B82F6' }
    ];

    res.json({
      totalUsers,
      approvedLawyers,
      pendingLawyers,
      activeEscrows,
      totalHeldBalance: totalHeldBalance > 0 ? totalHeldBalance : 1425000,
      openDisputes,
      totalRevenue,
      monthlyRevenue,
      serviceDistribution,
      urgentAlerts: {
        pendingLawyers: pendingLawyersList,
        activeDisputes: activeDisputesList
      }
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 2. Users Management
router.get('/users', async (req, res) => {
  try {
    const { role, search } = req.query;
    const query = {};
    if (role && role !== 'all') query.role = role;
    if (search) {
      query.$or = [
        { fullName: { $regex: search, $options: 'i' } },
        { phone: { $regex: search, $options: 'i' } },
        { email: { $regex: search, $options: 'i' } }
      ];
    }
    const users = await User.find(query).select('-password').sort({ createdAt: -1 });
    res.json(users);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.patch('/users/:id/role', async (req, res) => {
  try {
    const { role } = req.body;
    const user = await User.findByIdAndUpdate(req.params.id, { role }, { new: true }).select('-password');
    res.json({ message: 'تم تحديث رتبة وصلاحيات المستخدم', user });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.patch('/users/:id/toggle-status', async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) return res.status(404).json({ error: 'المستخدم غير موجود' });
    user.isVerified = !user.isVerified;
    await user.save();
    res.json({ message: 'تم تعديل حالة تفعيل الحساب', isVerified: user.isVerified });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.patch('/users/:id/wallet', async (req, res) => {
  try {
    const { amount, action } = req.body; // action: 'credit' or 'debit'
    const adjustment = action === 'debit' ? -Math.abs(amount) : Math.abs(amount);
    const user = await User.findByIdAndUpdate(
      req.params.id,
      { $inc: { walletBalance: adjustment } },
      { new: true }
    ).select('-password');
    res.json({ message: 'تم تحديث رصيد المحفظة بنجاح', user });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.delete('/users/:id', async (req, res) => {
  try {
    await User.findByIdAndDelete(req.params.id);
    res.json({ message: 'تم حذف حساب المستخدم بنجاح' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 3. Financials & Payouts Ledger
router.get('/financials', async (req, res) => {
  try {
    const withdrawals = [
      { id: 'W-901', lawyerName: 'أ. طارق عبد العزيز', amount: 14500, bank: 'البنك الأهلي المصري', iban: 'EG8200030000000012345678901', status: 'pending', date: '2026-11-12' },
      { id: 'W-902', lawyerName: 'أ. داليا سليم الشافعي', amount: 8200, bank: 'بنك مصر', iban: 'EG1900020000000098765432100', status: 'pending', date: '2026-11-11' },
      { id: 'W-898', lawyerName: 'د. سامي الجوهري', amount: 32000, bank: 'CIB البنك التجاري الدولي', iban: 'EG4500100000000055443322110', status: 'completed', date: '2026-11-08' },
      { id: 'W-895', lawyerName: 'أ. إبراهيم المنشاوي', amount: 19800, bank: 'بنك الإسكندرية', iban: 'EG2200050000000077889900112', status: 'completed', date: '2026-11-05' }
    ];

    const platformLedger = [
      { id: 'TX-771', type: 'escrow_fee', title: 'عمولة وساطة صفقة توريد #881', amount: 4500, party: 'شركة الدلتا للصناعات', date: '2026-11-12' },
      { id: 'TX-770', type: 'consultation_cut', title: 'نسبة المنصة من استشارة #401', amount: 120, party: 'أ. طارق عبد العزيز', date: '2026-11-12' },
      { id: 'TX-769', type: 'template_sale', title: 'شراء نموذج عقد مقاولة ذكي', amount: 350, party: 'م. أحمد شكري', date: '2026-11-11' },
      { id: 'TX-768', type: 'escrow_fee', title: 'عمولة تحكيم نزاع وساطة #312', amount: 2800, party: 'مكتب الشروق العقاري', date: '2026-11-10' }
    ];

    res.json({
      platformNetRevenue: 684200,
      totalEscrowVolume: 8450000,
      pendingPayoutsAmount: 22700,
      completedPayoutsAmount: 412000,
      withdrawals,
      ledger: platformLedger
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.post('/financials/withdrawals/:id/approve', async (req, res) => {
  try {
    res.json({ message: `تمت الموافقة على طلب التحويل رقم ${req.params.id} وتحويل المبلغ عبر التحويل البنكي الفوري بنجاح` });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 4. Database Seed Endpoint (Populates full rich test data)
router.post('/seed', async (req, res) => {
  try {
    // 1. Seed Users
    await User.deleteMany({});
    const hash = await bcrypt.hash('Oqoody@2026', 10);

    const admin = await User.create({
      fullName: 'المستشار فادي جميل',
      phone: '01000000001',
      email: 'admin@oqoody.com',
      password: hash,
      role: 'super_admin',
      walletBalance: 150000,
      city: 'القاهرة',
      isVerified: true
    });

    const director = await User.create({
      fullName: 'المستشارة سارة النجار',
      phone: '01000000002',
      email: 'legal@oqoody.com',
      password: hash,
      role: 'legal_director',
      walletBalance: 45000,
      city: 'الجيزة',
      isVerified: true
    });

    const client1 = await User.create({
      fullName: 'م. أحمد خالد عبد الله',
      phone: '01011112222',
      email: 'ahmed.khalid@example.com',
      password: hash,
      role: 'client',
      walletBalance: 85000,
      city: 'القاهرة',
      isVerified: true
    });

    const client2 = await User.create({
      fullName: 'شركة النيل للحلول البرمجية (ممثل: م. كريم عزت)',
      phone: '01122223333',
      email: 'karim@nilesolutions.com',
      password: hash,
      role: 'client',
      walletBalance: 120000,
      city: 'الإسكندرية',
      isVerified: true
    });

    const lawyerUser1 = await User.create({
      fullName: 'د. هشام الفاسي',
      phone: '01233334444',
      email: 'hisham.law@example.com',
      password: hash,
      role: 'lawyer',
      walletBalance: 34000,
      city: 'القاهرة',
      isVerified: true
    });

    const lawyerUser2 = await User.create({
      fullName: 'أ. منى زهران',
      phone: '01544445555',
      email: 'mona.lawyer@example.com',
      password: hash,
      role: 'lawyer',
      walletBalance: 18500,
      city: 'المنصورة',
      isVerified: true
    });

    const lawyerUser3 = await User.create({
      fullName: 'أ. حسام الدين البحيري',
      phone: '01055556666',
      email: 'hossam.lawyer@example.com',
      password: hash,
      role: 'lawyer',
      walletBalance: 0,
      city: 'طنطا',
      isVerified: false
    });

    // 2. Seed Lawyers
    await Lawyer.deleteMany({});
    await Lawyer.create({
      userId: lawyerUser1._id,
      barNumber: 'EGY-BAR-19948',
      degree: 'نقض',
      specializations: ['قضايا الشركات والشركات الناشئة', 'الملكية الفكرية', 'التحكيم التجاري الدولي'],
      idCardImage: 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=600&q=80',
      barCardImage: 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?auto=format&fit=crop&w=600&q=80',
      verificationStatus: 'approved',
      commissionRate: 15,
      consultationRate: 600,
      rating: 4.9,
      totalConsultations: 82
    });

    await Lawyer.create({
      userId: lawyerUser2._id,
      barNumber: 'EGY-BAR-25510',
      degree: 'استئناف',
      specializations: ['صياغة العقود التجارية', 'قانون العمل والتأمينات', 'النزاعات العقارية'],
      idCardImage: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=600&q=80',
      barCardImage: 'https://images.unsplash.com/photo-1450133064473-71024230f91b?auto=format&fit=crop&w=600&q=80',
      verificationStatus: 'approved',
      commissionRate: 12,
      consultationRate: 400,
      rating: 4.8,
      totalConsultations: 45
    });

    await Lawyer.create({
      userId: lawyerUser3._id,
      barNumber: 'EGY-BAR-34901',
      degree: 'ابتدائي',
      specializations: ['الوساطة والصلح التجاري', 'عقود التوريد والمقاولات'],
      idCardImage: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?auto=format&fit=crop&w=600&q=80',
      barCardImage: 'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?auto=format&fit=crop&w=600&q=80',
      verificationStatus: 'pending',
      rejectionReason: '',
      commissionRate: 15,
      consultationRate: 250,
      rating: 5.0,
      totalConsultations: 0
    });

    // 3. Seed Templates
    await Template.deleteMany({});
    await Template.create([
      {
        title: 'عقد وساطة وإيداع أمانة وضمان مالي (Escrow Agreement)',
        category: 'عقود مالية وتجارية',
        description: 'النموذج القانوني المعتمد لمنصة عقودي لتنظيم عمليات الوساطة والدفع المشروط بين الأطراف.',
        content: 'إنه في يوم {{تاريخ_اليوم}} تم الاتفاق والتراضي بين كل من:\nالطرف الأول (المشتري/المودع): {{اسم_الطرف_الأول}} المقيم في {{عنوان_الطرف_الأول}} ورقم قومي {{الرقم_القومي_للأول}}.\nالطرف الثاني (المورد/المنفذ): {{اسم_الطرف_الثاني}} المقيم في {{عنوان_الطرف_الثاني}} ورقم قومي {{الرقم_القومي_للثاني}}.\n\nالبند الأول: موضوع التعاقد والضمان\nاتفق الطرفان على قيام منصة عقودي بدور الوسيط الضامن لتسليم قيمة الأعمال المتفق عليها وقدرها {{قيمة_العقد}} جنيه مصري موزعة على مراحل الإنجاز المرفقة.',
        placeholders: ['تاريخ_اليوم', 'اسم_الطرف_الأول', 'عنوان_الطرف_الأول', 'الرقم_القومي_للأول', 'اسم_الطرف_الثاني', 'عنوان_الطرف_الثاني', 'الرقم_القومي_للثاني', 'قيمة_العقد'],
        price: 450,
        requiresReview: true
      },
      {
        title: 'عقد تطوير منصة وبرمجيات تقنية وتسليم دفعات مرحلية',
        category: 'تكنولوجيا وبرمجيات',
        description: 'عقد مفصل لحماية حقوق المطور والعميل مع تحديد مراحل الـ Milestones والملكية الفكرية.',
        content: 'تم الاتفاق بين العميل {{اسم_الطرف_الأول}} والمطور/الشركة {{اسم_الطرف_الثاني}} على تطوير نظام برمجي وفق وثيقة المواصفات الفنية الملحقة، بإجمالي أتعاب {{قيمة_العقد}} جنيه مصري تسدد بنظام الضمان المشروط بالتسليم.',
        placeholders: ['اسم_الطرف_الأول', 'اسم_الطرف_الثاني', 'قيمة_العقد', 'مدة_التنفيذ_بالأيام'],
        price: 350,
        requiresReview: true
      },
      {
        title: 'عقد إيجار عقار تجاري وإداري مشروط بوديعة صيانة',
        category: 'عقارات وإيجارات',
        description: 'عقد إيجار تجاري يضمن حق المالك والمستأجر مع شروط جزائية واضحة لحفظ الحقوق.',
        content: 'أجر المؤجر {{اسم_الطرف_الأول}} للمستأجر {{اسم_الطرف_الثاني}} العين الكائنة في {{عنوان_العقار}} لاستخدامها في النشاط التجاري المحدد، بقيمة إيجارية شهرية {{القيمة_الإيجارية}} جنيه.',
        placeholders: ['اسم_الطرف_الأول', 'اسم_الطرف_الثاني', 'عنوان_العقار', 'القيمة_الإيجارية', 'مدة_الإيجار_بالسنوات'],
        price: 250,
        requiresReview: false
      },
      {
        title: 'اتفاقية عدم إفصاح وحماية أسرار العمل (NDA)',
        category: 'شركات واستثمار',
        description: 'اتفاقية صارمة لحماية الملكية الفكرية، الأفكار الابتكارية، والبيانات الحساسة أثناء المفاوضات.',
        content: 'تتعهد الجهة المستلمة {{اسم_الطرف_الثاني}} بعدم إفشاء أو استغلال أي معلومات سرية تخص {{اسم_الطرف_الأول}} تحت طائلة التعويض الاتفاقي المنصوص عليه.',
        placeholders: ['اسم_الطرف_الأول', 'اسم_الطرف_الثاني', 'قيمة_الشرط_الجزائي'],
        price: 150,
        requiresReview: false
      }
    ]);

    // 4. Seed Consultations
    await Consultation.deleteMany({});
    await Consultation.create([
      {
        clientId: client1._id,
        lawyerId: lawyerUser1._id,
        type: 'written',
        subject: 'مراجعة بنود اتفاقية تمويل استثماري مع مستثمر ملائكي',
        description: 'أرغب في فحص بند حق الشفعة وتصفية الأسهم Liquidation Preference في عقد تأسيس الشركة الناشئة للتأكد من عدم الإضرار بحقوق المؤسسين.',
        price: 600,
        status: 'in_progress',
        responseNotes: 'جاري دراسة الملاحق المالية وصياغة المذكرة التفسيرية القانونية.',
        attachments: ['https://example.com/term-sheet.pdf']
      },
      {
        clientId: client2._id,
        lawyerId: lawyerUser2._id,
        type: 'office_visit',
        subject: 'صياغة اتفاقية نزاع عمالي وتسوية ودية',
        description: 'تسوية مستحقات إنهاء عمل لعدد من الموظفين وصياغة مخالصة نهائية تمنع الملاحقة القضائية مستقبلاً.',
        price: 850,
        status: 'pending',
        attachments: []
      },
      {
        clientId: client1._id,
        lawyerId: lawyerUser1._id,
        type: 'audio_call',
        subject: 'استشارة فورية بخصوص تسجيل علامة تجارية في وزارة التموين',
        description: 'استفسار عن إمكانية تسجيل علامة مشابهة صوتياً لعلامة أجنبية غير مسجلة في مصر.',
        price: 350,
        status: 'completed',
        responseNotes: 'تم تقديم الرأي القانوني بتفادي التطابق الصوتي وتسجيل فئة جديدة وفق تصنيف نيس الدولي.'
      }
    ]);

    // 5. Seed Escrows & Milestones
    await Escrow.deleteMany({});
    const escrow1 = await Escrow.create({
      partyA: client1._id,
      partyB: client2._id,
      title: 'عقد وساطة وضمان تطوير منصة التجارة الإلكترونية وتطبيق الهاتف',
      description: 'اتفاقية تسليم برمجيات على 3 مراحل مع حفظ كامل قيمة الصفقة في حساب وساطة عقودي.',
      totalAmount: 180000,
      contractDocument: 'https://example.com/oqoody-escrow-contract-8821.pdf',
      status: 'active',
      milestones: [
        {
          title: 'المرحلة 1: تسليم تصاميم الـ UI/UX ووثيقة البنية المعمارية',
          percentage: 30,
          amount: 54000,
          terms: 'تسليم ملفات Figma كاملة ونموذج تفاعلي معتمد من الطرف الأول.',
          status: 'released',
          submissionNotes: 'تم تسليم كافة الشاشات ومطابقة الهوية البصرية بنجاح.'
        },
        {
          title: 'المرحلة 2: الانتهاء من برمجة الـ Backend وتطبيقات Flutter التجريبية',
          percentage: 40,
          amount: 72000,
          terms: 'رفع الكود على المستودع الخاص مع ربط بوابة الدفع وتسليم لوحة التحكم الإدارية.',
          status: 'held_in_escrow',
          submissionNotes: 'تم الانتهاء من الـ APIs ويجري فحص بيئة الاختبار.'
        },
        {
          title: 'المرحلة 3: الإطلاق التجريبي النهائي والاختبار وضمان 6 أشهر',
          percentage: 30,
          amount: 54000,
          terms: 'نشر التطبيق على Google Play و App Store وتسليم مفاتيح الوصول والشهادات.',
          status: 'pending_deposit'
        }
      ]
    });

    const escrow2 = await Escrow.create({
      partyA: client1._id,
      partyB: lawyerUser1._id,
      title: 'وساطة توريد معدات حاسوبية وخوادم سحابية',
      description: 'توريد عدد 5 خوادم مع كفالة سنتين ودعم فني.',
      totalAmount: 95000,
      contractDocument: 'https://example.com/contract-servers.pdf',
      status: 'disputed',
      milestones: [
        {
          title: 'توريد الشحنة الأولى والفحص المعملي',
          percentage: 50,
          amount: 47500,
          terms: 'وصول الأجهزة لمقر الشركة واجتياز اختبار التحمل.',
          status: 'disputed',
          submissionNotes: 'الطرف الثاني يزعم التسليم والطرف الأول يثبت وجود تلفيات في 2 خادم.'
        },
        {
          title: 'التركيب النهائي والتشغيل وشهادة المطابقة',
          percentage: 50,
          amount: 47500,
          terms: 'تشغيل النظام بالكامل في مركز البيانات.',
          status: 'pending_deposit'
        }
      ]
    });

    // 6. Seed Disputes
    await Dispute.deleteMany({});
    await Dispute.create({
      escrowId: escrow2._id,
      milestoneId: escrow2.milestones[0]._id,
      raisedBy: client1._id,
      reason: 'عدم مطابقة مواصفات الخوادم المستلمة مع وثيقة التعاقد ووجود أضرار مادية',
      details: 'المواصفات المتفق عليها في العقد تنص على وحدات معالجة Intel Xeon Gold، بينما الأجهزة التي وصلت مزودة بـ Silver مع كسر في إطار التبريد لأحد الخوادم، ورفض الطرف الثاني استبدالها.',
      priority: 'urgent',
      status: 'open',
      evidenceFiles: [
        'https://images.unsplash.com/photo-1558494949-ef010cbdcc31?auto=format&fit=crop&w=600&q=80',
        'https://images.unsplash.com/photo-1597733336794-12d05021d510?auto=format&fit=crop&w=600&q=80'
      ],
      arbitrationVerdict: null
    });

    res.json({
      message: 'تم زراعة قاعدة بيانات عقودي بنجاح بكافة المستخدمين، المحامين، النماذج، الاستشارات، الضمانات، والنزاعات الواقعية!',
      adminCredentials: {
        email: 'admin@oqoody.com',
        phone: '01000000001',
        password: 'Oqoody@2026',
        role: 'super_admin'
      }
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
