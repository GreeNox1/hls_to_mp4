# HLS <-> MP4 Converter (Dart)

[![Dart SDK](https://img.shields.io/badge/Dart-3.12%2B-blue.svg)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A high-performance, bidirectional CLI tool and Dart library to seamlessly convert offline **HLS playlists (`.m3u8` + `.ts`)** to **MP4** videos and vice versa, using FFmpeg stream copy (`-c copy`) without quality loss or unnecessary re-encoding.

[English](#-english) | [O'zbekcha](#-ozbekcha)

---

## 🇺🇸 English

### ✨ Features
- 🔄 **Bidirectional Conversion**: Convert `HLS (.m3u8)` -> `MP4` AND `MP4` -> `HLS (.m3u8 + .ts)`.
- ⚡ **Zero Quality Loss**: Uses stream copying (`-c copy`) to remux media without re-encoding.
- 🧠 **Smart Auto-detection**: Automatically detects conversion direction based on input path type.
- 🚀 **Low Memory Footprint**: Streams process output live (`Process.start`) instead of buffering in memory.
- 🏗️ **Clean Architecture & SOLID**: Fully decoupled code structure with custom exceptions, validators, command builders, and dependency injection.

### 📋 Prerequisites
- **Dart SDK** (v3.12.0 or higher)
- **FFmpeg** (Included in `tools/ffmpeg.exe` for Windows, or installed on system `PATH` for Linux/macOS).

### 🚀 Usage (CLI)

#### 1. Convert HLS Playlist to MP4
Pass the folder containing `index.m3u8` or `index_rel.m3u8` and the target MP4 file path:
```bash
dart run bin/main.dart "D:\Videos\Episode01" "D:\Videos\Episode01.mp4"
```

#### 2. Convert MP4 Video to HLS Playlist & Segments
Pass the source `.mp4` file and the output destination folder:
```bash
dart run bin/main.dart "D:\Videos\Episode01.mp4" "D:\Videos\Episode01_hls"
```

### 💻 Using as a Dart Package

```dart
import 'package:hls_to_mp4/hls_to_mp4.dart';

Future<void> main() async {
  // 1. HLS -> MP4
  final hlsConverter = HlsConverter();
  final result1 = await hlsConverter.convert(
    inputFolder: 'D:\\Videos\\Episode01',
    outputFile: 'D:\\Videos\\Episode01.mp4',
  );
  print('HLS -> MP4 Done in ${result1.duration.inSeconds}s');

  // 2. MP4 -> HLS
  final mp4Converter = Mp4ToHlsConverter();
  final result2 = await mp4Converter.convert(
    inputFile: 'D:\\Videos\\Episode01.mp4',
    outputDirectoryOrPlaylist: 'D:\\Videos\\Episode01_hls',
  );
  print('MP4 -> HLS Done in ${result2.duration.inSeconds}s');
}
```

### 🧪 Testing & Analysis

```bash
# Run static analysis
dart analyze

# Run unit tests
dart test
```

---

## 🇺🇿 O'zbekcha

### ✨ Imkoniyatlari
- 🔄 **Ikki tomonlama konvertatsiya**: `HLS (.m3u8)` -> `MP4` va `MP4` -> `HLS (.m3u8 + .ts)`.
- ⚡ **Nol yo'qotish (Lossless)**: Video va audio sifatini yo'qotmasdan stream copy (`-c copy`) usulida tezkor o'tkazish.
- 🧠 **Aqlli avtomatik aniqlash**: Kiritilgan manzil turiga qarab konvertatsiya yo'nalishini o'zi aniqlaydi.
- 🚀 **Kam RAM sarfi**: FFmpeg konsol ma'lumotlarini operativ xotirani to'ldirmasdan real vaqt rejimida o'qiydi.
- 🏗️ **Toza arxitektura (SOLID)**: Maxsus istisnolar (Exceptions), tekshiruvchilar (Validators) va Dependency Injection bilan modulli tuzilgan.

### 📋 Talablar
- **Dart SDK** (v3.12.0 yoki undan yuqori)
- **FFmpeg** (Windows uchun `tools/ffmpeg.exe` fayli mavjud, Linux/macOS uchun tizim `PATH`ida `ffmpeg` o'rnatilgan bo'lishi kerak).

### 🚀 CLI orqali foydalanish

#### 1. HLS papkasini MP4 fayliga o'tkazish
`index.m3u8` yoki `index_rel.m3u8` joylashgan papka va chiqish `.mp4` fayli manzilini kiriting:
```bash
dart run bin/main.dart "D:\Videos\Episode01" "D:\Videos\Episode01.mp4"
```

#### 2. MP4 faylini HLS formatiga (m3u8 + ts) o'tkazish
Manba `.mp4` fayli va chiqish HLS papkasi manzilini kiriting:
```bash
dart run bin/main.dart "D:\Videos\Episode01.mp4" "D:\Videos\Episode01_hls"
```

### 💻 Dart loyihasida kutubxona sifatida foydalanish

```dart
import 'package:hls_to_mp4/hls_to_mp4.dart';

Future<void> main() async {
  // 1. HLS -> MP4
  final hlsConverter = HlsConverter();
  final result1 = await hlsConverter.convert(
    inputFolder: 'D:\\Videos\\Episode01',
    outputFile: 'D:\\Videos\\Episode01.mp4',
  );
  print('HLS -> MP4 bajarildi: ${result1.duration.inSeconds}s');

  // 2. MP4 -> HLS
  final mp4Converter = Mp4ToHlsConverter();
  final result2 = await mp4Converter.convert(
    inputFile: 'D:\\Videos\\Episode01.mp4',
    outputDirectoryOrPlaylist: 'D:\\Videos\\Episode01_hls',
  );
  print('MP4 -> HLS bajarildi: ${result2.duration.inSeconds}s');
}
```

### 🧪 Test va tahlil

```bash
# Statik kod tahlili
dart analyze

# Unit testlarni ishga tushirish
dart test
```
