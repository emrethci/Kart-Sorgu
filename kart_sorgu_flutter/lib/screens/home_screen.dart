import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/card_service.dart';
import '../models/card.dart' as card_model;
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _cardNumberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  card_model.CardModel? _foundCard;
  bool _isSearching = false;
  String _searchResult = '';

  @override
  void dispose() {
    _cardNumberController.dispose();
    super.dispose();
  }

  void _searchCard() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSearching = true;
      _foundCard = null;
      _searchResult = '';
    });

    // Simüle edilmiş gecikme
    await Future.delayed(const Duration(milliseconds: 300));

    final cardNumber = _cardNumberController.text.trim();
    final foundCard = CardService.searchCard(cardNumber);

    setState(() {
      _isSearching = false;
      _foundCard = foundCard;
      
      if (foundCard != null) {
        _searchResult = '${foundCard.companyName} firması ${foundCard.cardType}';
      } else {
        _searchResult = 'Kart bulunamadı!\n\nGirilen kart numarası: $cardNumber';
      }
    });
  }

  void _logout() {
    AuthService.logout();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _clearSearch() {
    setState(() {
      _cardNumberController.clear();
      _foundCard = null;
      _searchResult = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2261B4),
              Color(0xFFA66E2A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Kart Kime Ait',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: _logout,
                      icon: const Icon(
                        Icons.logout,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),

              // Ana İçerik
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Başlık
                      const Icon(
                        Icons.credit_card,
                        size: 64,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Kart Sorgulama',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Kart numarasını girerek firma bilgilerini öğrenin',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Arama Formu
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                                                         Container(
                               decoration: BoxDecoration(
                                 borderRadius: BorderRadius.circular(16),
                                 boxShadow: [
                                   BoxShadow(
                                     color: Colors.black.withOpacity(0.1),
                                     blurRadius: 10,
                                     offset: const Offset(0, 4),
                                   ),
                                 ],
                               ),
                               child: TextFormField(
                                 controller: _cardNumberController,
                                 style: const TextStyle(fontSize: 16),
                                 decoration: InputDecoration(
                                   labelText: 'Kart Numarası',
                                   hintText: 'Örn: 4950028928684957',
                                   prefixIcon: const Icon(Icons.credit_card_outlined, color: Colors.blue),
                                   filled: true,
                                   fillColor: Colors.white,
                                   border: OutlineInputBorder(
                                     borderRadius: BorderRadius.circular(16),
                                     borderSide: BorderSide.none,
                                   ),
                                   enabledBorder: OutlineInputBorder(
                                     borderRadius: BorderRadius.circular(16),
                                     borderSide: BorderSide.none,
                                   ),
                                   focusedBorder: OutlineInputBorder(
                                     borderRadius: BorderRadius.circular(16),
                                     borderSide: const BorderSide(color: Colors.blue, width: 2),
                                   ),
                                   errorBorder: OutlineInputBorder(
                                     borderRadius: BorderRadius.circular(16),
                                     borderSide: const BorderSide(color: Colors.red, width: 2),
                                   ),
                                   contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                 ),
                                 validator: (value) {
                                   if (value == null || value.isEmpty) {
                                     return 'Kart numarası gerekli';
                                   }
                                   return null;
                                 },
                               ),
                             ),
                            const SizedBox(height: 16),

                                                         Row(
                               children: [
                                 Expanded(
                                   child: Container(
                                     height: 56,
                                     decoration: BoxDecoration(
                                       borderRadius: BorderRadius.circular(16),
                                       gradient: const LinearGradient(
                                         colors: [Colors.blue, Colors.blueAccent],
                                         begin: Alignment.centerLeft,
                                         end: Alignment.centerRight,
                                       ),
                                       boxShadow: [
                                         BoxShadow(
                                           color: Colors.blue.withOpacity(0.3),
                                           blurRadius: 15,
                                           offset: const Offset(0, 8),
                                         ),
                                       ],
                                     ),
                                     child: ElevatedButton(
                                       onPressed: _isSearching ? null : _searchCard,
                                       style: ElevatedButton.styleFrom(
                                         backgroundColor: Colors.transparent,
                                         foregroundColor: Colors.white,
                                         shadowColor: Colors.transparent,
                                         shape: RoundedRectangleBorder(
                                           borderRadius: BorderRadius.circular(16),
                                         ),
                                         elevation: 0,
                                       ),
                                       child: _isSearching
                                           ? const SizedBox(
                                               height: 24,
                                               width: 24,
                                               child: CircularProgressIndicator(
                                                 strokeWidth: 3,
                                                 valueColor: AlwaysStoppedAnimation<Color>(
                                                   Colors.white,
                                                 ),
                                               ),
                                             )
                                           : Row(
                                               mainAxisAlignment: MainAxisAlignment.center,
                                               children: [
                                                 const Icon(Icons.search, size: 20),
                                                 const SizedBox(width: 8),
                                                 const Text(
                                                   'Ara',
                                                   style: TextStyle(
                                                     fontSize: 18,
                                                     fontWeight: FontWeight.w600,
                                                   ),
                                                 ),
                                               ],
                                             ),
                                     ),
                                   ),
                                 ),
                                 const SizedBox(width: 12),
                                 Container(
                                   height: 56,
                                   width: 56,
                                                                       decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      gradient: const LinearGradient(
                                        colors: [Colors.grey, Color(0xFF757575)],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                     boxShadow: [
                                       BoxShadow(
                                         color: Colors.grey.withOpacity(0.3),
                                         blurRadius: 15,
                                         offset: const Offset(0, 8),
                                       ),
                                     ],
                                   ),
                                   child: ElevatedButton(
                                     onPressed: _clearSearch,
                                     style: ElevatedButton.styleFrom(
                                       backgroundColor: Colors.transparent,
                                       foregroundColor: Colors.white,
                                       shadowColor: Colors.transparent,
                                       shape: RoundedRectangleBorder(
                                         borderRadius: BorderRadius.circular(16),
                                       ),
                                       elevation: 0,
                                       padding: EdgeInsets.zero,
                                     ),
                                     child: const Icon(Icons.clear, size: 24),
                                   ),
                                 ),
                               ],
                             ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Sonuç Alanı
                      if (_searchResult.isNotEmpty)
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: _foundCard != null
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _foundCard != null
                                    ? Colors.green
                                    : Colors.red,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      _foundCard != null
                                          ? Icons.check_circle
                                          : Icons.error,
                                      color: _foundCard != null
                                          ? Colors.green
                                          : Colors.red,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _foundCard != null
                                          ? 'Kart Bulundu'
                                          : 'Kart Bulunamadı',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: _foundCard != null
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchResult,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    height: 1.5,
                                  ),
                                ),
                                if (_foundCard != null) ...[
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Firma: ${_foundCard!.companyName}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text('Tür: ${_foundCard!.cardType}'),
                                        const SizedBox(height: 4),
                                        Text('Numara: ${_foundCard!.cardNumber}'),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
