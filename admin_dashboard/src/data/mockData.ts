import { 
  User, 
  Lawyer, 
  Template, 
  Consultation, 
  Escrow, 
  Dispute, 
  DashboardStats,
  FinancialStats
} from '../types';

export const mockCurrentUser: User = {
  _id: 'usr-admin-01',
  fullName: 'المستشار فادي جميل',
  phone: '01000000001',
  email: 'admin@oqoody.com',
  role: 'super_admin',
  walletBalance: 154000,
  city: 'القاهرة',
  isVerified: true,
  createdAt: '2026-01-10T10:00:00.000Z'
};

export const mockUsers: User[] = [
  mockCurrentUser,
  {
    _id: 'usr-admin-02',
    fullName: 'المستشارة سارة النجار',
    phone: '01000000002',
    email: 'legal@oqoody.com',
    role: 'legal_director',
    walletBalance: 45000,
    city: 'الجيزة',
    isVerified: true,
    createdAt: '2026-01-15T12:00:00.000Z'
  },
  {
    _id: 'usr-agent-01',
    fullName: 'أ. مروان القاضي',
    phone: '01000000003',
    email: 'disputes@oqoody.com',
    role: 'dispute_agent',
    walletBalance: 28000,
    city: 'القاهرة',
    isVerified: true,
    createdAt: '2026-02-01T14:30:00.000Z'
  },
  {
    _id: 'usr-client-01',
    fullName: 'م. أحمد خالد عبد الله',
    phone: '01011112222',
    email: 'ahmed.khalid@example.com',
    role: 'client',
    walletBalance: 85000,
    city: 'القاهرة',
    isVerified: true,
    createdAt: '2026-02-12T09:15:00.000Z'
  },
  {
    _id: 'usr-client-02',
    fullName: 'شركة النيل للحلول البرمجية (كريم عزت)',
    phone: '01122223333',
    email: 'karim@nilesolutions.com',
    role: 'client',
    walletBalance: 120000,
    city: 'الإسكندرية',
    isVerified: true,
    createdAt: '2026-03-01T11:00:00.000Z'
  },
  {
    _id: 'usr-lawyer-01',
    fullName: 'د. هشام الفاسي',
    phone: '01233334444',
    email: 'hisham.law@example.com',
    role: 'lawyer',
    walletBalance: 34000,
    city: 'القاهرة',
    isVerified: true,
    createdAt: '2026-01-20T10:00:00.000Z'
  },
  {
    _id: 'usr-lawyer-02',
    fullName: 'أ. منى زهران',
    phone: '01544445555',
    email: 'mona.lawyer@example.com',
    role: 'lawyer',
    walletBalance: 18500,
    city: 'المنصورة',
    isVerified: true,
    createdAt: '2026-02-18T16:20:00.000Z'
  },
  {
    _id: 'usr-lawyer-03',
    fullName: 'أ. حسام الدين البحيري',
    phone: '01055556666',
    email: 'hossam.lawyer@example.com',
    role: 'lawyer',
    walletBalance: 0,
    city: 'طنطا',
    isVerified: false,
    createdAt: '2026-11-09T08:00:00.000Z'
  },
  {
    _id: 'usr-lawyer-04',
    fullName: 'أ. ريم عبد الوهاب',
    phone: '01099998888',
    email: 'reem.law@example.com',
    role: 'lawyer',
    walletBalance: 0,
    city: 'القاهرة',
    isVerified: false,
    createdAt: '2026-11-11T13:45:00.000Z'
  }
];

