import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/template_model.dart';
import '../../models/contract_model.dart';
import '../../services/api_service.dart';
import 'contract_form_screen.dart';
import 'contract_pdf_viewer_screen.dart';

class ContractsTab extends StatefulWidget {
  const ContractsTab({super.key});

  @override
  State<ContractsTab> createState() => _ContractsTabState();
}

class _ContractsTabState extends State<ContractsTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Templates state
  List<TemplateModel> _templates = [];
  bool _isLoadingTemplates = false;
  String _selectedCategory = 'الكل';
  String _searchQuery = '';

  // My contracts state
  List<ContractModel> _myContracts = [];
  bool _isLoadingMyContracts = false;

  final List<String> _categories = [
    'الكل',
    'عقاري',
    'تجاري',
    'عمل',
    'شركات',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTemplates();
    _loadMyContracts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTemplates() async {
    setState(() => _isLoadingTemplates = true);
    try {
      final list = await ApiService().getTemplates(
        category: _selectedCategory == 'الكل' ? null : _selectedCategory,
      );
      if (mounted) {
        setState(() {
          _templates = list;
          _isLoadingTemplates = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingTemplates = false);
    }
  }

  Future<void> _loadMyContracts() async {
    setState(() => _isLoadingMyContracts = true);
    try {
      final list = await ApiService().getMyContracts();
      if (mounted) {
        setState(() {
          _myContracts = list;
          _isLoadingMyContracts = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingMyContracts = false);
    }
  }

  List<TemplateModel> get _filteredTemplates {
    if (_searchQuery.isEmpty) return _templates;
    return _templates.where((t) {
      return t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.description.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: OqoodyTheme.primaryDark,
        title: const Text('إدارة ونماذج العقود', style: TextStyle(color: OqoodyTheme.accentGold, fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: OqoodyTheme.accentGold,
          labelColor: OqoodyTheme.accentGold,
          unselectedLabelColor: OqoodyTheme.textMuted,
          tabs: const [
            Tab(text: 'النماذج الذكية'),
            Tab(text: 'عقودي الموثقة'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: Smart Templates Catalog
          RefreshIndicator(
            onRefresh: _loadTemplates,
            color: OqoodyTheme.accentGold,
            child: Column(
              children: [
                // Search & Filter header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'ابحث عن نموذج عقد (إيجار، شراكة، بيع...)...',
                      prefixIcon: const Icon(Icons.search, color: OqoodyTheme.accentGold),
                      filled: true,
                      fillColor: OqoodyTheme.cardBg,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                // Category chips
                SizedBox(
                  height: 48,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, idx) {
                      final cat = _categories[idx];
                      final isSelected = _selectedCategory == cat;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        selectedColor: OqoodyTheme.accentGold,
                        backgroundColor: OqoodyTheme.cardBg,
                        labelStyle: TextStyle(
                          color: isSelected ? OqoodyTheme.primaryDark : OqoodyTheme.textLight,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedCategory = cat);
                            _loadTemplates();
                          }
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 8),

                // Templates List
                Expanded(
                  child: _isLoadingTemplates
                      ? const Center(child: CircularProgressIndicator(color: OqoodyTheme.accentGold))
                      : _filteredTemplates.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.description_outlined, size: 64, color: OqoodyTheme.textMuted),
                                  const SizedBox(height: 12),
                                  const Text('لا توجد نماذج متوفرة حالياً', style: TextStyle(color: OqoodyTheme.textMuted)),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: _loadTemplates,
                                    child: const Text('إعادة التحميل'),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredTemplates.length,
                              itemBuilder: (context, index) {
                                final template = _filteredTemplates[index];
                                return _buildTemplateCard(template);
                              },
                            ),
                ),
              ],
            ),
          ),

          // TAB 2: My Generated Contracts
          RefreshIndicator(
            onRefresh: _loadMyContracts,
            color: OqoodyTheme.accentGold,
            child: _isLoadingMyContracts
                ? const Center(child: CircularProgressIndicator(color: OqoodyTheme.accentGold))
                : _myContracts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.history_edu, size: 64, color: OqoodyTheme.textMuted),
                            const SizedBox(height: 12),
                            const Text('لم تقم بتوثيق أو إصدار أي عقود بعد', style: TextStyle(color: OqoodyTheme.textMuted, fontSize: 15)),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: () => _tabController.animateTo(0),
                              icon: const Icon(Icons.add),
                              label: const Text('اختر نموذجاً للبدء'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _myContracts.length,
                        itemBuilder: (context, index) {
                          final contract = _myContracts[index];
                          return _buildMyContractCard(contract);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(TemplateModel template) {
    return Card(
      color: OqoodyTheme.cardBg,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: OqoodyTheme.primaryEmerald),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ContractFormScreen(template: template),
            ),
          ).then((_) => _loadMyContracts());
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: OqoodyTheme.primaryDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: OqoodyTheme.accentGold.withOpacity(0.4)),
                    ),
                    child: const Icon(Icons.assignment, color: OqoodyTheme.accentGold, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          template.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          template.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: OqoodyTheme.textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(color: OqoodyTheme.primaryEmerald, height: 1),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: OqoodyTheme.primaryDark,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'فوري: ${template.autoGeneratePrice.toStringAsFixed(0)} ج.م',
                          style: const TextStyle(color: OqoodyTheme.accentGold, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: OqoodyTheme.primaryDark,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'محامٍ: ${template.lawyerReviewPrice.toStringAsFixed(0)} ج.م',
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const Row(
                    children: [
                      Text('صياغة العقد', style: TextStyle(color: OqoodyTheme.accentGold, fontSize: 12, fontWeight: FontWeight.bold)),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios, size: 12, color: OqoodyTheme.accentGold),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyContractCard(ContractModel contract) {
    Color statusColor;
    String statusText;

    switch (contract.status) {
      case 'approved':
      case 'completed':
        statusColor = OqoodyTheme.successGreen;
        statusText = 'موثق وجاهز';
        break;
      case 'pending_review':
        statusColor = Colors.amber;
        statusText = 'قيد المراجعة';
        break;
      default:
        statusColor = OqoodyTheme.textMuted;
        statusText = 'مسودة';
    }

    return Card(
      color: OqoodyTheme.cardBg,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: statusColor.withOpacity(0.5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.15),
          child: Icon(Icons.description, color: statusColor),
        ),
        title: Text(contract.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                Text(
                  contract.contractType == 'instant' ? 'توليد آلي' : 'مراجعة محامٍ',
                  style: const TextStyle(color: OqoodyTheme.textMuted, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: OqoodyTheme.textMuted),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ContractPdfViewerScreen(contract: contract),
            ),
          );
        },
      ),
    );
  }
}
