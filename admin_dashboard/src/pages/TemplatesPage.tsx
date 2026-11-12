import React, { useState, useEffect, useRef } from 'react';
import { 
  FileText, 
  Plus, 
  Search, 
  Layers, 
  Sparkles, 
  Trash2, 
  Edit3, 
  Eye, 
  ShieldAlert, 
  CheckCircle, 
  CheckCircle2,
  DollarSign,
  Variable,
  Calendar,
  Hash,
  ListFilter,
  Type
} from 'lucide-react';
import { adminApi } from '../services/api';
import { Template, TemplateVariable } from '../types';

export const TemplatesPage: React.FC = () => {
  const [templates, setTemplates] = useState<Template[]>([]);
  const [selectedCategory, setSelectedCategory] = useState<string>('all');
  const [searchQuery, setSearchQuery] = useState<string>('');
  const [isLoading, setIsLoading] = useState<boolean>(true);

  // Template Builder Modal
  const [isModalOpen, setIsModalOpen] = useState<boolean>(false);
  const [editingTemplate, setEditingTemplate] = useState<Template | null>(null);
  const [previewTemplate, setPreviewTemplate] = useState<Template | null>(null);

  // Form Fields
  const [title, setTitle] = useState('');
  const [category, setCategory] = useState('عقود مالية وتجارية');
  const [description, setDescription] = useState('');
  const [content, setContent] = useState('');
  const [autoGeneratePrice, setAutoGeneratePrice] = useState<number>(150);
  const [lawyerReviewPrice, setLawyerReviewPrice] = useState<number>(450);
  const [requiresReview, setRequiresReview] = useState<boolean>(true);
  const [variables, setVariables] = useState<TemplateVariable[]>([]);

  // New Variable Input State
  const [newVarName, setNewVarName] = useState('');
  const [newVarLabel, setNewVarLabel] = useState('');
  const [newVarType, setNewVarType] = useState<'text' | 'number' | 'date' | 'select'>('text');
  const [newVarOptions, setNewVarOptions] = useState('');
  const [newVarDefault, setNewVarDefault] = useState('');

  const [toast, setToast] = useState<string | null>(null);
  const contentTextareaRef = useRef<HTMLTextAreaElement>(null);

  useEffect(() => {
    loadTemplates();
  }, []);

  const loadTemplates = async () => {
    setIsLoading(true);
    try {
      const data = await adminApi.getTemplates();
      setTemplates(data);
    } catch (err) {
      console.error(err);
    } finally {
      setIsLoading(false);
    }
  };

  const handleOpenCreate = () => {
    setEditingTemplate(null);
    setTitle('');
    setCategory('عقود مالية وتجارية');
    setDescription('');
    setContent(`إنه في يوم {{تاريخ_اليوم}} تم الاتفاق والتراضي بين كل من:
الطرف الأول: {{اسم_الطرف_الأول}} المقيم في {{عنوان_الطرف_الأول}} ورقم قومي {{الرقم_القومي_للأول}}.
الطرف الثاني: {{اسم_الطرف_الثاني}} المقيم في {{عنوان_الطرف_الثاني}} ورقم قومي {{الرقم_القومي_للثاني}}.

البند الأول: موضوع التعاقد والالتزامات
اتفق الطرفان على تنفيذ الأعمال المحددة بقيمة إجمالية قدرها {{قيمة_العقد}} جنيه مصري مع كفالة إنجاز مدتها {{مدة_التنفيذ_بالأيام}} يوماً.`);
    setAutoGeneratePrice(150);
    setLawyerReviewPrice(450);
    setRequiresReview(true);
    setVariables([
      { name: 'تاريخ_اليوم', label: 'تاريخ إبرام العقد', type: 'date', required: true, defaultValue: '2026-11-12' },
      { name: 'اسم_الطرف_الأول', label: 'اسم الطرف الأول', type: 'text', required: true, defaultValue: '' },
      { name: 'عنوان_الطرف_الأول', label: 'عنوان الطرف الأول', type: 'text', required: true, defaultValue: 'القاهرة' },
      { name: 'الرقم_القومي_للأول', label: 'الرقم القومي للطرف الأول', type: 'text', required: true, defaultValue: '' },
      { name: 'اسم_الطرف_الثاني', label: 'اسم الطرف الثاني', type: 'text', required: true, defaultValue: '' },
      { name: 'عنوان_الطرف_الثاني', label: 'عنوان الطرف الثاني', type: 'text', required: true, defaultValue: '' },
      { name: 'الرقم_القومي_للثاني', label: 'الرقم القومي للطرف الثاني', type: 'text', required: true, defaultValue: '' },
      { name: 'قيمة_العقد', label: 'قيمة العقد (ج.م)', type: 'number', required: true, defaultValue: '50000' },
      { name: 'مدة_التنفيذ_بالأيام', label: 'مدة التنفيذ (بالأيام)', type: 'number', required: true, defaultValue: '30' }
    ]);
    setIsModalOpen(true);
  };

  const handleOpenEdit = (t: Template) => {
    setEditingTemplate(t);
    setTitle(t.title);
    setCategory(t.category);
    setDescription(t.description || '');
    setContent(t.content);
    setAutoGeneratePrice(t.autoGeneratePrice || t.price || 150);
    setLawyerReviewPrice(t.lawyerReviewPrice || 450);
    setRequiresReview(t.requiresReview);
    setVariables(t.variables || []);
    setIsModalOpen(true);
  };

  const handleAddVariable = () => {
    if (!newVarName.trim() || !newVarLabel.trim()) {
      showToast('يرجى كتابة اسم المتغير وعنوانه في النموذج');
      return;
    }

    const cleanName = newVarName.trim().replace(/\s+/g, '_');
    const opts = newVarType === 'select' ? newVarOptions.split(',').map(s => s.trim()).filter(Boolean) : [];

    const newVar: TemplateVariable = {
      name: cleanName,
      label: newVarLabel.trim(),
      type: newVarType,
      options: opts,
      required: true,
      defaultValue: newVarDefault.trim()
    };

    setVariables([...variables, newVar]);
    setNewVarName('');
    setNewVarLabel('');
    setNewVarOptions('');
    setNewVarDefault('');
    showToast(`تمت إضافة المتغير {{${cleanName}}}`);
  };

  const handleRemoveVariable = (name: string) => {
    setVariables(variables.filter(v => v.name !== name));
  };

  const insertPlaceholder = (ph: string) => {
    const textarea = contentTextareaRef.current;
    if (!textarea) return;
    const start = textarea.selectionStart;
    const end = textarea.selectionEnd;
    const textBefore = content.substring(0, start);
    const textAfter = content.substring(end, content.length);
    const placeholderText = `{{${ph}}}`;
    const newContent = textBefore + placeholderText + textAfter;
    setContent(newContent);

    setTimeout(() => {
      textarea.focus();
      textarea.setSelectionRange(start + placeholderText.length, start + placeholderText.length);
    }, 50);
  };

  const handleSaveTemplate = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!title.trim() || !content.trim()) {
      showToast('يرجى ملء عنوان النموذج ونصه القانوني');
      return;
    }

    const placeholders = variables.map(v => v.name);

    try {
      if (editingTemplate) {
        const updated = await adminApi.updateTemplate(editingTemplate._id, {
          title,
          category,
          description,
          content,
          placeholders,
          variables,
          autoGeneratePrice,
          lawyerReviewPrice,
          price: autoGeneratePrice,
          requiresReview
        });
        setTemplates(templates.map(t => t._id === editingTemplate._id ? updated : t));
        showToast('تم تحديث نموذج العقد والمتغيرات بنجاح');
      } else {
        const created = await adminApi.createTemplate({
          title,
          category,
          description,
          content,
          placeholders,
          variables,
          autoGeneratePrice,
          lawyerReviewPrice,
          price: autoGeneratePrice,
          requiresReview
        });
        setTemplates([created, ...templates]);
        showToast('تم إنشاء ونشر نموذج العقد الجديد');
      }
      setIsModalOpen(false);
    } catch {
      showToast('حدث خطأ أثناء حفظ النموذج');
    }
  };

  const handleDeleteTemplate = async (id: string) => {
    if (!window.confirm('هل أنت متأكد من حذف هذا النموذج القانوني؟')) return;
    try {
      await adminApi.deleteTemplate(id);
      setTemplates(templates.filter(t => t._id !== id));
      showToast('تم حذف النموذج بنجاح');
    } catch {
      showToast('تعذر حذف النموذج');
    }
  };

  const showToast = (msg: string) => {
    setToast(msg);
    setTimeout(() => setToast(null), 3000);
  };

  const categories = [
    'all',
    'عقود مالية وتجارية',
    'تكنولوجيا وبرمجيات',
    'عقارات وإيجارات',
    'شركات واستثمار'
  ];

  const filteredTemplates = templates.filter(t => {
    const matchCat = selectedCategory === 'all' || t.category === selectedCategory;
    const matchQuery = t.title.toLowerCase().includes(searchQuery.toLowerCase()) || 
                       (t.description && t.description.toLowerCase().includes(searchQuery.toLowerCase()));
    return matchCat && matchQuery;
  });

  return (
    <div className="space-y-6">
      {toast && (
        <div className="fixed bottom-6 left-6 z-50 bg-oqoody-dark border border-oqoody-gold/60 text-oqoody-gold px-4 py-3 rounded-xl shadow-2xl flex items-center gap-2 text-sm animate-in fade-in slide-in-from-bottom-2">
          <CheckCircle2 className="w-5 h-5 text-oqoody-gold" />
          <span>{toast}</span>
        </div>
      )}

      {/* Top Header & Actions */}
      <div className="flex flex-col sm:flex-row items-stretch sm:items-center justify-between gap-4">
        <div className="relative flex-1 max-w-md">
          <Search className="w-4 h-4 text-oqoody-textMuted absolute right-3.5 top-3.5" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="البحث في نماذج العقود والبنود القانونية..."
            className="w-full bg-oqoody-card border border-oqoody-border rounded-xl pr-10 pl-4 py-2.5 text-xs text-oqoody-textLight focus:outline-none focus:border-oqoody-gold transition-colors"
          />
        </div>

        <button
          onClick={handleOpenCreate}
          className="px-5 py-2.5 rounded-xl bg-oqoody-gold hover:bg-oqoody-goldHover text-oqoody-bg font-bold text-xs shadow-gold-glow transition-all flex items-center justify-center gap-2"
        >
          <Plus className="w-4 h-4" />
          <span>منشئ النماذج والمتغيرات الذكية</span>
        </button>
      </div>

      {/* Categories Bar */}
      <div className="flex items-center gap-2 overflow-x-auto pb-1">
        <Layers className="w-4 h-4 text-oqoody-gold flex-shrink-0" />
        {categories.map((cat) => (
          <button
            key={cat}
            onClick={() => setSelectedCategory(cat)}
            className={`px-3.5 py-1.5 rounded-xl text-xs font-semibold whitespace-nowrap transition-all ${
              selectedCategory === cat 
                ? 'bg-oqoody-gold text-oqoody-bg shadow-gold-glow' 
                : 'bg-oqoody-card text-oqoody-textMuted hover:text-oqoody-textLight border border-oqoody-border'
            }`}
          >
            {cat === 'all' ? 'كافة التصنيفات' : cat}
          </button>
        ))}
      </div>

      {/* Templates Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {isLoading ? (
          <div className="col-span-full text-center py-16 text-oqoody-textMuted">
            <span className="inline-block w-6 h-6 border-2 border-oqoody-gold border-t-transparent rounded-full animate-spin mb-2" />
            <div>جاري تحميل نماذج العقود...</div>
          </div>
        ) : filteredTemplates.length === 0 ? (
          <div className="col-span-full text-center py-16 text-oqoody-textMuted">
            لا توجد نماذج عقود مطابقة للتصنيف أو البحث الحالي
          </div>
        ) : (
          filteredTemplates.map((template) => (
            <div
              key={template._id}
              className="oqoody-card p-6 flex flex-col justify-between hover:border-oqoody-gold/40 transition-all duration-300 group"
            >
              <div>
                <div className="flex items-start justify-between gap-2 mb-3">
                  <span className="px-2.5 py-1 rounded-lg bg-oqoody-dark border border-oqoody-gold/30 text-[11px] font-bold text-oqoody-gold">
                    {template.category}
                  </span>
                  <div className="text-right">
                    <span className="text-xs text-oqoody-textMuted block">توليد فوري</span>
                    <span className="text-sm font-black text-emerald-400">
                      {template.autoGeneratePrice || template.price || 150} ج.م
                    </span>
                  </div>
                </div>

                <h3 className="font-bold text-sm text-oqoody-textLight group-hover:text-oqoody-gold transition-colors leading-snug mb-2">
                  {template.title}
                </h3>
                <p className="text-xs text-oqoody-textMuted line-clamp-2 mb-3 leading-relaxed">
                  {template.description || 'نموذج قانوني موثق وخاضع لأحكام القانون المصري مع دعم المتغيرات التلقائية.'}
                </p>

                {/* Dual Pricing Info */}
                <div className="flex items-center justify-between p-2 rounded-lg bg-oqoody-dark/70 border border-oqoody-border/60 text-[11px] mb-3">
                  <div>
                    <span className="text-oqoody-textMuted">توليد فوري: </span>
                    <span className="font-bold text-emerald-400">{template.autoGeneratePrice || 150} ج.م</span>
                  </div>
                  <div>
                    <span className="text-oqoody-textMuted">فحص ومراجعة محامٍ: </span>
                    <span className="font-bold text-oqoody-gold">{template.lawyerReviewPrice || 450} ج.م</span>
                  </div>
                </div>

                {/* Variables Preview Badges */}
                <div className="flex flex-wrap gap-1 mb-4">
                  {(template.variables || []).slice(0, 3).map((v, idx) => (
                    <span key={idx} className="bg-oqoody-dark text-oqoody-textLight border border-oqoody-border text-[10px] px-2 py-0.5 rounded">
                      &#123;&#123;{v.name}&#125;&#125;
                    </span>
                  ))}
                  {(template.variables || []).length > 3 && (
                    <span className="text-[10px] text-oqoody-gold font-bold self-center">
                      +{(template.variables || []).length - 3} متغيرات ذكية
                    </span>
                  )}
                </div>
              </div>

              {/* Card Footer */}
              <div className="pt-3 border-t border-oqoody-border/80 flex items-center justify-between">
                <div className="flex items-center gap-1 text-[11px]">
                  {template.requiresReview ? (
                    <span className="text-oqoody-warning flex items-center gap-1">
                      <ShieldAlert className="w-3.5 h-3.5" />
                      <span>فحص محامٍ إلزامي</span>
                    </span>
                  ) : (
                    <span className="text-oqoody-success flex items-center gap-1">
                      <CheckCircle className="w-3.5 h-3.5" />
                      <span>متاح فوري</span>
                    </span>
                  )}
                </div>

                <div className="flex items-center gap-2">
                  <button
                    onClick={() => setPreviewTemplate(template)}
                    title="معاينة النص الكامل"
                    className="p-1.5 rounded-lg bg-oqoody-dark hover:bg-oqoody-card border border-oqoody-border text-oqoody-textLight transition-colors"
                  >
                    <Eye className="w-3.5 h-3.5" />
                  </button>
                  <button
                    onClick={() => handleOpenEdit(template)}
                    title="تعديل النموذج والمتغيرات"
                    className="p-1.5 rounded-lg bg-oqoody-dark hover:bg-oqoody-card border border-oqoody-border text-oqoody-gold transition-colors"
                  >
                    <Edit3 className="w-3.5 h-3.5" />
                  </button>
                  <button
                    onClick={() => handleDeleteTemplate(template._id)}
                    title="حذف النموذج"
                    className="p-1.5 rounded-lg bg-oqoody-dark hover:bg-oqoody-danger/20 border border-oqoody-border text-oqoody-danger transition-colors"
                  >
                    <Trash2 className="w-3.5 h-3.5" />
                  </button>
                </div>
              </div>
            </div>
          ))
        )}
      </div>

      {/* Dynamic Template & Variable Builder Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 bg-black/85 backdrop-blur-md flex items-center justify-center p-4">
          <div className="bg-oqoody-dark border border-oqoody-border rounded-3xl w-full max-w-4xl max-h-[92vh] overflow-y-auto shadow-2xl p-6 sm:p-8">
            <div className="flex items-start justify-between pb-4 border-b border-oqoody-border mb-6">
              <div>
                <h3 className="text-lg font-bold text-oqoody-textLight flex items-center gap-2">
                  <FileText className="w-5 h-5 text-oqoody-gold" />
                  <span>{editingTemplate ? 'تعديل نموذج العقد والمتغيرات' : 'منشئ نماذج العقود والمتغيرات الديناميكية'}</span>
                </h3>
                <p className="text-xs text-oqoody-textMuted mt-1">
                  إعداد الحقول المتغيرة والخيارات والتسعير المزدوج (فوري ومراجعة محامٍ)
                </p>
              </div>
              <button onClick={() => setIsModalOpen(false)} className="text-oqoody-textMuted hover:text-white p-1">
                ✕
              </button>
            </div>

            <form onSubmit={handleSaveTemplate} className="space-y-5">
              {/* Basic Fields */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-semibold text-oqoody-textMuted mb-1.5">
                    عنوان النموذج القانوني *
                  </label>
                  <input
                    type="text"
                    required
                    value={title}
                    onChange={(e) => setTitle(e.target.value)}
                    placeholder="مثال: عقد وساطة تجارية وتوريد معدات..."
                    className="w-full bg-oqoody-card border border-oqoody-border rounded-xl px-4 py-2.5 text-xs text-oqoody-textLight focus:outline-none focus:border-oqoody-gold"
                  />
                </div>

                <div>
                  <label className="block text-xs font-semibold text-oqoody-textMuted mb-1.5">
                    التصنيف القانوني *
                  </label>
                  <select
                    value={category}
                    onChange={(e) => setCategory(e.target.value)}
                    className="w-full bg-oqoody-card border border-oqoody-border rounded-xl px-4 py-2.5 text-xs text-oqoody-textLight focus:outline-none focus:border-oqoody-gold"
                  >
                    <option value="عقود مالية وتجارية">عقود مالية وتجارية</option>
                    <option value="تكنولوجيا وبرمجيات">تكنولوجيا وبرمجيات</option>
                    <option value="عقارات وإيجارات">عقارات وإيجارات</option>
                    <option value="شركات واستثمار">شركات واستثمار</option>
                  </select>
                </div>
              </div>

              {/* Dual Pricing Controls */}
              <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 bg-oqoody-card/60 p-4 rounded-2xl border border-oqoody-border">
                <div>
                  <label className="block text-xs font-semibold text-oqoody-textMuted mb-1.5">
                    سعر التوليد الفوري المباشر (ج.م)
                  </label>
                  <input
                    type="number"
                    min={0}
                    value={autoGeneratePrice}
                    onChange={(e) => setAutoGeneratePrice(Number(e.target.value))}
                    className="w-full bg-oqoody-dark border border-oqoody-border rounded-xl px-4 py-2 text-xs text-emerald-400 font-bold"
                  />
                </div>

                <div>
                  <label className="block text-xs font-semibold text-oqoody-textMuted mb-1.5">
                    سعر الصياغة ومراجعة المحامي (ج.م)
                  </label>
                  <input
                    type="number"
                    min={0}
                    value={lawyerReviewPrice}
                    onChange={(e) => setLawyerReviewPrice(Number(e.target.value))}
                    className="w-full bg-oqoody-dark border border-oqoody-border rounded-xl px-4 py-2 text-xs text-oqoody-gold font-bold"
                  />
                </div>

                <div className="flex items-center gap-2 pt-6">
                  <input
                    type="checkbox"
                    id="revCheck"
                    checked={requiresReview}
                    onChange={(e) => setRequiresReview(e.target.checked)}
                    className="w-4 h-4 accent-oqoody-gold cursor-pointer"
                  />
                  <label htmlFor="revCheck" className="text-xs font-bold text-oqoody-textLight cursor-pointer">
                    فحص محامٍ إلزامي
                  </label>
                </div>
              </div>

              {/* Dynamic Variables Section */}
              <div className="bg-oqoody-card/80 p-4 rounded-2xl border border-oqoody-border space-y-3">
                <div className="flex items-center justify-between">
                  <span className="text-xs font-bold text-oqoody-gold flex items-center gap-1.5">
                    <Variable className="w-4 h-4" />
                    <span>المتغيرات الديناميكية المعرفة في النموذج ({variables.length})</span>
                  </span>
                  <span className="text-[11px] text-oqoody-textMuted">
                    انقر على أي متغير لإدراجه في محرر العقد
                  </span>
                </div>

                {/* Active Variables List */}
                <div className="flex flex-wrap gap-2">
                  {variables.map((v) => (
                    <div
                      key={v.name}
                      className="flex items-center gap-1.5 bg-oqoody-dark px-2.5 py-1 rounded-lg border border-oqoody-border text-xs"
                    >
                      <button
                        type="button"
                        onClick={() => insertPlaceholder(v.name)}
                        className="font-mono text-oqoody-gold hover:underline"
                        title="انقر للإدراج في النص"
                      >
                        &#123;&#123;{v.name}&#125;&#125;
                      </button>
                      <span className="text-[10px] text-oqoody-textMuted">({v.label} - {v.type})</span>
                      <button
                        type="button"
                        onClick={() => handleRemoveVariable(v.name)}
                        className="text-oqoody-textMuted hover:text-oqoody-danger mr-1"
                      >
                        ✕
                      </button>
                    </div>
                  ))}
                </div>

                {/* Add New Variable Sub-form */}
                <div className="pt-3 border-t border-oqoody-border/60">
                  <span className="text-[11px] font-bold text-oqoody-textLight block mb-2">
                    + تعريف متغير جديد:
                  </span>
                  <div className="grid grid-cols-1 sm:grid-cols-5 gap-2">
                    <input
                      type="text"
                      placeholder="اسم الكود (مثال: عنوان_العقار)"
                      value={newVarName}
                      onChange={(e) => setNewVarName(e.target.value)}
                      className="bg-oqoody-dark border border-oqoody-border rounded-lg px-2.5 py-1.5 text-xs text-oqoody-textLight"
                    />
                    <input
                      type="text"
                      placeholder="العنوان بالعربية للمستخدم"
                      value={newVarLabel}
                      onChange={(e) => setNewVarLabel(e.target.value)}
                      className="bg-oqoody-dark border border-oqoody-border rounded-lg px-2.5 py-1.5 text-xs text-oqoody-textLight"
                    />
                    <select
                      value={newVarType}
                      onChange={(e: any) => setNewVarType(e.target.value)}
                      className="bg-oqoody-dark border border-oqoody-border rounded-lg px-2 py-1.5 text-xs text-oqoody-textLight"
                    >
                      <option value="text">نص (Text)</option>
                      <option value="number">رقم (Number)</option>
                      <option value="date">تاريخ (Date)</option>
                      <option value="select">خيارات منسدلة (Select)</option>
                    </select>

                    {newVarType === 'select' ? (
                      <input
                        type="text"
                        placeholder="الخيارات مفصولة بفواصل (أ، ب)"
                        value={newVarOptions}
                        onChange={(e) => setNewVarOptions(e.target.value)}
                        className="bg-oqoody-dark border border-oqoody-border rounded-lg px-2.5 py-1.5 text-xs text-oqoody-textLight"
                      />
                    ) : (
                      <input
                        type="text"
                        placeholder="القيمة الافتراضية (اختياري)"
                        value={newVarDefault}
                        onChange={(e) => setNewVarDefault(e.target.value)}
                        className="bg-oqoody-dark border border-oqoody-border rounded-lg px-2.5 py-1.5 text-xs text-oqoody-textLight"
                      />
                    )}

                    <button
                      type="button"
                      onClick={handleAddVariable}
                      className="px-3 py-1.5 rounded-lg bg-oqoody-border hover:bg-oqoody-gold hover:text-oqoody-bg text-oqoody-gold text-xs font-bold transition-all"
                    >
                      إضافة المتغير
                    </button>
                  </div>
                </div>
              </div>

              {/* Clause Editor */}
              <div>
                <label className="block text-xs font-semibold text-oqoody-textMuted mb-1.5">
                  النص والبنود القانونية للعقد (مع الحقول المتغيرة) *
                </label>
                <textarea
                  ref={contentTextareaRef}
                  required
                  rows={8}
                  value={content}
                  onChange={(e) => setContent(e.target.value)}
                  className="w-full bg-oqoody-card border border-oqoody-border rounded-xl p-4 text-xs font-mono text-oqoody-textLight leading-relaxed focus:outline-none focus:border-oqoody-gold"
                />
              </div>

              {/* Submit Buttons */}
              <div className="flex items-center justify-end gap-3 pt-3 border-t border-oqoody-border">
                <button
                  type="button"
                  onClick={() => setIsModalOpen(false)}
                  className="px-5 py-2.5 rounded-xl text-xs font-semibold bg-oqoody-card hover:bg-oqoody-border text-oqoody-textMuted transition-colors"
                >
                  إلغاء
                </button>
                <button
                  type="submit"
                  className="px-6 py-2.5 rounded-xl text-xs font-bold bg-oqoody-gold hover:bg-oqoody-goldHover text-oqoody-bg shadow-gold-glow transition-all"
                >
                  حفظ ونشر النموذج الذكي
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Preview Full Text Modal */}
      {previewTemplate && (
        <div className="fixed inset-0 z-50 bg-black/85 backdrop-blur-md flex items-center justify-center p-4">
          <div className="bg-oqoody-dark border border-oqoody-border rounded-3xl w-full max-w-2xl max-h-[85vh] overflow-y-auto shadow-2xl p-6 sm:p-8">
            <div className="flex items-start justify-between pb-4 border-b border-oqoody-border mb-4">
              <div>
                <h3 className="text-base font-bold text-oqoody-textLight">{previewTemplate.title}</h3>
                <span className="text-xs text-oqoody-gold">{previewTemplate.category}</span>
              </div>
              <button onClick={() => setPreviewTemplate(null)} className="text-oqoody-textMuted hover:text-white">✕</button>
            </div>
            <div className="bg-oqoody-card p-4 rounded-xl border border-oqoody-border/60 text-xs font-mono text-oqoody-textLight whitespace-pre-wrap leading-relaxed max-h-96 overflow-y-auto">
              {previewTemplate.content}
            </div>
            <div className="mt-4 flex justify-end">
              <button
                onClick={() => setPreviewTemplate(null)}
                className="px-5 py-2 rounded-xl text-xs font-bold bg-oqoody-gold text-oqoody-bg"
              >
                إغلاق المعاينة
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
