class CardModel {
  final String cardNumber;
  final String companyName;
  final String cardType;

  CardModel({
    required this.cardNumber,
    required this.companyName,
    required this.cardType,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      cardNumber: json['cardNumber'] ?? '',
      companyName: json['companyName'] ?? '',
      cardType: json['cardType'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cardNumber': cardNumber,
      'companyName': companyName,
      'cardType': cardType,
    };
  }
}

class CardsData {
  final List<CardModel> cards;

  CardsData({required this.cards});

  factory CardsData.fromJson(Map<String, dynamic> json) {
    List<CardModel> cardsList = [];
    if (json['cards'] != null) {
      cardsList = (json['cards'] as List)
          .map((cardJson) => CardModel.fromJson(cardJson))
          .toList();
    }
    return CardsData(cards: cardsList);
  }
}
