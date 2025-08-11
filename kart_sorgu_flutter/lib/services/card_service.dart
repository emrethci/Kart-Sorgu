import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/card.dart';

class CardService {
  static List<CardModel> _cards = [];
  static bool _isLoaded = false;

  // Kart verilerini yükle
  static Future<void> loadCards() async {
    if (_isLoaded) return;

    try {
      final String response = await rootBundle.loadString('assets/data/cards.json');
      final data = await json.decode(response);
      final cardsData = CardsData.fromJson(data);
      _cards = cardsData.cards;
      _isLoaded = true;
    } catch (e) {
      print('Kart verileri yüklenirken hata: $e');
      _cards = [];
    }
  }

  // Kart ara
  static CardModel? searchCard(String cardNumber) {
    if (!_isLoaded) {
      print('Kart verileri henüz yüklenmedi!');
      return null;
    }

    // Kart numarasını temizle (boşlukları kaldır)
    final cleanCardNumber = cardNumber.replaceAll(' ', '');
    
    try {
      return _cards.firstWhere(
        (card) => card.cardNumber == cleanCardNumber,
        orElse: () => throw Exception('Kart bulunamadı'),
      );
    } catch (e) {
      return null;
    }
  }

  // Tüm kartları getir
  static List<CardModel> getAllCards() {
    return List.from(_cards);
  }

  // Kart sayısını getir
  static int getCardCount() {
    return _cards.length;
  }
}