export const mockLawyers: Lawyer[] = [
  {
    _id: 'law-01',
    userId: mockUsers[5],
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
  },
  {
    _id: 'law-02',
    userId: mockUsers[6],
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
  },
  {
    _id: 'law-03',
    userId: mockUsers[7],
    barNumber: 'EGY-BAR-34901',
    degree: 'ابتدائي',
    specializations: ['الوساطة والصلح التجاري', 'عقود التوريد والمقاولات'],
    idCardImage: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?auto=format&fit=crop&w=600&q=80',
    barCardImage: 'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?auto=format&fit=crop&w=600&q=80',
    verificationStatus: 'pending',
    commissionRate: 15,
    consultationRate: 250,
    rating: 5.0,
    totalConsultations: 0
  },
  {
    _id: 'law-04',
    userId: mockUsers[8],
    barNumber: 'EGY-BAR-41209',
    degree: 'استئناف',
    specializations: ['القضايا الجنائية الاقتصادية', 'الجرائم الإلكترونية'],
    idCardImage: 'https://images.unsplash.com/photo-1580489944761-15a19d654956?auto=format&fit=crop&w=600&q=80',
    barCardImage: 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=600&q=80',
    verificationStatus: 'pending',
    commissionRate: 15,
    consultationRate: 500,
    rating: 4.9,
    totalConsultations: 0
  }
];

export const mockTemplates: Template[] = [
  {
    _id: 'tmpl-01',
    title: 'عقد وساطة وإيداع أمانة وضمان مالي (Escrow Agreement)',
    category: 'عقود مالية وتجارية',
    description: 'النموذج القانوني المعتمد لمنصة عقودي لتنظيم عمليات الوساطة والدفع المشروط بين الأطراف.',
    content: `إنه في يوم {{تاريخ_اليوم}} تم الاتفاق والتراضي بين كل من:
الطرف الأول (المشتري/المودع): {{اسم_الطرف_الأول}} المقيم في {{عنوان_الطرف_الأول}} ورقم قومي {{الرقم_القومي_للأول}}.
الطرف الثاني (المورد/المنفذ): {{اسم_الطرف_الثاني}} المقيم في {{عنوان_الطرف_الثاني}} ورقم قومي {{الرقم_القومي_للثاني}}.

البند الأول: موضوع التعاقد والضمان
اتفق الطرفان على قيام منصة عقودي بدور الوسيط الضامن لتسليم قيمة الأعمال المتفق عليها وقدرها {{قيمة_العقد}} جنيه مصري موزعة على مراحل الإنجاز المرفقة.`,
    placeholders: ['تاريخ_اليوم', 'اسم_الطرف_الأول', 'عنوان_الطرف_الأول', 'الرقم_القومي_للأول', 'اسم_الطرف_الثاني', 'عنوان_الطرف_الثاني', 'الرقم_القومي_للثاني', 'قيمة_العقد'],
    price: 450,
    requiresReview: true,
    createdAt: '2026-01-20T10:00:00.000Z'
  },
  {
    _id: 'tmpl-02',
    title: 'عقد تطوير منصة وبرمجيات تقنية وتسليم دفعات مرحلية',
    category: 'تكنولوجيا وبرمجيات',
    description: 'عقد مفصل لحماية حقوق المطور والعميل مع تحديد مراحل الـ Milestones والملكية الفكرية.',
    content: `تم الاتفاق بين العميل {{اسم_الطرف_الأول}} والمطور/الشركة {{اسم_الطرف_الثاني}} على تطوير نظام برمجي وفق وثيقة المواصفات الفنية الملحقة، بإجمالي أتعاب {{قيمة_العقد}} جنيه مصري تسدد بنظام الضمان المشروط بالتسليم.`,
    placeholders: ['اسم_الطرف_الأول', 'اسم_الطرف_الثاني', 'قيمة_العقد', 'مدة_التنفيذ_بالأيام'],
    price: 350,
    requiresReview: true,
    createdAt: '2026-02-05T12:00:00.000Z'
  },
  {
    _id: 'tmpl-03',
    title: 'عقد إيجار عقار تجاري وإداري مشروط بوديعة صيانة',
    category: 'عقارات وإيجارات',
    description: 'عقد إيجار تجاري يضمن حق المالك والمستأجر مع شروط جزائية واضحة لحفظ الحقوق.',
    content: `أجر المؤجر {{اسم_الطرف_الأول}} للمستأجر {{اسم_الطرف_الثاني}} العين الكائنة في {{عنوان_العقار}} لاستخدامها في النشاط التجاري المحدد، بقيمة إيجارية شهرية {{القيمة_الإيجارية}} جنيه.`,
    placeholders: ['اسم_الطرف_الأول', 'اسم_الطرف_الثاني', 'عنوان_العقار', 'القيمة_الإيجارية', 'مدة_الإيجار_بالسنوات'],
    price: 250,
    requiresReview: false,
    createdAt: '2026-02-15T15:30:00.000Z'
  },
  {
    _id: 'tmpl-04',
    title: 'اتفاقية عدم إفصاح وحماية أسرار العمل (NDA)',
    category: 'شركات واستثمار',
    description: 'اتفاقية صارمة لحماية الملكية الفكرية، الأفكار الابتكارية، والبيانات الحساسة أثناء المفاوضات.',
    content: `تتعهد الجهة المستلمة {{اسم_الطرف_الثاني}} بعدم إفشاء أو استغلال أي معلومات سرية تخص {{اسم_الطرف_الأول}} تحت طائلة التعويض الاتفاقي المنصوص عليه وقدره {{قيمة_الشرط_الجزائي}} جنيه.`,
    placeholders: ['اسم_الطرف_الأول', 'اسم_الطرف_الثاني', 'قيمة_الشرط_الجزائي'],
    price: 150,
    requiresReview: false,
    createdAt: '2026-03-01T08:00:00.000Z'
  }
];

