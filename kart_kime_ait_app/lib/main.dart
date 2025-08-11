import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:convert';

void main() {
  runApp(const KartKimeAitApp());
}

class KartKimeAitApp extends StatelessWidget {
  const KartKimeAitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kart Kime Ait',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  // Local kullanıcı bilgileri
  static const Map<String, String> localUsers = {
    'demo': 'demo123',
    'admin': 'admin123',
    'test': 'test123',
  };

  // Local kullanıcı bilgileri
  static const Map<String, String> localUsers = {
    'demo': 'demo123',
    'admin': 'admin123',
    'test': 'test123',
  };

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('userEmail');
    final savedPassword = prefs.getString('userPassword');

    if (savedEmail != null && savedPassword != null) {
      _emailController.text = savedEmail;
      _passwordController.text = savedPassword;
      await _performLogin(true);
    }
  }

  Future<void> _performLogin(bool isAutoLogin) async {
    if (!isAutoLogin) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // Local kullanıcı kontrolü
      if (localUsers.containsKey(email) && localUsers[email] == password) {
        // Giriş bilgilerini kaydet
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userEmail', email);
        await prefs.setString('userPassword', password);
        await prefs.setString('sessionToken', 'local_session_${DateTime.now().millisecondsSinceEpoch}');

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        }
      } else {
        if (!isAutoLogin) {
          setState(() {
            _errorMessage = 'Geçersiz kullanıcı adı veya şifre';
          });
        } else {
          // Otomatik giriş başarısızsa localStorage'ı temizle
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('userEmail');
          await prefs.remove('userPassword');
        }
      }
    } catch (error) {
      if (!isAutoLogin) {
        setState(() {
          _errorMessage = 'Giriş sırasında hata oluştu';
        });
      } else {
        // Otomatik giriş başarısızsa localStorage'ı temizle
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('userEmail');
        await prefs.remove('userPassword');
      }
    } finally {
      if (!isAutoLogin) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2261b4), Color(0xFFa66e2a)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Header
                  const Column(
                    children: [
                      Icon(
                        Icons.lock,
                        size: 48,
                        color: Colors.white,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Giriş Yap',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Devam etmek için giriş yapın',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Login Form
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 400),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Email Field
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Kullanıcı Adı',
                              prefixIcon: Icon(Icons.person),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Kullanıcı adı gerekli';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Şifre',
                              prefixIcon: Icon(Icons.lock),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Şifre gerekli';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : () async {
                                if (_formKey.currentState!.validate()) {
                                  await _performLogin(false);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _isLoading
                                  ? const SpinKitThreeBounce(
                                      color: Colors.white,
                                      size: 20,
                                    )
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.login),
                                        SizedBox(width: 8),
                                        Text(
                                          'Giriş Yap',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                            ),
                          ),

                          // Demo Bilgileri
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              border: Border.all(color: Colors.blue.shade200),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Column(
                              children: [
                                Text(
                                  'Demo Kullanıcı Bilgileri:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Kullanıcı: demo, Şifre: demo123',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ],
                            ),
                          ),

                          // Error Message
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                border: Border.all(color: Colors.red.shade200),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error, color: Colors.red.shade600),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: TextStyle(color: Colors.red.shade700),
                                    ),
                                  ),
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
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _cardController = TextEditingController();
  bool _isLoading = false;
  String? _result;
  String? _errorMessage;
  String? _originalInput;

  // Local kart verileri (orijinal JSON'dan alınan veriler)
  static const Map<String, Map<String, String>> localCards = {
    '4950028928684957': {'companyName': 'VİNA KUYUMCULUK', 'cardType': 'GİYİM KARTI'},
    '4950029813611208': {'companyName': 'VİNA KUYUMCULUK', 'cardType': 'GİYİM KARTI'},
    '4950020708911274': {'companyName': 'VİNA KUYUMCULUK', 'cardType': 'GİYİM KARTI'},
    '4950021643954865': {'companyName': 'HG İNOVASYON', 'cardType': 'GİYİM KARTI'},
    '4950020250246953': {'companyName': 'HG İNOVASYON', 'cardType': 'GİYİM KARTI'},
    '4950027431506513': {'companyName': 'HG İNOVASYON', 'cardType': 'GİYİM KARTI'},
    '4950028269702318': {'companyName': 'HEXCEL', 'cardType': 'MARKET KARTI'},
    '4950028300289772': {'companyName': 'HEXCEL', 'cardType': 'MARKET KARTI'},
    '4950026069354474': {'companyName': 'HEXCEL', 'cardType': 'MARKET KARTI'},
    '4950024056017684': {'companyName': 'HEXCEL', 'cardType': 'MARKET KARTI'},
    '4950027766769640': {'companyName': 'HEXCEL', 'cardType': 'MARKET KARTI'},
    '4950020175867249': {'companyName': 'HEXCEL', 'cardType': 'MARKET KARTI'},
    '4950029347220121': {'companyName': 'HEXCEL', 'cardType': 'MARKET KARTI'},
    '4950025981486971': {'companyName': 'HEXCEL', 'cardType': 'MARKET KARTI'},
    '4950026328658050': {'companyName': 'HEXCEL', 'cardType': 'MARKET KARTI'},
    '4950023230306343': {'companyName': 'HEXCEL', 'cardType': 'MARKET KARTI'},
    '4950028852667724': {'companyName': 'HEXCEL', 'cardType': 'MARKET KARTI'},
    '4950020879369588': {'companyName': 'HEXCEL', 'cardType': 'MARKET KARTI'},
    '4950023507320197': {'companyName': 'HEXCEL', 'cardType': 'MARKET KARTI'},
    '4950027543747786': {'companyName': 'HEXCEL', 'cardType': 'MARKET KARTI'},
    '4950023654618659': {'companyName': 'HEXCEL', 'cardType': 'MARKET KARTI'},
    '4950027200212837': {'companyName': 'HEXCEL', 'cardType': 'MARKET KARTI'},
    '4950030129052016': {'companyName': 'HEXCEL', 'cardType': 'MARKET KARTI'},
    '4950025875362544': {'companyName': 'HEXCEL', 'cardType': 'MARKET KARTI'},
    '4950023366329406': {'companyName': 'HEXCEL', 'cardType': 'MARKET KARTI'},
    '4950029101400398': {'companyName': 'HEXCEL', 'cardType': 'MARKET KARTI'},
    '4950026054287916': {'companyName': 'HEXCEL', 'cardType': 'MARKET KARTI'},
    '4950020820555859': {'companyName': 'HEXCEL', 'cardType': 'MARKET KARTI'},
    '4950023676588680': {'companyName': 'HEXCEL', 'cardType': 'MARKET KARTI'},
    '4950021754937078': {'companyName': 'HEXCEL', 'cardType': 'MARKET KARTI'},
    '4950020327070752': {'companyName': 'HEXCEL', 'cardType': 'MARKET KARTI'},
    '4950023684240712': {'companyName': 'HEXCEL', 'cardType': 'MARKET KARTI'},
    '4950022695733894': {'companyName': 'HEXCEL', 'cardType': 'MARKET KARTI'},
    '4950021466964909': {'companyName': 'HEXCEL', 'cardType': 'MARKET KARTI'},
    '4950027051415418': {'companyName': 'HEXCEL', 'cardType': 'MARKET KARTI'},
    '4950029331989241': {'companyName': 'HEXCEL', 'cardType': 'MARKET KARTI'},
    '4950027564152827': {'companyName': 'HEXCEL', 'cardType': 'MARKET KARTI'},
    '4950025438276522': {'companyName': 'HEXCEL', 'cardType': 'MARKET KARTI'},
    '4950026143430081': {'companyName': 'HEXCEL', 'cardType': 'MARKET KARTI'},
    '4950023419171918': {'companyName': 'HEXCEL', 'cardType': 'MARKET KARTI'},
    '4950023642754104': {'companyName': 'HEXCEL', 'cardType': 'MARKET KARTI'},
    '4950024232569706': {'companyName': 'HEXCEL', 'cardType': 'MARKET KARTI'},
    '4950027904115849': {'companyName': 'HEXCEL', 'cardType': 'MARKET KARTI'},
    '4950026276289834': {'companyName': 'HEXCEL', 'cardType': 'MARKET KARTI'},
    '4950022618218080': {'companyName': 'HEXCEL', 'cardType': 'MARKET KARTI'},
    '4950023231834983': {'companyName': 'HEXCEL', 'cardType': 'MARKET KARTI'},
    '4950024127446616': {'companyName': 'HEXCEL', 'cardType': 'MARKET KARTI'},
    '4950023412572673': {'companyName': 'HEXCEL', 'cardType': 'MARKET KARTI'},
    '4950029144420237': {'companyName': 'HEXCEL', 'cardType': 'MARKET KARTI'},
    '4950028976783100': {'companyName': 'HEXCEL', 'cardType': 'MARKET KARTI'},
    '4950023393763976': {'companyName': 'HEXCEL', 'cardType': 'MARKET KARTI'},
    '4950024914904091': {'companyName': 'HEXCEL', 'cardType': 'MARKET KARTI'},
    '4950023119931306': {'companyName': 'HEXCEL', 'cardType': 'MARKET KARTI'},
    '4950025345377042': {'companyName': 'HEXCEL', 'cardType': 'MARKET KARTI'},
    '4950020296140507': {'companyName': 'ADC MAKİNE', 'cardType': 'MARKET KARTI'},
    '4950029307567783': {'companyName': 'ADC MAKİNE', 'cardType': 'MARKET KARTI'},
    '4950029880828844': {'companyName': 'ADC MAKİNE', 'cardType': 'MARKET KARTI'},
    '4950020556314806': {'companyName': 'ADC MAKİNE', 'cardType': 'MARKET KARTI'},
    '4950024237129902': {'companyName': 'ADC MAKİNE', 'cardType': 'MARKET KARTI'},
    '4950022871594093': {'companyName': 'ADC MAKİNE', 'cardType': 'MARKET KARTI'},
    '4950020518821628': {'companyName': 'ADC MAKİNE', 'cardType': 'MARKET KARTI'},
    '4950028768911268': {'companyName': 'ADC MAKİNE', 'cardType': 'MARKET KARTI'},
    '4950022070481392': {'companyName': 'ADC MAKİNE', 'cardType': 'MARKET KARTI'},
    '4950023811928082': {'companyName': 'ADC MAKİNE', 'cardType': 'MARKET KARTI'},
    '4950022170148154': {'companyName': 'ADC MAKİNE', 'cardType': 'MARKET KARTI'},
    '4950025097316838': {'companyName': 'ADC MAKİNE', 'cardType': 'MARKET KARTI'},
    '4950025047717394': {'companyName': 'ADC MAKİNE', 'cardType': 'MARKET KARTI'},
    '4950024204646955': {'companyName': 'ADC MAKİNE', 'cardType': 'MARKET KARTI'},
    '4950026902358363': {'companyName': 'ADC MAKİNE', 'cardType': 'MARKET KARTI'},
    '4950020872142778': {'companyName': 'ADC MAKİNE', 'cardType': 'MARKET KARTI'},
    '4950025419064389': {'companyName': 'ADC MAKİNE', 'cardType': 'MARKET KARTI'},
    '4950026729452937': {'companyName': 'ADC MAKİNE', 'cardType': 'MARKET KARTI'},
    '4950026018052024': {'companyName': 'ADC MAKİNE', 'cardType': 'MARKET KARTI'},
    '4950028476352216': {'companyName': 'ADC MAKİNE', 'cardType': 'MARKET KARTI'},
    '4950025010235986': {'companyName': 'ADC MAKİNE', 'cardType': 'MARKET KARTI'},
    '4950023430114204': {'companyName': 'ADC MAKİNE', 'cardType': 'MARKET KARTI'},
    '4950024726425425': {'companyName': 'ADC MAKİNE', 'cardType': 'MARKET KARTI'},
    '4950027804508953': {'companyName': 'ADC MAKİNE', 'cardType': 'MARKET KARTI'},
    '4950021053859634': {'companyName': 'ADC MAKİNE', 'cardType': 'MARKET KARTI'},
    '4950020551598267': {'companyName': 'ADC MAKİNE', 'cardType': 'MARKET KARTI'},
    '4950020204904998': {'companyName': 'ADC MAKİNE', 'cardType': 'MARKET KARTI'},
    '4950025187755050': {'companyName': 'ADC MAKİNE', 'cardType': 'MARKET KARTI'},
    '4950025154512626': {'companyName': 'ADC MAKİNE', 'cardType': 'MARKET KARTI'},
    '4950029273042152': {'companyName': 'ADC MAKİNE', 'cardType': 'MARKET KARTI'},
    '4950025031465599': {'companyName': 'ADC MAKİNE', 'cardType': 'MARKET KARTI'},
    '4950027853561543': {'companyName': 'ADC MAKİNE', 'cardType': 'MARKET KARTI'},
    '4950021421771658': {'companyName': 'ADC MAKİNE', 'cardType': 'MARKET KARTI'},
    '4950022524382016': {'companyName': 'ADC MAKİNE', 'cardType': 'MARKET KARTI'},
    '4950021038161600': {'companyName': 'ADC MAKİNE', 'cardType': 'MARKET KARTI'},
    '4950020296140507': {'companyName': 'YARGITAY', 'cardType': 'GİYİM KARTI'},
    '4950029307567783': {'companyName': 'YARGITAY', 'cardType': 'GİYİM KARTI'},
    '4950028325965549': {'companyName': 'ATLAS PNÖMATİK', 'cardType': 'MARKET KARTI'},
    '4950022041902445': {'companyName': 'ATLAS PNÖMATİK', 'cardType': 'MARKET KARTI'},
    '4950020319888058': {'companyName': 'ATLAS PNÖMATİK', 'cardType': 'MARKET KARTI'},
    '4950022296200614': {'companyName': 'ATLAS PNÖMATİK', 'cardType': 'MARKET KARTI'},
    '4950026407384413': {'companyName': 'ATLAS PNÖMATİK', 'cardType': 'MARKET KARTI'},
    '4950024713310222': {'companyName': 'ATLAS PNÖMATİK', 'cardType': 'MARKET KARTI'},
    '4950025608043165': {'companyName': 'ATLAS PNÖMATİK', 'cardType': 'MARKET KARTI'},
    '4950023225667463': {'companyName': 'ATLAS PNÖMATİK', 'cardType': 'MARKET KARTI'},
    '4950024912879561': {'companyName': 'ATLAS PNÖMATİK', 'cardType': 'MARKET KARTI'},
    '4950029134737805': {'companyName': 'ATLAS PNÖMATİK', 'cardType': 'MARKET KARTI'},
    '4950020996759810': {'companyName': 'ATLAS PNÖMATİK', 'cardType': 'MARKET KARTI'},
    '4950024203785201': {'companyName': 'ATLAS PNÖMATİK', 'cardType': 'MARKET KARTI'},
    '4950023245594401': {'companyName': 'ATLAS PNÖMATİK', 'cardType': 'MARKET KARTI'},
    '4950022462098297': {'companyName': 'ATLAS PNÖMATİK', 'cardType': 'MARKET KARTI'},
    '4950028607730267': {'companyName': 'ATLAS PNÖMATİK', 'cardType': 'MARKET KARTI'},
    '4950025283834123': {'companyName': 'ATLAS PNÖMATİK', 'cardType': 'MARKET KARTI'},
    '4950020713304646': {'companyName': 'ATLAS PNÖMATİK', 'cardType': 'MARKET KARTI'},
    '4950022538593133': {'companyName': 'ATLAS PNÖMATİK', 'cardType': 'MARKET KARTI'},
    '4950023928854161': {'companyName': 'ATLAS PNÖMATİK', 'cardType': 'MARKET KARTI'},
    '4950023511745053': {'companyName': 'ATLAS PNÖMATİK', 'cardType': 'MARKET KARTI'},
    '4950029918107128': {'companyName': 'ATLAS PNÖMATİK', 'cardType': 'MARKET KARTI'},
    '4950027268149717': {'companyName': 'ATLAS PNÖMATİK', 'cardType': 'MARKET KARTI'},
    '4950027284360070': {'companyName': 'ATLAS PNÖMATİK', 'cardType': 'MARKET KARTI'},
    '4950027329252216': {'companyName': 'ATLAS PNÖMATİK', 'cardType': 'MARKET KARTI'},
    '4950025463134468': {'companyName': 'ATLAS PNÖMATİK', 'cardType': 'MARKET KARTI'},
    '4950020957737710': {'companyName': 'ATLAS PNÖMATİK', 'cardType': 'MARKET KARTI'},
    '4950021029718912': {'companyName': 'ATLAS PNÖMATİK', 'cardType': 'MARKET KARTI'},
    '4950026532359650': {'companyName': 'ATLAS PNÖMATİK', 'cardType': 'MARKET KARTI'},
    '4950020944454722': {'companyName': 'ATLAS PNÖMATİK', 'cardType': 'MARKET KARTI'},
    '4950020089458524': {'companyName': 'HÜSEYİN BEY', 'cardType': 'GİYİM KARTI'},
    '4950029520115933': {'companyName': 'HÜSEYİN BEY', 'cardType': 'GİYİM KARTI'},
    '4950024643347570': {'companyName': 'HÜSEYİN BEY', 'cardType': 'GİYİM KARTI'},
    '4950021302555896': {'companyName': 'HÜSEYİN BEY', 'cardType': 'GİYİM KARTI'},
    '4950022697711186': {'companyName': 'HÜSEYİN BEY', 'cardType': 'GİYİM KARTI'},
    '4950024351462950': {'companyName': 'HÜSEYİN BEY', 'cardType': 'GİYİM KARTI'},
    '4950021963205481': {'companyName': 'HÜSEYİN BEY', 'cardType': 'GİYİM KARTI'},
    '4950020892648555': {'companyName': 'HÜSEYİN BEY', 'cardType': 'GİYİM KARTI'},
    '4950023788022209': {'companyName': 'HÜSEYİN BEY', 'cardType': 'GİYİM KARTI'},
    '4950024914262517': {'companyName': 'HÜSEYİN BEY', 'cardType': 'GİYİM KARTI'},
    '4950026425555072': {'companyName': 'HÜSEYİN BEY', 'cardType': 'GİYİM KARTI'},
    '4950022283730497': {'companyName': 'HÜSEYİN BEY', 'cardType': 'GİYİM KARTI'},
    '4950025358129689': {'companyName': 'ERCAN BEY', 'cardType': 'GİYİM KARTI'},
    '4950028748244500': {'companyName': 'ERCAN BEY', 'cardType': 'GİYİM KARTI'},
    '4950027441656627': {'companyName': 'BEYDEKOR', 'cardType': 'GİYİM KARTI'},
    '4950022857738434': {'companyName': 'BEYDEKOR', 'cardType': 'GİYİM KARTI'},
    '4950026118821400': {'companyName': 'BEYDEKOR', 'cardType': 'GİYİM KARTI'},
    '4950029238925672': {'companyName': 'BEYDEKOR', 'cardType': 'GİYİM KARTI'},
    '4950028536733703': {'companyName': 'BEYDEKOR', 'cardType': 'GİYİM KARTI'},
    '4950021830588168': {'companyName': 'BEYDEKOR', 'cardType': 'GİYİM KARTI'},
    '4950026792082633': {'companyName': 'BEYDEKOR', 'cardType': 'GİYİM KARTI'},
    '4950021026478118': {'companyName': 'BEYDEKOR', 'cardType': 'GİYİM KARTI'},
    '4950029963143355': {'companyName': 'BEYDEKOR', 'cardType': 'GİYİM KARTI'},
    '4950025994524090': {'companyName': 'BEYDEKOR', 'cardType': 'GİYİM KARTI'},
    '4950024208057419': {'companyName': 'BEYDEKOR', 'cardType': 'GİYİM KARTI'},
    '4950020373623699': {'companyName': 'BEYDEKOR', 'cardType': 'GİYİM KARTI'},
    '4950020731477020': {'companyName': 'BEYDEKOR', 'cardType': 'GİYİM KARTI'},
    '4950026841246048': {'companyName': 'BEYDEKOR', 'cardType': 'GİYİM KARTI'},
    '4950027581424990': {'companyName': 'BEYDEKOR', 'cardType': 'GİYİM KARTI'},
    '4950028169998397': {'companyName': 'BEYDEKOR', 'cardType': 'GİYİM KARTI'},
    '4950028362928880': {'companyName': 'BEYDEKOR', 'cardType': 'GİYİM KARTI'},
    '4950024390620092': {'companyName': 'BEYDEKOR', 'cardType': 'GİYİM KARTI'},
    '4950023911678364': {'companyName': 'BEYDEKOR', 'cardType': 'GİYİM KARTI'},
    '4950021289649727': {'companyName': 'BEYDEKOR', 'cardType': 'GİYİM KARTI'},
    '4950027604760145': {'companyName': 'BEYDEKOR', 'cardType': 'GİYİM KARTI'},
    '4950028420472709': {'companyName': 'BEYDEKOR', 'cardType': 'GİYİM KARTI'},
  };

  Future<void> _searchCard() async {
    final inputValue = _cardController.text.trim();
    
    if (inputValue.isEmpty) {
      setState(() {
        _errorMessage = 'Lütfen bir kart numarası girin';
        _result = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _result = null;
    });

    try {
      // Kart numarasını temizle (boşlukları kaldır)
      final cleanCardNumber = inputValue.replaceAll(' ', '');
      
      // Local kart arama
      final foundCard = localCards[cleanCardNumber];
      
      if (foundCard != null) {
        final resultText = '${foundCard['companyName']} firması ${foundCard['cardType']}';
        setState(() {
          _result = resultText;
          _originalInput = inputValue;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _result = 'Kart bulunamadı!\n\nGirilen kart numarası: $inputValue';
          _originalInput = inputValue;
          _errorMessage = null;
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Kart arama sırasında hata oluştu';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (error) {
      // Hata olsa bile local state'i temizle
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2261b4), Color(0xFFa66e2a)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 50), // Boşluk için
                    const Expanded(
                      child: Column(
                        children: [
                          Icon(
                            Icons.credit_card,
                            size: 48,
                            color: Colors.white,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Kart Kime Ait',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Kart numarasını girerek sahibini öğrenin',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
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
                const SizedBox(height: 32),

                // Main Content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Input Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Kart Numarası',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _cardController,
                                      decoration: const InputDecoration(
                                        hintText: 'Kart numarasını girin...',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.credit_card),
                                      ),
                                      onSubmitted: (_) => _searchCard(),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  SizedBox(
                                    height: 56,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _searchCard,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Icon(Icons.search),
                                    ),
                                  ),
                                ],
                              ),
                              if (_isLoading) ...[
                                const SizedBox(height: 16),
                                const Center(
                                  child: Column(
                                    children: [
                                      SpinKitThreeBounce(
                                        color: Colors.blue,
                                        size: 20,
                                      ),
                                      SizedBox(height: 8),
                                      Text('Aranıyor...'),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Result Card
                        if (_result != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Sonuç',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _result!,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                if (_originalInput != null) ...[
                                  const SizedBox(height: 12),
                                  const Divider(),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Orijinal Giriş: $_originalInput',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                        // Error Message
                        if (_errorMessage != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              border: Border.all(color: Colors.red.shade200),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error, color: Colors.red.shade600),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(color: Colors.red.shade700),
                                  ),
                                ),
                              ],
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
      ),
    );
  }

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }
}
