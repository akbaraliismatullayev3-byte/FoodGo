import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { uz, ru, en }

class LanguageProvider with ChangeNotifier {
  AppLanguage _currentLanguage = AppLanguage.uz;

  LanguageProvider() {
    _loadLanguage();
  }

  AppLanguage get currentLanguage => _currentLanguage;

  String get languageCode {
    switch (_currentLanguage) {
      case AppLanguage.uz: return 'uz';
      case AppLanguage.ru: return 'ru';
      case AppLanguage.en: return 'en';
    }
  }

  void setLanguage(AppLanguage language) async {
    _currentLanguage = language;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', languageCode);
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('app_language') ?? 'uz';
    _currentLanguage = AppLanguage.values.firstWhere(
      (l) => l.toString().split('.').last == code,
      orElse: () => AppLanguage.uz,
    );
    notifyListeners();
  }

  static final Map<String, Map<AppLanguage, String>> _translations = {
    // Auth
    'login': {AppLanguage.uz: 'Kirish', AppLanguage.ru: 'Вход', AppLanguage.en: 'Login'},
    'email': {AppLanguage.uz: 'Email', AppLanguage.ru: 'Email', AppLanguage.en: 'Email'},
    'password': {AppLanguage.uz: 'Parol', AppLanguage.ru: 'Пароль', AppLanguage.en: 'Password'},
    'register': {AppLanguage.uz: 'Ro\'yxatdan o\'tish', AppLanguage.ru: 'Регистрация', AppLanguage.en: 'Register'},
    
    // Home
    'search_hint': {AppLanguage.uz: 'Taomlarni qidirish...', AppLanguage.ru: 'Поиск блюд...', AppLanguage.en: 'Search dishes...'},
    'categories': {AppLanguage.uz: 'Kategoriyalar', AppLanguage.ru: 'Категории', AppLanguage.en: 'Categories'},
    'recommended': {AppLanguage.uz: 'Tavsiya etiladi', AppLanguage.ru: 'Рекомендуем', AppLanguage.en: 'Recommended'},
    'popular': {AppLanguage.uz: 'Ommabop', AppLanguage.ru: 'Популярное', AppLanguage.en: 'Popular'},
    'see_all': {AppLanguage.uz: 'Hammasi', AppLanguage.ru: 'Все', AppLanguage.en: 'See All'},
    
    // Bottom Nav
    'home': {AppLanguage.uz: 'Asosiy', AppLanguage.ru: 'Главная', AppLanguage.en: 'Home'},
    'search': {AppLanguage.uz: 'Qidiruv', AppLanguage.ru: 'Поиск', AppLanguage.en: 'Search'},
    'orders': {AppLanguage.uz: 'Buyurtmalar', AppLanguage.ru: 'Заказы', AppLanguage.en: 'Orders'},
    'profile': {AppLanguage.uz: 'Profil', AppLanguage.ru: 'Профиль', AppLanguage.en: 'Profile'},
    'burgers': {AppLanguage.uz: 'Burgerlar', AppLanguage.ru: 'Бургеры', AppLanguage.en: 'Burgers'},
    'pizza': {AppLanguage.uz: 'Pitsalar', AppLanguage.ru: 'Пицца', AppLanguage.en: 'Pizza'},
    'sushi': {AppLanguage.uz: 'Sushilar', AppLanguage.ru: 'Суши', AppLanguage.en: 'Sushi'},
    'desserts': {AppLanguage.uz: 'Desertlar', AppLanguage.ru: 'Десерты', AppLanguage.en: 'Desserts'},
    
    // Cart/Orders
    'cart': {AppLanguage.uz: 'Savat', AppLanguage.ru: 'Корзина', AppLanguage.en: 'Cart'},
    'checkout': {AppLanguage.uz: 'Buyurtma berish', AppLanguage.ru: 'Оформить заказ', AppLanguage.en: 'Checkout'},
    'total': {AppLanguage.uz: 'Jami', AppLanguage.ru: 'Итого', AppLanguage.en: 'Total'},
    'order_history': {AppLanguage.uz: 'Tarix', AppLanguage.ru: 'История', AppLanguage.en: 'History'},
    'cart_tab': {AppLanguage.uz: 'Savat', AppLanguage.ru: 'Корзина', AppLanguage.en: 'Cart'},
    'trending': {AppLanguage.uz: 'Trenddagi taomlar', AppLanguage.ru: 'В тренде', AppLanguage.en: 'Trending Dishes'},
    'restaurants': {AppLanguage.uz: 'Restoranlar', AppLanguage.ru: 'Рестораны', AppLanguage.en: 'Restaurants'},
    'no_results': {AppLanguage.uz: 'Hech narsa topilmadi', AppLanguage.ru: 'Ничего не найдено', AppLanguage.en: 'No results found'},
    
    // Auth
    'welcome_back': {AppLanguage.uz: 'Xush kelibsiz', AppLanguage.ru: 'С возвращением', AppLanguage.en: 'Welcome Back'},
    'create_account': {AppLanguage.uz: 'Roʻyxatdan oʻtish', AppLanguage.ru: 'Создать аккаунт', AppLanguage.en: 'Create Account'},
    'sign_in_subtitle': {AppLanguage.uz: 'Davom etish uchun tizimga kiring', AppLanguage.ru: 'Войдите, чтобы продолжить', AppLanguage.en: 'Sign in to continue'},
    'sign_up_subtitle': {AppLanguage.uz: 'Oshpazlik sayohatingizni boshlang', AppLanguage.ru: 'Начните свое кулинарное путешествие', AppLanguage.en: 'Start your culinary journey'},
    'full_name': {AppLanguage.uz: 'Toʻliq ism', AppLanguage.ru: 'Полное имя', AppLanguage.en: 'Full Name'},
    'email_address': {AppLanguage.uz: 'Email manzil', AppLanguage.ru: 'Email адрес', AppLanguage.en: 'Email Address'},
    'enter_gallery': {AppLanguage.uz: 'Kirish', AppLanguage.ru: 'Войти в галерею', AppLanguage.en: 'Enter the Gallery'},
    'begin_journey': {AppLanguage.uz: 'Boshlash', AppLanguage.ru: 'Начать путешествие', AppLanguage.en: 'Begin Journey'},
    'signup': {AppLanguage.uz: 'Roʻyxatdan oʻtish', AppLanguage.ru: 'Регистрация', AppLanguage.en: 'Sign Up'},
    'forgot_password': {AppLanguage.uz: 'Parolni unutdingizmi?', AppLanguage.ru: 'Забыли пароль?', AppLanguage.en: 'Forgot Password?'},
    'enter_email': {AppLanguage.uz: 'Email kiriting', AppLanguage.ru: 'Введите Email', AppLanguage.en: 'Enter Email'},
    'invalid_email': {AppLanguage.uz: 'Email noto\'g\'ri', AppLanguage.ru: 'Неверный Email', AppLanguage.en: 'Invalid Email'},
    'enter_password': {AppLanguage.uz: 'Parol kiriting', AppLanguage.ru: 'Введите пароль', AppLanguage.en: 'Enter Password'},
    'password_too_short': {AppLanguage.uz: 'Parol juda qisqa', AppLanguage.ru: 'Пароль слишком короткий', AppLanguage.en: 'Password too short'},
    'or': {AppLanguage.uz: 'yoki', AppLanguage.ru: 'или', AppLanguage.en: 'or'},
    'no_account': {AppLanguage.uz: 'Hisobingiz yo\'qmi?', AppLanguage.ru: 'Нет аккаунта?', AppLanguage.en: 'No account?'},
    'gender': {AppLanguage.uz: 'Jins', AppLanguage.ru: 'Пол', AppLanguage.en: 'Gender'},
    'male': {AppLanguage.uz: 'Erkak', AppLanguage.ru: 'Мужской', AppLanguage.en: 'Male'},
    'female': {AppLanguage.uz: 'Ayol', AppLanguage.ru: 'Женский', AppLanguage.en: 'Female'},
    'name_too_short': {AppLanguage.uz: 'Ism juda qisqa', AppLanguage.ru: 'Имя слишком короткое', AppLanguage.en: 'Name too short'},
    'enter_name': {AppLanguage.uz: 'Ismingizni kiriting', AppLanguage.ru: 'Введите ваше имя', AppLanguage.en: 'Enter your name'},
    'password_strength': {AppLanguage.uz: 'Parol kuchi', AppLanguage.ru: 'Сложность пароля', AppLanguage.en: 'Password Strength'},
    'weak': {AppLanguage.uz: 'Zaif', AppLanguage.ru: 'Слабый', AppLanguage.en: 'Weak'},
    'medium': {AppLanguage.uz: 'O\'rta', AppLanguage.ru: 'Средний', AppLanguage.en: 'Medium'},
    'strong': {AppLanguage.uz: 'Kuchli', AppLanguage.ru: 'Сильный', AppLanguage.en: 'Strong'},
    'confirm_password': {AppLanguage.uz: 'Parolni tasdiqlash', AppLanguage.ru: 'Подтвердите пароль', AppLanguage.en: 'Confirm Password'},
    'passwords_not_match': {AppLanguage.uz: 'Parollar mos kelmadi', AppLanguage.ru: 'Пароли не совпадают', AppLanguage.en: 'Passwords do not match'},
    'already_have_account': {AppLanguage.uz: 'Hisobingiz bormi?', AppLanguage.ru: 'Уже есть аккаунт?', AppLanguage.en: 'Already have an account?'},

    'add_to_cart': {AppLanguage.uz: 'Savatga qoʻshish', AppLanguage.ru: 'В корзину', AppLanguage.en: 'Add to Cart'},
    'calories': {AppLanguage.uz: 'Kaloriya', AppLanguage.ru: 'Калории', AppLanguage.en: 'Calories'},
    'protein': {AppLanguage.uz: 'Oqsil', AppLanguage.ru: 'Белок', AppLanguage.en: 'Protein'},
    'customizations': {AppLanguage.uz: 'Qoʻshimchalar', AppLanguage.ru: 'Настройки', AppLanguage.en: 'Customizations'},
    'description': {AppLanguage.uz: 'Tavsif', AppLanguage.ru: 'Описание', AppLanguage.en: 'Description'},
    'clear_all': {AppLanguage.uz: 'Tozalash', AppLanguage.ru: 'Очистить', AppLanguage.en: 'Clear All'},
    'nutrition': {AppLanguage.uz: 'Ozuqaviy qiymati', AppLanguage.ru: 'Пищевая ценность', AppLanguage.en: 'Nutritional Profile'},

    'edit_profile': {AppLanguage.uz: 'Profilni tahrirlash', AppLanguage.ru: 'Редактировать профиль', AppLanguage.en: 'Edit Profile'},
    'favorites': {AppLanguage.uz: 'Sevimlilar', AppLanguage.ru: 'Избранное', AppLanguage.en: 'Favorites'},
    'admin_panel': {AppLanguage.uz: 'Admin Panel', AppLanguage.ru: 'Админ панель', AppLanguage.en: 'Admin Panel'},
    'gold_member': {AppLanguage.uz: 'OLTIN A’ZO', AppLanguage.ru: 'GOLD MEMBER', AppLanguage.en: 'GOLD MEMBER'},

    'add_product': {AppLanguage.uz: 'Yangi taom qoʻshish', AppLanguage.ru: 'Добавить продукт', AppLanguage.en: 'Add Product'},
    'product_name': {AppLanguage.uz: 'Taom nomi', AppLanguage.ru: 'Название продукта', AppLanguage.en: 'Product Name'},
    'product_price': {AppLanguage.uz: 'Narxi', AppLanguage.ru: 'Цена', AppLanguage.en: 'Price'},
    'product_image': {AppLanguage.uz: 'Rasm URL', AppLanguage.ru: 'URL изображения', AppLanguage.en: 'Image URL'},
    'save_to_gallery': {AppLanguage.uz: 'Galereyaga qoʻshish', AppLanguage.ru: 'Добавить в галерею', AppLanguage.en: 'Save to Gallery'},

    // Banners
    'banner_promo': {AppLanguage.uz: 'Maxsus taklif', AppLanguage.ru: 'Спецпредложение', AppLanguage.en: 'Special Offer'},
    'banner_free': {AppLanguage.uz: 'Tekin yetkazib berish', AppLanguage.ru: 'Бесплатная доставка', AppLanguage.en: 'Free Delivery'},
    'banner_new': {AppLanguage.uz: 'Yangi mavsum', AppLanguage.ru: 'Новый сезон', AppLanguage.en: 'New Season'},
    'order_now': {AppLanguage.uz: 'Buyurtma berish', AppLanguage.ru: 'Заказать сейчас', AppLanguage.en: 'Order Now'},

    // Profile
    'settings': {AppLanguage.uz: 'Sozlamalar', AppLanguage.ru: 'Настройки', AppLanguage.en: 'Settings'},
    'language': {AppLanguage.uz: 'Til', AppLanguage.ru: 'Язык', AppLanguage.en: 'Language'},
    'logout': {AppLanguage.uz: 'Chiqish', AppLanguage.ru: 'Выход', AppLanguage.en: 'Logout'},
    'dark_mode': {AppLanguage.uz: 'Tungi rejim', AppLanguage.ru: 'Темная тема', AppLanguage.en: 'Dark Mode'},
    'about_us': {AppLanguage.uz: 'Biz haqimizda', AppLanguage.ru: 'О нас', AppLanguage.en: 'About Us'},
    'contact_us': {AppLanguage.uz: 'Aloqa', AppLanguage.ru: 'Контакты', AppLanguage.en: 'Contact Us'},
    'news': {AppLanguage.uz: 'Yangiliklar', AppLanguage.ru: 'Новости', AppLanguage.en: 'News'},
    'write_review': {AppLanguage.uz: 'Fikr bildirish', AppLanguage.ru: 'Оставить отзыв', AppLanguage.en: 'Write a Review'},
    'submit': {AppLanguage.uz: 'Yuborish', AppLanguage.ru: 'Отправить', AppLanguage.en: 'Submit'},
    'review_success': {AppLanguage.uz: 'Siz yozgan sharh qabul qilindi', AppLanguage.ru: 'Ваш отзыв принят', AppLanguage.en: 'Your review has been accepted'},
    'ai_assistant': {AppLanguage.uz: 'Lumière AI yordamchisi', AppLanguage.ru: 'AI помощник Lumière', AppLanguage.en: 'Lumière AI Assistant'},
    'type_message': {AppLanguage.uz: 'Xabar yozing...', AppLanguage.ru: 'Напишите сообщение...', AppLanguage.en: 'Type a message...'},
    'yes': {AppLanguage.uz: 'Ha', AppLanguage.ru: 'Да', AppLanguage.en: 'Yes'},
    'no': {AppLanguage.uz: 'Yo\'q', AppLanguage.ru: 'Нет', AppLanguage.en: 'No'},
    'logout_confirm': {AppLanguage.uz: 'Haqiqatan ham chiqmoqchimisiz?', AppLanguage.ru: 'Вы уверены, что хотите выйти?', AppLanguage.en: 'Are you sure you want to logout?'},
  };

  String translate(String key) {
    return _translations[key]?[_currentLanguage] ?? key;
  }
}

extension LanguageExtension on BuildContext {
  String t(String key) {
    return Provider.of<LanguageProvider>(this).translate(key);
  }
}