export const mockConsultations: Consultation[] = [
  {
    _id: 'cns-01',
    clientId: mockUsers[3],
    lawyerId: mockUsers[5],
    type: 'written',
    subject: 'مراجعة بنود اتفاقية تمويل استثماري مع مستثمر ملائكي',
    description: 'أرغب في فحص بند حق الشفعة وتصفية الأسهم Liquidation Preference في عقد تأسيس الشركة الناشئة للتأكد من عدم الإضرار بحقوق المؤسسين.',
    price: 600,
    status: 'in_progress',
    responseNotes: 'جاري دراسة الملاحق المالية وصياغة المذكرة التفسيرية القانونية ومقارنتها بنظام الشركات المصري 2026.',
    attachments: ['term-sheet-investment.pdf'],
    createdAt: '2026-11-10T14:00:00.000Z'
  },
  {
    _id: 'cns-02',
    clientId: mockUsers[4],
    lawyerId: mockUsers[6],
    type: 'office_visit',
    subject: 'صياغة اتفاقية تسوية نزاع عمالي ومخالصة نهائية',
    description: 'تسوية مستحقات إنهاء عمل لعدد من الموظفين وصياغة مخالصة نهائية تمنع الملاحقة القضائية مستقبلاً.',
    price: 850,
    status: 'pending',
    attachments: ['settlement-draft.docx'],
    createdAt: '2026-11-12T09:30:00.000Z'
  },
  {
    _id: 'cns-03',
    clientId: mockUsers[3],
    lawyerId: mockUsers[5],
    type: 'audio_call',
    subject: 'استشارة فورية بخصوص تسجيل علامة تجارية في وزارة التموين',
    description: 'استفسار عن إمكانية تسجيل علامة مشابهة صوتياً لعلامة أجنبية غير مسجلة في مصر.',
    price: 350,
    status: 'completed',
    responseNotes: 'تم تقديم الرأي القانوني بتفادي التطابق الصوتي وتسجيل فئة جديدة وفق تصنيف نيس الدولي لحماية الاسم التجاري.',
    createdAt: '2026-11-08T11:15:00.000Z'
  }
];

