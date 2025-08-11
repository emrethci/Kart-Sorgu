# Kart Kime Ait App

Modern ve kullanıcı dostu bir web uygulaması. Input alanından değer alıp backend'de işleyerek sonucu gösterir.

## Özellikler

- 🎨 Modern ve responsive tasarım
- ⚡ Hızlı ve kullanıcı dostu arayüz
- 🔄 Real-time işlem
- 📱 Mobil uyumlu
- 🎯 Tailwind CSS ile güzel görünüm

## Teknolojiler

- **Frontend:** HTML5, JavaScript (ES6+), Tailwind CSS
- **Backend:** Node.js, Express.js
- **Authentication:** Session-based authentication
- **Icons:** Font Awesome

## Kurulum

1. Projeyi klonlayın:
```bash
git clone <repository-url>
cd kartkimeaitapp
```

2. Bağımlılıkları yükleyin:
```bash
npm install
```

3. Kullanıcı bilgilerini ayarlayın:
```bash
# Örnek config dosyasını kopyalayın
cp config/users.example.js config/users.js

# config/users.js dosyasını düzenleyerek kendi kullanıcı bilgilerinizi ekleyin
```

4. Uygulamayı başlatın:
```bash
# Geliştirme modu (nodemon ile)
npm run dev

# Production modu
npm start
```

5. Tarayıcınızda açın:
```
http://localhost:3010
```

## Kullanım

1. **Giriş Yapın**: `config/users.js` dosyasında tanımladığınız kullanıcı bilgileri ile giriş yapın
2. **Ana Uygulamaya Erişim**: Başarılı girişten sonra ana uygulama açılır
3. **Kart Bilgisi Girin**: Input alanına kart numarasını girin
4. **İşle**: "Ara" butonuna tıklayın veya Enter tuşuna basın
5. **Sonucu Görün**: Sonuç alt kısımda görünecektir

## Güvenlik

- Kullanıcı bilgileri `config/users.js` dosyasında saklanır
- Bu dosya `.gitignore`'da olduğu için GitHub'a gönderilmez
- Gerçek uygulamada şifrelenmiş veritabanı kullanılmalıdır

## API Endpoints

- `POST /api/login` - Kullanıcı girişi
  - Body: `{ "email": "string", "password": "string" }` (email alanı kullanıcı adı olarak kullanılır)
  - Response: `{ "success": true, "sessionToken": "string", "user": { "email": "string" } }`

- `POST /api/logout` - Kullanıcı çıkışı
  - Body: `{ "sessionToken": "string" }`
  - Response: `{ "success": true, "message": "string" }`

- `POST /api/process` - Input değerini işler (Authentication gerekli)
  - Headers: `X-Session-Token: string`
  - Body: `{ "inputValue": "string" }`
  - Response: `{ "success": true, "result": "string", "originalInput": "string" }`

## Proje Yapısı

```
kartkimeaitapp/
├── public/
│   ├── index.html      # Ana HTML sayfası
│   └── script.js       # Frontend JavaScript
├── server.js           # Backend sunucu
├── package.json        # Proje bağımlılıkları
└── README.md          # Bu dosya
```

## Geliştirme

Uygulamayı geliştirmek için:

1. `npm run dev` komutu ile nodemon ile çalıştırın
2. Kod değişikliklerini yapın
3. Otomatik olarak yeniden başlatılacaktır

## Lisans

MIT License
