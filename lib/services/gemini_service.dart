import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

/// Grok AI service (xAI Grok-3-mini)
/// Eski GeminiService o'rniga ishlatiladi.
/// Fayl nomi saqlanib qolindi (import'lar o'zgarmaydi).
class GeminiService {
  static const String _baseUrl = 'https://api.x.ai/v1/chat/completions';
  // 🔑 xAI API kalitingizni shu yerga qo'ying: https://console.x.ai
  static const String _apiKey = 'xai-YOUR_GROK_API_KEY_HERE';

  final String languageCode;
  final List<Product> products;
  final List<Map<String, String>> _history = [];

  GeminiService(this.products, {this.languageCode = 'uz'}) {
    _history.add({'role': 'system', 'content': _buildSystemPrompt()});
  }

  String _buildSystemPrompt() {
    final menu = products
        .map((p) =>
            '- [${p.tag}] ${p.name}: \$${p.price.toStringAsFixed(2)}, '
            '${p.calories} kkal, protein: ${p.protein}. ${p.description}')
        .join('\n');

    String langInstruction = "O'zbek tilida gapir.";
    if (languageCode == 'ru') langInstruction = "Govori na russkom yazyke.";
    if (languageCode == 'en') langInstruction = "Speak in English.";

    return '''
Sen Lumiere Gastronomy restoranining Grok AI (xAI tomonidan yaratilgan) yordamchisisan. 
Sening vazifang - mijozlarga eng yuqori darajadagi servis ko'rsatish va ularga menyudagi taomlarni tanlashda ko'maklashish.

Xaraktering:
- Professional, samimiy va biroz hazilkash.
- Haqiqiy insonga o'xshab gaplash (robotdek emas).
- Har bir javobingda bitta so'zni qayta-qayta takrorlama, boy va xilma-xil so'z boyligidan foydalan.
- Mijozga xuddi qadrdon do'stingdek yoki qimmatbaho restoran ofitsiantidek murojaat qil.

$langInstruction

MENYU:
$menu

Qoidalar:
1. Faqat menyudagi taomlarni tavsiya qil.
2. Narx, kaloriya va tarkibini aytib berish orqali mijozda ishtaha uyg'ot.
3. Agar so'ralgan taom yo'q bo'lsa, "Afsuski bu yo'q, lekin uning o'rniga bizda yanada mazaliroq..." deb boshqa variant taklif qil.
4. Javoblaringni qisqa (3-5 jumla) va mazmunli qil.
5. Har doim turli xil gap qurilmalaridan foydalan, bir xil shablonlardan qoch!
''';
  }

  Future<String> sendMessage(String userMessage) async {
    _history.add({'role': 'user', 'content': userMessage});

    if (_apiKey.contains('YOUR_GROK')) {
      final reply = _demoResponse(userMessage);
      _history.add({'role': 'assistant', 'content': reply});
      return reply;
    }

    try {
      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'Authorization': 'Bearer $_apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': 'grok-3-mini',
              'messages': _history,
              'temperature': 0.7,
              'max_tokens': 512,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        _history.add({'role': 'assistant', 'content': content});
        return content;
      } else if (response.statusCode == 401) {
        return languageCode == 'en'
            ? 'Grok API key is invalid. Check console.x.ai'
            : "Grok API kaliti noto'g'ri. console.x.ai ni tekshiring.";
      } else {
        return _demoResponse(userMessage);
      }
    } catch (_) {
      return _demoResponse(userMessage);
    }
  }

  String _demoResponse(String query) {
    // Demo mahsulotlar agar baza bo'sh bo'lsa
    final List<Product> effectiveProducts = products.isNotEmpty 
      ? products 
      : [
          Product(
            id: 'demo1',
            name: 'Royal Burger',
            description: 'Eng mazali va suvli burger, maxsus sous bilan.',
            imageUrl: '',
            price: 12.99,
            rating: 4.9,
            reviews: 120,
            calories: 550,
            protein: '25g',
            tag: 'Burgers',
          ),
          Product(
            id: 'demo2',
            name: 'Margherita Pizza',
            description: 'Klassik italyancha pitsa, yangi motsarella va rayhon bilan.',
            imageUrl: '',
            price: 14.50,
            rating: 4.8,
            reviews: 85,
            calories: 800,
            protein: '18g',
            tag: 'Pizza',
          ),
          Product(
            id: 'demo3',
            name: 'Salmon Roll',
            description: 'Yangi losos va krem-pishloqli sushilar.',
            imageUrl: '',
            price: 18.00,
            rating: 4.9,
            reviews: 210,
            calories: 320,
            protein: '22g',
            tag: 'Sushi',
          ),
        ];

    final q = query.toLowerCase();
    Product? match;
    for (final p in effectiveProducts) {
      if (p.name.toLowerCase().contains(q) ||
          p.tag.toLowerCase().contains(q) ||
          q.contains(p.tag.toLowerCase())) {
        match = p;
        break;
      }
    }
    match ??= effectiveProducts.reduce((a, b) => a.rating > b.rating ? a : b);

    if (languageCode == 'en') {
      return '🤖 I recommend "${match.name}" — \$${match.price.toStringAsFixed(2)}, '
          '${match.calories} kcal. ${match.description} Want to order it? 🍽️';
    }
    if (languageCode == 'ru') {
      return '🤖 Рекомендую "${match.name}" — \$${match.price.toStringAsFixed(2)}, '
          '${match.calories} ккал. ${match.description} Хотите заказать? 🍽️';
    }
    return '🤖 "${match.name}" ni tavsiya qilaman — \$${match.price.toStringAsFixed(2)}, '
        "${match.calories} kkal. ${match.description} Buyurtma berasizmi? 🍽️";
  }
}
