# StickerSense 🏷️

![Build Status](https://img.shields.io/badge/build-passing-brightgreen)
![License](https://img.shields.io/badge/license-MIT-blue)
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B)

**StickerSense** is a local-first, smart sticker organizer for mobile devices. It leverages on-device Machine Learning (ML) to automatically tag and index your sticker collection, making it instantly searchable without compromising your privacy.

---

## ✨ Features

- **Dual AI Modes** 🤖:
  - **Cloud API** (default): Uses Gemma 3 27B via Google AI API for maximum quality (30 RPM limit)
  - **On-Device**: Downloads Gemma 3 Nano E4B (~4.4GB) for unlimited, offline AI tagging
- **Hybrid AI Indexing**: Combines AI analysis with **on-device OCR** for text extraction from memes.
- **WhatsApp Import** 📥 (Android): Folder picker to import your existing WhatsApp sticker collection with automatic AI tagging.
- **Smart Fallback**: Automatically reverts to local ML Kit (Labeling, Face Detection, Translation) if AI fails or is offline.
- **Full-Text Search** 🔍: Instant search across all indexed stickers using SQLite FTS5.
- **Custom Keyboard** (Coming Soon): Access your stickers directly from any chatting app via a custom system keyboard.
- **Modern UI**: Clean, responsive layout built with Flutter and Riverpod.nsures 100% offline functionality.
- **Fast Search**: Built on SQLite (Drift) with FTS5 for lightning-fast full-text search capabilities.
- **Custom Keyboard** (Coming Soon): Access your stickers directly from any chatting app via a custom system keyboard.
- **Modern UI**: Clean, responsive layout built with Flutter and Riverpod.

## 🔑 Setup (Gemma AI)

1.  Get your API Key from [Google AI Studio](https://aistudio.google.com/).
2.  Create a `.env` file in the root directory.
3.  Add your key: `GEMINI_API_KEY=your_api_key_here`.

> **Note**: The free tier has usage limits. The app automatically handles rate limiting when "Più preciso" mode is enabled. For current limits, see [Google AI API Pricing](https://ai.google.dev/pricing).


## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev)
- **State Management**: [Riverpod](https://riverpod.dev)
- **Database**: [Drift](https://drift.simonbinder.eu) (SQLite)
- **ML & AI**: 
  - [Google Gemma 3 27B](https://ai.google.dev) (Cloud-based semantic analysis)
  - [Google ML Kit](https://developers.google.com/ml-kit) (On-device: Image Labeling, OCR, Face Detection, Translation)
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