export const mockEscrows: Escrow[] = [
  {
    _id: 'esc-01',
    partyA: mockUsers[3],
    partyB: mockUsers[4],
    title: 'عقد وساطة وضمان تطوير منصة التجارة الإلكترونية وتطبيق الهاتف',
    description: 'اتفاقية تسليم برمجيات على 3 مراحل مع حفظ كامل قيمة الصفقة في حساب وساطة منصة عقودي.',
    totalAmount: 180000,
    contractDocument: 'https://oqoody.com/contracts/escrow-8821.pdf',
    status: 'active',
    createdAt: '2026-10-15T10:00:00.000Z',
    milestones: [
      {
        _id: 'ms-01',
        title: 'المرحلة 1: تسليم تصاميم الـ UI/UX ووثيقة البنية المعمارية',
        percentage: 30,
        amount: 54000,
        terms: 'تسليم ملفات Figma كاملة ونموذج تفاعلي معتمد من الطرف الأول.',
        status: 'released',
        submissionNotes: 'تم تسليم كافة الشاشات ومطابقة الهوية البصرية بنجاح وتم فك الحجز المالي.'
      },
      {
        _id: 'ms-02',
        title: 'المرحلة 2: الانتهاء من برمجة الـ Backend وتطبيقات Flutter التجريبية',
        percentage: 40,
        amount: 72000,
        terms: 'رفع الكود على المستودع الخاص مع ربط بوابة الدفع وتسليم لوحة التحكم الإدارية.',
        status: 'held_in_escrow',
        submissionNotes: 'تم الانتهاء من الـ APIs ويجري فحص بيئة الاختبار QA.'
      },
      {
        _id: 'ms-03',
        title: 'المرحلة 3: الإطلاق التجريبي النهائي والاختبار وضمان 6 أشهر',
        percentage: 30,
        amount: 54000,
        terms: 'نشر التطبيق على Google Play و App Store وتسليم مفاتيح الوصول والشهادات.',
        status: 'pending_deposit'
      }
    ]
  },
  {
    _id: 'esc-02',
    partyA: mockUsers[3],
    partyB: mockUsers[5],
    title: 'وساطة توريد معدات حاسوبية وخوادم سحابية لمركز البيانات',
    description: 'توريد عدد 5 خوادم عالية الكفاءة مع كفالة سنتين ودعم فني.',
    totalAmount: 95000,
    contractDocument: 'https://oqoody.com/contracts/servers-9912.pdf',
    status: 'disputed',
    createdAt: '2026-10-28T14:30:00.000Z',
    milestones: [
      {
        _id: 'ms-04',
        title: 'توريد الشحنة الأولى والفحص المعملي ومطابقة المواصفات',
        percentage: 50,
        amount: 47500,
        terms: 'وصول الأجهزة لمقر الشركة واجتياز اختبار التحمل والمطابقة.',
        status: 'disputed',
        submissionNotes: 'الطرف الثاني يزعم التسليم والطرف الأول يثبت وجود تلفيات واختلاف نوع المعالج.'
      },
      {
        _id: 'ms-05',
        title: 'التركيب النهائي والتشغيل وتسليم شهادة الضمان المصنعي',
        percentage: 50,
        amount: 47500,
        terms: 'تشغيل النظام بالكامل في مركز البيانات ومصادقة مهندس الشبكات.',
        status: 'pending_deposit'
      }
    ]
  }
];

export const mockDisputes: Dispute[] = [
  {
    _id: 'dsp-01',
    escrowId: mockEscrows[1],
    milestoneId: 'ms-04',
    raisedBy: mockUsers[3],
    reason: 'عدم مطابقة مواصفات الخوادم المستلمة مع وثيقة التعاقد ووجود أضرار مادية',
    details: 'المواصفات المتفق عليها في العقد تنص صراحة على معالجات Intel Xeon Gold بتردد 3.2GHz، بينما الأجهزة المستلمة مزودة بفئة Silver مع كسر في إطار التبريد لأحد الخوادم، ورفض الطرف الثاني استبدالها أو تقديم خصم تعويضي.',
    priority: 'urgent',
    status: 'open',
    evidenceFiles: [
      'https://images.unsplash.com/photo-1558494949-ef010cbdcc31?auto=format&fit=crop&w=600&q=80',
      'https://images.unsplash.com/photo-1597733336794-12d05021d510?auto=format&fit=crop&w=600&q=80'
    ],
    arbitrationVerdict: null,
    createdAt: '2026-11-11T12:00:00.000Z'
  }
];

