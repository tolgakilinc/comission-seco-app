## seco_app
Komisyon bazlı firmalar için stok, müşteri ve ödeme takibi sağlayan bir Flutter projesi.

**Proje Özeti**
Bu uygulama, komisyon firmalarının ürün, stok, müşteri ve ödeme takibini kolayca yapabilmesi için geliştirilmiştir. Gerçek zamanlı veri yönetimi için Firebase kullanarak gelir, gider ve bakiye takibini basit bir arayüzle sunar. Uygulama Flutter ile geliştirilmiştir ve komisyon bazlı bir işletmenin ihtiyaç duyabileceği çeşitli sayfaları içerir.

![login](https://github.com/user-attachments/assets/107e19b1-e672-476f-b5f2-6b3343b506ec)

**Ana sayfa:** Gelir, gider ve bakiye genel görünümü.

**Özellikler**
Gelir ve Gider Takibi: Firmanın gelir ve giderlerini izleyerek güncel bakiyeyi görüntüleme.


![menu](https://github.com/user-attachments/assets/e03c9039-b0ef-4b8e-9323-198944a8eefa)


**Ürün Yönetimi:** Firma tarafından satılan ürünlerin (meyve, sebze vb.) listesi ve stok bilgilerini yönetme.

![product](https://github.com/user-attachments/assets/4848e4ca-0be6-4356-b3f0-357b3a1dfbc3)




**Stok Takibi:** Ürün miktarlarını güncelleme ve stok seviyelerini gerçek zamanlı olarak izleme.

![stock](https://github.com/user-attachments/assets/c04d5558-afb7-4c92-b3a5-6bb9ee973a72)

**Müşteri Yönetimi:** Firma müşterilerini kaydetme, düzenleme ve listeleme.


![customer](https://github.com/user-attachments/assets/da5453fb-c4ef-46a7-8cd1-41058c3ba485)


**Ödeme Takibi:** Müşterilerden alınan ödemeler ve yaklaşan ödeme tarihlerini görüntüleme.


**İşlem Geçmişi:** Yapılan tüm işlemleri detaylı bir şekilde görüntüleme ve arşivleme.


![transaction](https://github.com/user-attachments/assets/7a581afe-3b45-479e-b74a-30a2621a28d9)

**Firebase Entegrasyonu:** Gerçek zamanlı veri senkronizasyonu ve güvenli depolama için Firebase kullanımı.

**Kurulum**
Bu proje, Flutter uygulamaları için başlangıç noktasıdır.

Projeyi yerel ortamınıza kurmak için aşağıdaki adımları takip edin:

**Gereksinimler**

• Flutter SDK
• Firebase hesabı ve proje ayarları
• Kurulum Adımları
• Depoyu Klonlayın


```git clone https://github.com/tolgakilinc/comission-seco-app.git```
```cd comission-seco-app```
Bağımlılıkları Yükleyin Gerekli Flutter bağımlılıklarını yüklemek için aşağıdaki komutu çalıştırın:


```flutter pub get```
Firebase Yapılandırması Firebase projenizi kurun ve aşağıdaki dosyaları projeye ekleyin:

**google-services.json** dosyasını Android için android/app dizinine ekleyin.
**GoogleService-Info.plist** dosyasını iOS için ios/Runner dizinine ekleyin.
Uygulamayı Çalıştırın Uygulamayı başlatmak için şu komutu çalıştırın:

```flutter run```

**Kullanılan Teknolojiler**
• Flutter: Uygulamanın arayüz ve temel işleyişi için.
• Firebase: Gerçek zamanlı veritabanı ve kullanıcı yönetimi için.
• Dart: Flutter için kullanılan programlama dili.

**Lisans**
Bu proje MIT Lisansı ile lisanslanmıştır. Detaylar için LICENSE dosyasını inceleyin.
