# لوحة تحكم الأمير سوبر ماركت - Admin Panel

برنامج إدارة متجر الأمير سوبر ماركت - للأدمن فقط بدون الحاجة لتسجيل دخول.

## المميزات

### 1. إدارة الأقسام (Categories)
- إضافة أقسام جديدة
- تعديل الأقسام الموجودة
- حذف الأقسام
- إضافة وصف للقسم (اختياري)

### 2. إدارة المنتجات (Products)
- إضافة منتجات جديدة
- تعديل المنتجات (الاسم، الوصف، السعر، الصور)
- حذف المنتجات
- تحديد القسم لكل منتج
- تحديد إذا كان المنتج متوفر أم لا
- تحديد المنتجات المميزة (Featured)
- السعر القديم (لعرض التخفيضات)
- تصفية المنتجات حسب القسم

### 3. إدارة الطلبات (Orders)
- عرض جميع الطلبات
- تغيير حالة الطلب (قيد الانتظار → جاري التجهيز → في الطريق → تم التسليم ، أو ملغي)
- عرض تفاصيل الطلب الكاملة (العميل، الهاتف، العنوان، المنتجات، الملاحظات)
- عرض قائمة المنتجات في كل طلب
- حساب الإجمالي تلقائياً
- تصفية الطلبات حسب الحالة

## البيانات المشتركة مع التطبيق

البرنامج متصل ب **نفس Firebase Database** مع تطبيق العميل:
- **Project ID**: market-8c0f1
- **Database**: Firestore
- **Collections**:
  - `categories` - الأقسام
  - `products` - المنتجات
  - `orders` - الطلبات
  - `users` - بيانات العملاء (في تطبيق العميل)

## البنية

```
alamair_admin_panel/
├── lib/
│   ├── main.dart                    # نقطة الدخول الرئيسية
│   ├── firebase_options.dart        # إعدادات Firebase
│   ├── models/
│   │   ├── category.dart           # نموذج القسم
│   │   ├── product.dart            # نموذج المنتج
│   │   └── order.dart              # نموذج الطلب
│   ├── services/
│   │   ├── category_service.dart   # خدمة الأقسام
│   │   ├── product_service.dart    # خدمة المنتجات
│   │   └── order_service.dart      # خدمة الطلبات
│   └── screens/
│       ├── home_screen.dart        # الشاشة الرئيسية
│       ├── categories_screen.dart  # شاشة إدارة الأقسام
│       ├── products_screen.dart    # شاشة إدارة المنتجات
│       └── orders_screen.dart      # شاشة إدارة الطلبات
└── android/
    └── app/
        └── google-services.json    # إعدادات Firebase للـ Android
```

## إعدادات Firebase المطلوبة

### 1. Firestore Database Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Admin panel access - بدون تسجيل دخول (للأدمن فقط)
    match /categories/{document=**} {
      allow read, write: if true;
    }
    
    match /products/{document=**} {
      allow read, write: if true;
    }
    
    match /orders/{document=**} {
      allow read, write: if true;
    }
    
    // Customer access - مع تسجيل دخول
    match /users/{uid} {
      allow read, write: if request.auth.uid == uid;
    }
    
    match /users/{uid}/favorites/{document=**} {
      allow read, write: if request.auth.uid == uid;
    }
  }
}
```

### 2. Collections Structure

**Categories Collection**
```json
{
  "name": "اسم القسم",
  "description": "وصف القسم",
  "createdAt": "timestamp"
}
```

**Products Collection**
```json
{
  "name": "اسم المنتج",
  "categoryId": "معرف القسم",
  "price": 50.0,
  "oldPrice": 100.0,
  "image": "رابط الصورة",
  "description": "وصف المنتج",
  "isAvailable": true,
  "isFeatured": false,
  "createdAt": "timestamp"
}
```

**Orders Collection**
```json
{
  "userId": "معرف العميل",
  "customerName": "اسم العميل",
  "phone": "رقم الهاتف",
  "address": "العنوان",
  "notes": "ملاحظات",
  "items": [
    {
      "productId": "معرف المنتج",
      "productName": "اسم المنتج",
      "price": 50.0,
      "quantity": 2
    }
  ],
  "totalPrice": 100.0,
  "status": "pending", // pending, preparing, shipped, delivered, cancelled
  "createdAt": "timestamp"
}
```

## كيفية الاستخدام

### التشغيل
```bash
cd alamair_admin_panel
flutter run
```

### الإنشاء للإنتاج
```bash
flutter build apk --release    # لـ Android
flutter build ios --release    # لـ iOS
flutter build web --release    # لـ Web
```

## الألوان والتصميم

- **اللون الأساسي**: #F57C00 (برتقالي)
- **الخلفية الداكنة**: #0a0a0a
- **بطاقات**: #1a1a1a
- **حقول الإدخال**: #2a2a2a

نفس التصميم الداكن مع الأكسنت البرتقالي من تطبيق العميل.

## ملاحظات مهمة

⚠️ **الأمان**: برنامج الأدمن هذا بدون تسجيل دخول لأنه للاستخدام الداخلي فقط في الجهاز.

⚠️ **الاتصال بـ Firebase**: تأكد من أن جهاز الأدمن متصل بالإنترنت لعرض البيانات المحدثة.

⚠️ **الصور**: يمكن إضافة روابط الصور من أي مصدر (Firebase Storage أو أي خدمة أخرى).

## الدعم الفني

- **Firebase Console**: https://console.firebase.google.com/
- **Flutter Documentation**: https://flutter.dev/docs
- **Firestore Documentation**: https://firebase.google.com/docs/firestore
