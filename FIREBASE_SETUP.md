# Firebase Firestore Rules وإعدادات الأمان

## القاعدة الحالية للـ Database

البرنامج يستخدم نفس Firebase Project لكل من:
- تطبيق العميل (alamir_supermarket)
- برنامج الأدمن (alamair_admin_panel)

### Project Details
```
Project ID: market-8c0f1
Storage Bucket: market-8c0f1.firebasestorage.app
```

## Firestore Security Rules - القواعد النهائية

أضف هذه القاعدة في Firebase Console (https://console.firebase.google.com/project/market-8c0f1/firestore/rules):

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // === HELPER FUNCTIONS ===
    function isAuthed() {
      return request.auth != null;
    }

    function userDoc(uid) {
      return get(/databases/$(database)/documents/users/$(uid));
    }

    function isOwner() {
      return isAuthed() && userDoc(request.auth.uid).data.role == 'owner';
    }

    function isAdmin() {
      return isAuthed() && userDoc(request.auth.uid).data.role == 'admin';
    }

    function isActiveUser() {
      return isAuthed() && userDoc(request.auth.uid).data.isActive == true;
    }

    // === COLLECTIONS ===

    // Users Collection - الحسابات
    match /users/{userId} {
      allow read: if isAuthed() && (request.auth.uid == userId || isOwner() || isAdmin());
      
      allow create: if isAuthed() && (
        (request.auth.uid == userId && request.resource.data.role == 'customer') ||
        isOwner()
      );
      
      allow update: if isAuthed() && (
        isOwner() ||
        (request.auth.uid == userId &&
          request.resource.data.role == resource.data.role &&
          request.resource.data.isActive == resource.data.isActive
        )
      );
      
      allow delete: if isOwner();
    }

    // Favorites Subcollection - المفضلة
    match /users/{userId}/favorites/{productId} {
      allow read: if request.auth.uid == userId;
      allow create, delete: if request.auth.uid == userId;
    }

    // Categories Collection - الأقسام
    // ✅ تطبيق العميل: يقرأ الجميع، الأدمن/المالك فقط يكتبون
    // ✅ لوحة الأدمن: تقرأ/تكتب بدون تحقق
    match /categories/{categoryId} {
      allow read: if true;
      allow write: if !isAuthed() || (isActiveUser() && (isAdmin() || isOwner()));
    }

    // Products Collection - المنتجات
    // ✅ تطبيق العميل: يقرأ الجميع، الأدمن/المالك يكتبون
    // ✅ لوحة الأدمن: تقرأ/تكتب بدون تحقق
    match /products/{productId} {
      allow read: if true;
      
      allow create, delete: if !isAuthed() || (isActiveUser() && (isAdmin() || isOwner()));
      
      allow update: if !isAuthed() || (isActiveUser() && (
        isAdmin() || 
        isOwner() ||
        // Allow updating quantity for orders (customer app)
        (isAuthed() && request.resource.data.diff(resource.data).affectedKeys().hasOnly(['quantity', 'isAvailable']))
      ));
    }

    // Products Reviews Subcollection - التقييمات
    match /products/{productId}/reviews/{reviewId} {
      allow read: if true;
      allow create: if isAuthed();
      allow delete: if isAuthed() && request.auth.uid == resource.data.userId;
    }

    // Orders Collection - الطلبات
    // ✅ تطبيق العميل: يقرأ/ينشئ الجميع، يلغي طلبه الخاص، الأدمن يحدث الحالة
    // ✅ لوحة الأدمن: تقرأ/تكتب/تحدث بدون تحقق
    match /orders/{orderId} {
      allow read: if true;
      allow create: if true;
      allow update: if !isAuthed() || 
                      (isActiveUser() && (isAdmin() || isOwner())) ||
                      // Allow user to cancel their own pending order
                      (isAuthed() && 
                       request.auth.uid == resource.data.userId && 
                       resource.data.status == 'pending' && 
                       request.resource.data.status == 'cancelled');
      allow delete: if !isAuthed() || isOwner();
    }
  }
}
```

## خطوات التطبيق

1. **افتح Firebase Console**
   - https://console.firebase.google.com/project/market-8c0f1/firestore/rules

2. **انسخ الكود الكامل** من أعلى (كل الـ Rules)

3. **الصق في Firebase Console** في تبويب Rules

4. **اضغط Publish** (الزر الأزرق)

---

## القاعدة البسيطة للتطوير

إذا حصلت على أي مشكلة، استخدم هذه القاعدة البسيطة (للتطوير فقط):

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

⚠️ **هذه القاعدة غير آمنة - استخدمها للتطوير فقط!**

---

## Collections والحقول المطلوبة

### 1. categories Collection
```json
{
  "id": "auto-generated",
  "name": "string",           // مثال: "خضروات"
  "description": "string",    // اختياري
  "createdAt": "timestamp"
}
```

### 2. products Collection
```json
{
  "id": "auto-generated",
  "name": "string",           // مثال: "طماطم"
  "categoryId": "string",     // معرف القسم
  "price": "number",          // مثال: 15.50
  "oldPrice": "number",       // اختياري - لعرض التخفيضات
  "image": "string",          // رابط الصورة
  "description": "string",    // وصف المنتج
  "isAvailable": "boolean",   // هل المنتج متوفر
  "isFeatured": "boolean",    // هل المنتج مميز (عروض اليوم)
  "createdAt": "timestamp"
}
```

### 3. products/{productId}/reviews Subcollection
```json
{
  "userId": "string",
  "rating": "number",         // من 1-5
  "createdAt": "timestamp"
}
```

### 4. orders Collection
```json
{
  "id": "auto-generated",
  "userId": "string",
  "customerName": "string",
  "phone": "string",
  "address": "string",
  "notes": "string",          // اختياري
  "items": [
    {
      "productId": "string",
      "productName": "string",
      "price": "number",
      "quantity": "number"
    }
  ],
  "totalPrice": "number",
  "status": "string",         // pending, preparing, shipped, delivered, cancelled
  "createdAt": "timestamp"
}
```

### 5. users Collection
```json
{
  "uid": "firebase-auth-id",
  "name": "string",
  "email": "string",
  "phone": "string",
  "role": "string",           // customer, admin, owner
  "createdAt": "timestamp"
}
```

### 6. users/{uid}/favorites Subcollection
```json
{
  "productId": "string",
  "addedAt": "timestamp"
}
```

## خطوات التكوين في Firebase Console

1. **اذهب إلى Firestore Database**
   - https://console.firebase.google.com/project/market-8c0f1/firestore

2. **أنشئ Collections (إن لم تكن موجودة)**
   - categories
   - products
   - orders
   - users

3. **طبّق Security Rules**
   - اذهب إلى Rules tab
   - انسخ القاعدة من أعلى

4. **تفعيل Authentication**
   - Email/Password
   - Google Sign-in (اختياري)

## ملاحظات مهمة

### 🔐 الأمان
- في التطوير: استخدم القواعد المفتوحة (allow if true)
- في الإنتاج: استخدم القواعد الصارمة مع تحقق من التفويض

### 📱 Mobile vs Web
- تطبيق العميل (alamir_supermarket): Android/iOS
- برنامج الأدمن (alamair_admin_panel): Android/iOS/Web

### 🌐 Hosting
يمكنك استخدام Firebase Hosting للـ Web version:
```bash
flutter build web
firebase deploy
```

### 📊 المراقبة
- استخدم Firebase Console لرؤية:
  - عدد الـ Read/Write operations
  - التخزين المستخدم
  - الأخطاء والمشاكل

## خطوات إضافية مقترحة

### 1. إضافة Indexes (للأداء)
```
Products by category and price:
- categoryId (Ascending)
- price (Ascending)

Orders by status and date:
- status (Ascending)
- createdAt (Descending)
```

### 2. تفعيل Backups
- في Firebase Console > Settings > Backups
- فعّل النسخ الاحتياطية التلقائية

### 3. إضافة Storage للصور
```
storage-rules.txt
match /products/{productId}/{allPaths=**} {
  allow read: if true;
  allow write: if request.auth != null;
}
```

## التوثيق الرسمية
- Firestore: https://firebase.google.com/docs/firestore
- Security Rules: https://firebase.google.com/docs/firestore/security/start
- Firebase Console: https://console.firebase.google.com/
