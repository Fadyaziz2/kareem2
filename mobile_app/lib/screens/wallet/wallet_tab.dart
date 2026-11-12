import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/transaction_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class WalletTab extends StatefulWidget {
  const WalletTab({super.key});

  @override
  State<WalletTab> createState() => _WalletTabState();
}

class _WalletTabState extends State<WalletTab> {
  double _walletBalance = 0.0;
  double _heldBalance = 0.0;
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService().getWalletData();
      if (mounted) {
        setState(() {
          _walletBalance = data['walletBalance'] ?? 0.0;
          _heldBalance = data['heldBalance'] ?? 0.0;
          _transactions = data['transactions'] ?? [];
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showTopupDialog() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final amountController = TextEditingController(text: '500');
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: OqoodyTheme.cardBg,
        title: const Text('شحن رصيد المحفظة', style: TextStyle(color: OqoodyTheme.accentGold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('أدخل المبلغ المراد شحنه (ج.م):', style: TextStyle(fontSize: 13, color: Colors.white70)),
            const SizedBox(height: 10),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(suffixText: 'ج.م'),
            ),
            const SizedBox(height: 12),
            const Text('وسيلة الدفع: بطاقة بنكية / فودافون كاش / إنستاباي (محاكاة فورية)', style: TextStyle(fontSize: 11, color: OqoodyTheme.textMuted)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(color: OqoodyTheme.textMuted))),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text) ?? 0.0;
              if (amount <= 0) return;
              Navigator.pop(ctx);
              try {
                await ApiService().mockCheckout(type: 'topup', amount: amount, description: 'شحن رصيد المحفظة الإلكترونية');
                await ApiService().topupWallet(amount);
                await auth.refreshUser();
                _loadWallet();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('تم شحن $amount ج.م بنجاح إلى محفظتك'), backgroundColor: OqoodyTheme.successGreen),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('فشل الشحن: $e'), backgroundColor: OqoodyTheme.alertRed),
                  );
                }
              }
            },
            child: const Text('دفع وشحن الآن'),
          ),
        ],
      ),
    );
  }

  Future<void> _showWithdrawDialog() async {
    final amountController = TextEditingController(text: '1000');
    final bankController = TextEditingController(text: 'البنك الأهلي المصري');
    final ibanController = TextEditingController(text: 'EG123456789012345678901234');
    final holderController = TextEditingController(text: Provider.of<AuthProvider>(context, listen: false).currentUser?.fullName ?? '');

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: OqoodyTheme.cardBg,
        title: const Text('طلب سحب أرباح أو رصيد', style: TextStyle(color: OqoodyTheme.accentGold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'المبلغ المطلوب سحبه (ج.م)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: bankController,
                decoration: const InputDecoration(labelText: 'اسم البنك أو المحفظة الإلكترونية'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: ibanController,
                decoration: const InputDecoration(labelText: 'رقم الحساب / IBAN / هاتف المحفظة'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: holderController,
                decoration: const InputDecoration(labelText: 'اسم المستفيد ثلاثياً'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(color: OqoodyTheme.textMuted))),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text) ?? 0.0;
              if (amount <= 0) return;
              Navigator.pop(ctx);
              try {
                await ApiService().requestWithdrawal(
                  amount,
                  bankController.text.trim(),
                  ibanController.text.trim(),
                  holderController.text.trim(),
                );
                _loadWallet();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم تقديم طلب السحب وسيقوم القسم المالي بالتحويل خلال 24 ساعة'), backgroundColor: OqoodyTheme.successGreen),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('فشل طلب السحب: $e'), backgroundColor: OqoodyTheme.alertRed),
                  );
                }
              }
            },
            child: const Text('إرسال طلب السحب'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy - hh:mm a', 'ar');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: OqoodyTheme.primaryDark,
        title: const Text('المحفظة والعمليات المالية', style: TextStyle(color: OqoodyTheme.accentGold, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: OqoodyTheme.accentGold),
            onPressed: _loadWallet,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadWallet,
        color: OqoodyTheme.accentGold,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balances Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [OqoodyTheme.primaryDark, OqoodyTheme.cardBg],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: OqoodyTheme.accentGold.withOpacity(0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text('الرصيد المتاح للسحب أو الاستخدام', style: TextStyle(color: OqoodyTheme.textMuted, fontSize: 13)),
                    const SizedBox(height: 8),
                    Text(
                      '${_walletBalance.toStringAsFixed(0)} ج.م',
                      style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: OqoodyTheme.accentGold),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: OqoodyTheme.primaryDark,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: OqoodyTheme.primaryEmerald),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.lock, size: 14, color: Colors.amber),
                          const SizedBox(width: 6),
                          Text(
                            'المبلغ المحتجز في الضمان: ${_heldBalance.toStringAsFixed(0)} ج.م',
                            style: const TextStyle(fontSize: 12, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _showTopupDialog,
                            icon: const Icon(Icons.add_card),
                            label: const Text('شحن المحفظة'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _showWithdrawDialog,
                            icon: const Icon(Icons.arrow_upward, color: OqoodyTheme.accentGold),
                            label: const Text('سحب أرباح', style: TextStyle(color: Colors.white)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: OqoodyTheme.accentGold),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),
              const Text('سجل المعاملات والتحويلات:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: OqoodyTheme.accentGold)),
              const SizedBox(height: 12),

              if (_isLoading)
                const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(color: OqoodyTheme.accentGold)))
              else if (_transactions.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 56, color: OqoodyTheme.textMuted),
                        SizedBox(height: 10),
                        Text('لا توجد حركات مالية مسجلة بعد', style: TextStyle(color: OqoodyTheme.textMuted)),
                      ],
                    ),
                  ),
                )
              else
                ..._transactions.map((tx) {
                  final isCredit = tx.amount > 0;
                  final timeStr = tx.createdAt != null ? dateFormat.format(tx.createdAt!) : 'مؤخراً';

                  return Card(
                    color: OqoodyTheme.cardBg,
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: OqoodyTheme.primaryEmerald),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      leading: CircleAvatar(
                        backgroundColor: (isCredit ? OqoodyTheme.successGreen : OqoodyTheme.alertRed).withOpacity(0.15),
                        child: Icon(
                          isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                          color: isCredit ? OqoodyTheme.successGreen : OqoodyTheme.alertRed,
                        ),
                      ),
                      title: Text(tx.description, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text(timeStr, style: const TextStyle(color: OqoodyTheme.textMuted, fontSize: 11)),
                      trailing: Text(
                        '${isCredit ? '+' : ''}${tx.amount.toStringAsFixed(0)} ج.م',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isCredit ? OqoodyTheme.successGreen : OqoodyTheme.alertRed,
                        ),
                      ),
                    ),
                  );
                }),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
