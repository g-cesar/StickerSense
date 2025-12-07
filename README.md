# StickerSense 🏷️

![Build Status](https://img.shields.io/badge/build-passing-brightgreen)
![License](https://img.shields.io/badge/license-MIT-blue)
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B)

**StickerSense** is a local-first, smart sticker organizer for mobile devices. It leverages on-device Machine Learning (ML) to automatically tag and index your sticker collection, making it instantly searchable without compromising your privacy.

---

## ✨ Features

- **Smart Indexing**: Uses Google ML Kit to analyze images and extract relevant tags (objects, text).
- **Local-First**: All data and images are stored locally on your device. No cloud uploads, ensuring 100% privacy.
- **Fast Search**: Built on SQLite (Drift) with FTS5 for lightning-fast full-text search capabilities.
- **Custom Keyboard** (Coming Soon): Access your stickers directly from any chatting app via a custom system keyboard.
- **Modern UI**: Clean, responsive layout built with Flutter and Riverpod.

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev)
- **State Management**: [Riverpod](https://riverpod.dev)
- **Database**: [Drift](https://drift.simonbinder.eu) (SQLite)
- **ML & AI**: [Google ML Kit](https://developers.google.com/ml-kit) (Image Labeling, Text Recognition)
- **Architecture**: Clean Architecture + Feature-First structure.

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0 or later)
- Dart SDK
- Android Studio / Xcode

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/stickersense.git
   cd stickersense
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run Code Generation**
   This project uses `build_runner` for Riverpod and Drift code generation.
   ```bash
   dart run build_runner build -d
   ```

4. **Run the App**
   ```bash
   flutter run
   ```

## 📂 Project Structure

```
lib/
├── core/                   # Core functionality (Database, Services)
│   ├── database/           # Drift database schema and connection
│   └── services/           # ML services (Image Indexer)
├── features/               # Feature-based organization
│   └── sticker/            # Sticker management feature
│       ├── data/           # Repositories and Data Sources
│       └── presentation/   # UI widgets and Controllers
└── main.dart               # Application entry point
```

## 🤝 Contributing

Contributions are welcome! Please check the [CONTRIBUTING.md](CONTRIBUTING.md) file for guidelines on how to proceed.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