export const mockDashboardStats: DashboardStats = {
  totalUsers: 1480,
  approvedLawyers: 142,
  pendingLawyers: 7,
  activeEscrows: 89,
  totalHeldBalance: 2450000,
  openDisputes: 3,
  totalRevenue: 684200,
  monthlyRevenue: [
    { month: 'يناير', contracts: 45000, consultations: 22000, escrowFees: 68000 },
    { month: 'فبراير', contracts: 52000, consultations: 28000, escrowFees: 74000 },
    { month: 'مارس', contracts: 58000, consultations: 31000, escrowFees: 82000 },
    { month: 'أبريل', contracts: 63000, consultations: 35000, escrowFees: 95000 },
    { month: 'مايو', contracts: 71000, consultations: 42000, escrowFees: 110000 },
    { month: 'يونيو', contracts: 84000, consultations: 48000, escrowFees: 125000 }
  ],
  serviceDistribution: [
    { name: 'عقود الوساطة (Escrow)', value: 55, color: '#D4AF37' },
    { name: 'الاستشارات القانونية', value: 25, color: '#10B981' },
    { name: 'نماذج العقود الذكية', value: 20, color: '#3B82F6' }
  ],
  urgentAlerts: {
    pendingLawyers: [mockLawyers[2], mockLawyers[3]],
    activeDisputes: mockDisputes
  }
};

export const mockFinancialStats: FinancialStats = {
  platformNetRevenue: 684200,
  totalEscrowVolume: 8450000,
  pendingPayoutsAmount: 22700,
  completedPayoutsAmount: 412000,
  withdrawals: [
    { id: 'W-901', lawyerName: 'أ. طارق عبد العزيز', amount: 14500, bank: 'البنك الأهلي المصري', iban: 'EG8200030000000012345678901', status: 'pending', date: '2026-11-12' },
    { id: 'W-902', lawyerName: 'أ. داليا سليم الشافعي', amount: 8200, bank: 'بنك مصر', iban: 'EG1900020000000098765432100', status: 'pending', date: '2026-11-11' },
    { id: 'W-898', lawyerName: 'د. سامي الجوهري', amount: 32000, bank: 'CIB البنك التجاري الدولي', iban: 'EG4500100000000055443322110', status: 'completed', date: '2026-11-08' },
    { id: 'W-895', lawyerName: 'أ. إبراهيم المنشاوي', amount: 19800, bank: 'بنك الإسكندرية', iban: 'EG2200050000000077889900112', status: 'completed', date: '2026-11-05' }
  ],
  ledger: [
    { id: 'TX-771', type: 'escrow_fee', title: 'عمولة وساطة صفقة توريد معدات #881', amount: 4500, party: 'شركة الدلتا للصناعات', date: '2026-11-12' },
    { id: 'TX-770', type: 'consultation_cut', title: 'نسبة المنصة من استشارة قانونية #401', amount: 120, party: 'أ. طارق عبد العزيز', date: '2026-11-12' },
    { id: 'TX-769', type: 'template_sale', title: 'شراء نموذج عقد مقاولة ذكي وتوثيق', amount: 350, party: 'م. أحمد شكري', date: '2026-11-11' },
    { id: 'TX-768', type: 'escrow_fee', title: 'رسوم تحكيم غرفة النزاع لعملية #312', amount: 2800, party: 'مكتب الشروق العقاري', date: '2026-11-10' }
  ]
};

