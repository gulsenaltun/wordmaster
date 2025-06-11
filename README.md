# Wordle Mobile

İngilizce kelime öğrenme uygulaması. Kelimeleri öğrenmek ve test etmek için interaktif bir arayüz sunar.

## Proje Yapısı

```
lib/
├── main.dart                 # Uygulama giriş noktası
├── firebase_options.dart     # Firebase yapılandırması
├── screens/                  # Ana ekranlar
│   └── import_words_screen.dart
├── features/                 # Özellik modülleri
│   ├── auth/                # Kimlik doğrulama
│   ├── settings/            # Ayarlar
│   ├── wordle/              # Kelime oyunu
│   └── word_management/     # Kelime yönetimi
└── core/                    # Temel bileşenler
```

## Özellikler

- Kelime öğrenme ve test etme
- Firebase entegrasyonu
- Kullanıcı kimlik doğrulama
- Kelime yönetimi
- Özelleştirilebilir ayarlar

## Kurulum

Bu projede `lib/firebase_options.dart` dosyası sadece örnek amaçlı bırakılmıştır.
Projeyi çalıştırmadan önce kendi `firebase_options.dart` dosyanızı oluşturmanız gerekir.

1. Flutter'ı yükleyin:
```bash
# Flutter SDK'yı indirin ve kurun
# https://flutter.dev/docs/get-started/install
```

2. Bağımlılıkları yükleyin:
```bash
flutter pub get
```

3. Firebase yapılandırması:
- Firebase Console'dan yeni bir proje oluşturun
- Android ve iOS uygulamalarını ekleyin
- `google-services.json` ve `GoogleService-Info.plist` dosyalarını ilgili klasörlere ekleyin

4. Uygulamayı çalıştırın:
```bash
flutter run
```

## Geliştirme

### Kelime Yükleme
Kelimeleri Firebase'e yüklemek için:
1. `assets/words.json` dosyasını hazırlayın
2. Uygulamayı çalıştırın
3. Kelime yükleme ekranını kullanın

### Test Etme
```bash
flutter test
```

## Katkıda Bulunma

1. Bu depoyu fork edin
2. Yeni bir branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add some amazing feature'`)
4. Branch'inizi push edin (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

## Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için `LICENSE` dosyasına bakın.
