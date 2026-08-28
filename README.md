# PRD FINAL v2.0 — LYRIC & SUBTITLE MAKER

## 1. Ringkasan Produk
Aplikasi berbasis Flutter untuk membuat dan mengedit:
- Lirik dengan output `.lrc`
- Subtitle dengan output `.srt`

Fokus utama:
- input teks manual
- import file teks
- penandaan waktu secara real-time
- fine-tuning timestamp
- preview playback audio/video
- export ke clipboard/file
- autosave lokal

Target platform:
- Windows Desktop
- Android

Tema:
- Light Mode
- Clean UI
- Tidak perlu dark mode pada versi ini

## 2. Platform & Arsitektur

### Framework
- Flutter single codebase

### Target
- Windows
- Android

### Struktur kode
- Gunakan struktur modular, bukan satu file besar.
- Contoh struktur:
  - lib/main.dart
  - lib/app.dart
  - lib/models/
  - lib/services/
  - lib/providers/
  - lib/screens/
  - lib/widgets/

### Prinsip implementasi
- Kode harus bisa dijalankan.
- Tidak boleh ada TODO.
- Tidak boleh ada placeholder.
- Tidak boleh ada fitur di luar PRD ini.
- Jika ada bagian ambigu, AI harus bertanya sebelum melanjutkan.

## 3. Mode Aplikasi

Aplikasi memiliki 2 mode utama:

### 3.1. Mode Lirik
- Output utama: `.lrc`
- Setiap baris memiliki:
  - `text`
  - `startTime`
- Tidak menggunakan `endTime`

### 3.2. Mode Subtitle
- Output utama: `.srt`
- Setiap baris memiliki:
  - `text`
  - `startTime`
  - `endTime`

## 4. Dependencies Utama

Gunakan stack berikut:

- `media_kit` untuk engine media audio/video
- `media_kit_video` untuk rendering video
- `media_kit_libs_android_video` untuk dukungan Android video
- `media_kit_libs_windows_video` untuk dukungan Windows video
- `file_picker` untuk memilih file
- `file_saver` untuk menyimpan file export
- `path_provider` untuk penyimpanan lokal
- `permission_handler` untuk permission Android
- `shared_preferences` untuk setting sederhana dan persiapan fitur future
- `provider` untuk state management
- `uuid` untuk ID unik
- `path` untuk utilitas path/filename
- `collection` untuk helper list

Catatan:
- `flutter/services.dart` adalah bagian dari Flutter SDK, bukan package pub.
- Jangan memakai `just_audio` sebagai player utama karena PRD ini membutuhkan video dan target Windows.

## 5. Media Player

### 5.1. Engine
- Gunakan `media_kit` sebagai player utama.
- Harus mendukung:
  - audio
  - video

### 5.2. Mode penuh
- Audio diputar.
- Preview video ditampilkan jika file berupa video dan mode ringan nonaktif.

### 5.3. Mode ringan
- Mode ringan adalah opsi untuk perangkat lemah.
- Saat mode ringan aktif:
  - audio tetap diputar
  - preview video tidak ditampilkan
  - editor, timing, timeline, dan autosave tetap berfungsi
- Jika file berupa video:
  - aplikasi tetap mencoba memutar audionya
  - preview video disembunyikan

### 5.4. Perilaku media
- Jika media belum dimuat:
  - transport playback disabled
  - timestamp recording disabled
  - editing teks tetap boleh
- Jika media gagal dibuka:
  - tampilkan pesan error
  - aplikasi tidak boleh crash
- Jika autosave di-restore tetapi file media tidak ditemukan:
  - proyek tetap terbuka
  - playback disabled
  - user diminta memilih ulang file media

## 6. Alur Aplikasi

### 6.1. Home Screen
Home harus memiliki:

1. Lanjutkan Proyek
   - hanya muncul jika ada autosave
2. Buat Lirik
3. Buat Subtitle
4. Buka File
   - mendukung `.txt`, `.lrc`, `.srt`

### 6.2. Buat Lirik
- User boleh masuk editor tanpa media.
- Tanpa media:
  - bisa mengetik manual
  - bisa edit baris
  - tidak bisa menandai waktu
- Untuk timing:
  - user harus memasukkan file audio
  - timing dilakukan sambil audio diputar

### 6.3. Buat Subtitle
- User boleh masuk editor tanpa media.
- Tanpa media:
  - bisa mengetik manual
  - bisa import `.srt`
  - bisa edit teks
  - tidak bisa menandai waktu
- Untuk timing:
  - user harus memasukkan audio atau video
  - subtitle wajib memiliki media untuk perekaman waktu

### 6.4. Buka File
Perilaku:
- `.lrc` dibuka sebagai mode Lirik
- `.srt` dibuka sebagai mode Subtitle
- `.txt` meminta user memilih mode:
  - Lirik
  - atau Subtitle

## 7. Judul Proyek

### Sumber judul default
Judul default diambil dari salah satu berikut secara prioritas:
1. metadata/tag media jika tersedia
2. nama file media
3. nama file yang di-import
4. judul sementara seperti "Lirik Baru" atau "Subtitle Baru"

### Ketentuan
- Judul bisa diedit langsung di top bar editor.
- Judul dipakai sebagai default filename saat export.
- Karakter ilegal filename harus dibersihkan saat save.

Contoh:
- Judul: `Lagu Demo`
- Export lyric: `Lagu Demo.lrc`
- Export subtitle: `Lagu Demo.srt`

## 8. Model Data

### 8.1. TimingItem
Setiap baris memiliki:
- `id`: string unik
- `text`: string
- `startTime`: Duration nullable
- `endTime`: Duration nullable, khusus subtitle

### 8.2. Project
Project memiliki:
- `id`: string unik
- `title`: string
- `mode`: lyric/subtitle
- `mediaPath`: string nullable
- `lines`: list of TimingItem
- `lastPosition`: Duration
- `updatedAt`: DateTime

### 8.3. Presisi waktu
- Simpan waktu internal dalam `Duration` berbasis microsecond jika memungkinkan.
- Export:
  - LRC menggunakan format centisecond `[mm:ss.xx]`
  - SRT menggunakan format millisecond `hh:mm:ss,ms`

## 9. Penandaan Waktu

## 9.1. Mode Lirik

### Input
- Tombol besar UI: tap
- Keyboard default: `Z` ditekan sekali

### Perilaku
Saat timestamp lirik dipicu:
- simpan `startTime` pada posisi playback saat itu
- jika audio sedang pause, gunakan posisi pause tersebut
- setelah berhasil, pindah ke baris berikutnya

### Target baris
Urutan penentuan target:
1. Jika ada baris terpilih, gunakan baris terpilih.
2. Jika tidak ada, cari baris pertama yang belum memiliki timestamp.
3. Jika tidak ada, buat baris kosong baru.

### Timing-first
- User boleh membuat timestamp dulu, teks belakangan.
- Aplikasi boleh membuat baris kosong bertimestamp.

## 9.2. Mode Subtitle

### Input
- Tombol besar UI: hold
- Keyboard default: tahan `Z`

### Perilaku
- Saat tombol/key down: simpan `startTime`
- Saat tombol/key up: simpan `endTime`
- Tidak ada minimum duration yang dipaksakan.
- Duration sangat pendek tetap disimpan.
- `endTime` tidak boleh lebih kecil dari `startTime`.
- Jika release menghasilkan end lebih kecil dari start, samakan end dengan start.

### Target baris
Sama seperti lyric:
1. Jika ada baris terpilih, gunakan baris terpilih.
2. Jika tidak ada, cari baris pertama yang belum memiliki start dan end lengkap.
3. Jika tidak ada, buat baris kosong baru.

### Timing-first
- User boleh membuat subtitle kosong bertimestamp dulu.
- Teks bisa diisi belakangan.

## 10. Konflik Timestamp / Teks

Jika user memberi timestamp baru pada baris yang sudah memiliki:
- teks tidak kosong
- timestamp yang sudah ada

maka tampilkan dialog konflik.

Jika baris:
- punya timestamp tetapi teks kosong: langsung timpa timestamp
- punya teks tetapi belum punya timestamp: langsung beri timestamp tanpa dialog

### Pilihan dialog konflik
1. Timpa timing
   - timestamp lama diganti timestamp baru
   - teks tetap di baris yang sama

2. Pindahkan teks ke baris baru
   - buat baris baru dengan timestamp baru
   - teks dipindahkan ke baris baru
   - baris lama dikosongkan teksnya
   - timestamp lama tetap dipertahankan pada baris lama sebagai slot kosong

3. Batal
   - tidak ada perubahan

Ketentuan:
- aturan konflik berlaku untuk lyric dan subtitle
- untuk subtitle, timestamp baru mencakup start dan end

## 11. Playback & Transport Controls

### Kontrol transport
Transport bar utama berisi:
- `-5s`
- Play/Pause
- `+5s`
- Undo
- Redo

Catatan:
- tombol fine-tuning `+100ms` / `-100ms` tidak berada di transport bar utama
- fine-tuning dilakukan lewat panel baris terpilih atau menu baris

## 12. UI Editor

## 12.1. Komponen utama editor
Editor harus memiliki:
- top bar
  - tombol kembali
  - judul editable
  - tombol pilih media
  - menu export
- preview area
- transport bar
- timeline
- tombol timestamp besar
- list editor baris

## 12.2. Tampilan vertikal / portrait
Susunan dari atas ke bawah:
1. top bar
2. preview
3. transport bar
4. timeline
5. tombol timestamp besar
6. list editor

## 12.3. Tampilan horizontal / landscape / Windows
Gunakan layout responsif:
- area kiri:
  - preview
  - timeline
- area kanan:
  - transport controls
  - tombol timestamp besar
  - panel selected line
  - list editor

Jika ruang tidak cukup, boleh susun secara proporsional, tetapi semua komponen utama tetap tersedia.

## 13. Timeline

## 13.1. Timeline Mode Lirik
Jenis:
- horizontal lyric strip

### Bentuk
- baris lirik yang sudah punya timestamp ditampilkan sebagai item/chip horizontal
- item aktif diberi highlight
- auto-scroll mengikuti playback

### Interaksi
- tap item:
  - select item
  - seek ke startTime item
- jika item belum punya timestamp:
  - hanya bisa dipilih/diedit
  - tidak bisa seek

### Batasan MVP
- lyric strip tidak dipakai sebagai scrubber presisi
- tidak perlu drag-to-seek kompleks pada tahap ini

## 13.2. Timeline Mode Subtitle
Jenis:
- block timeline

### Level MVP
Gunakan Level 2 + zoom sederhana.

### Bentuk
- setiap subtitle yang memiliki start/end digambar sebagai block horizontal
- posisi block berdasarkan `startTime`
- lebar block berdasarkan durasi `endTime - startTime`

### Interaksi
- tap block:
  - select block
  - seek ke start block
- drag block:
  - menggeser block horizontal
  - mengubah `startTime` dan `endTime` secara bersamaan
  - durasi tetap
- zoom sederhana:
  - tombol zoom in/out
  - atau pinch jika memungkinkan
  - horizontal scroll untuk durasi panjang

### Batasan MVP
- belum perlu drag edge untuk mengubah start/end secara terpisah
- belum perlu multi-track
- belum perlu snapping kompleks
- fine-tuning start/end tetap lewat panel field terpilih

### Jika baris belum punya timestamp
- tidak muncul sebagai block di timeline sampai timestamp dibuat

## 14. Selection, Active Line, dan Fine-Tuning

## 14.1. Active line
Active line adalah baris yang sedang muncul berdasarkan posisi playback.

Untuk lyric:
- aktif jika posisi sekarang >= startTime dan sebelum startTime baris berikutnya dalam urutan

Untuk subtitle:
- aktif jika posisi sekarang berada di antara startTime dan endTime

## 14.2. Selected line
Selected line adalah baris yang dipilih user untuk diedit.

Ketentuan:
- selected line belum tentu active line
- aksi fine-tuning bekerja pada selected line
- user harus memilih baris terlebih dahulu sebelum fine-tuning

## 14.3. Fine-tuning timestamp
Untuk mengubah timestamp manual:

### Mode Lirik
- hanya field `Start`

### Mode Subtitle
- field `Start` dan `End`
- user memilih field mana yang ingin diubah
- tombol `+100ms` / `-100ms` mengubah field yang dipilih

### Aturan
- nilai tidak boleh negatif
- `endTime` tidak boleh lebih kecil dari `startTime`
- perubahan fine-tuning harus undoable

## 15. Editing List

Fitur editing baris yang wajib ada:

### 15.1. Edit teks
- edit inline per baris

### 15.2. Add line
- menambah baris baru
- jika ada baris terpilih, baris baru disisipkan setelah baris terpilih
- jika tidak ada, tambahkan di akhir

### 15.3. Delete line
- hapus baris
- tersedia lewat menu baris atau tombol delete

### 15.4. Reorder
- reorder baris wajib ada
- reorder memakai drag handle khusus

### 15.5. Long press / menu baris
Long press baris membuka menu aksi, minimal:
- hapus baris
- -100ms start
- +100ms start
- untuk subtitle:
  - -100ms end
  - +100ms end

### 15.6. Pemisahan reorder dan menu
Untuk menghindari konflik:
- drag handle khusus dipakai untuk reorder
- long press pada baris dipakai untuk menu aksi

## 16. Undo / Redo

### Scope undo/redo
Undo/redo berlaku untuk:
- set timestamp lyric
- set start/end subtitle
- timpa timestamp
- move text ke baris baru
- fine-tuning +/-100ms
- drag block subtitle
- add line
- delete line
- reorder line

Undo/redo tidak berlaku untuk:
- perubahan teks per karakter saat mengetik

### Alasan
- text field dapat memakai undo native TextField
- undo global difokuskan pada timing dan struktur

### Shortcut
- `Ctrl + Z` = Undo
- `Ctrl + Y` = Redo
- alternatif: `Ctrl + Shift + Z` = Redo

## 17. Shortcut Keyboard

## 17.1. Keputusan
- Pada MVP, gunakan fixed shortcut.
- Custom shortcut ditunda ke fase berikutnya.

## 17.2. Shortcut default

| Tombol | Fungsi |
|---|---|
| `Space` | Play/Pause |
| `Arrow Left` | Mundur 5 detik |
| `Arrow Right` | Maju 5 detik |
| `Z` | Timestamp |
| `Ctrl + Z` | Undo |
| `Ctrl + Y` | Redo |
| `Ctrl + Shift + Z` | Redo alternatif |

## 17.3. Perilaku shortcut
- `Z` untuk lyric = trigger sekali
- `Z` untuk subtitle = hold down/up
- saat user sedang mengetik di TextField:
  - shortcut global harus diabaikan
- key repeat OS harus ditangani:
  - saat menahan `Z`, key repeat tidak boleh dianggap trigger baru
  - hanya keydown pertama dan keyup yang dipakai

## 18. Import File

## 18.1. Encoding
- default UTF-8
- toleransi BOM jika memungkinkan

## 18.2. Import `.txt`
- setiap baris menjadi satu item
- baris kosong default: tetap dibuat sebagai item kosong
- sediakan opsi saat import:
  - abaikan baris kosong
- saat import `.txt`, user memilih mode:
  - Lirik
  - atau Subtitle

## 18.3. Import `.lrc`
- parse timestamp standar
- parse teks lirik
- baca metadata dasar jika ada, terutama `[ti:]`
- jika judul proyek kosong dan file memiliki tag judul, gunakan sebagai judul default

### Multiple timestamp
Jika ditemukan multiple timestamp untuk satu teks, tampilkan opsi:
1. Buat baris terpisah untuk tiap timestamp → default
2. Gunakan timestamp pertama saja
3. Batal

## 18.4. Import `.srt`
- parse block standar SRT
- multiline text disimpan apa adanya
- newline dalam subtitle tetap dipertahankan sebagai bagian teks

## 18.5. Import ke proyek yang sedang terbuka
Jika user melakukan import saat editor sudah terbuka:
- tampilkan pilihan:
  - Replace seluruh isi
  - Append ke daftar yang ada

## 19. Export

## 19.1. Export Lirik
Format:
- `.lrc`

Format waktu:
- `[mm:ss.xx] teks`

Ketentuan:
- hanya baris yang memiliki `startTime` yang diekspor
- jika ada baris tanpa timestamp:
  - tampilkan peringatan
  - user bisa memilih:
    - skip baris tanpa timestamp
    - atau batal export
- jika judul tidak kosong, boleh menulis metadata `[ti:judul]`

## 19.2. Export Subtitle
Format:
- `.srt`

Format waktu:
- `hh:mm:ss,ms --> hh:mm:ss,ms`

Ketentuan:
- hanya baris dengan start dan end lengkap yang diekspor
- jika ada baris belum lengkap:
  - tampilkan peringatan
  - user bisa memilih:
    - skip baris belum lengkap
    - atau batal export

### Opsi multiline
Saat export SRT, tampilkan pilihan:
1. Multiline apa adanya → default
2. Paksa satu baris
   - newline diganti spasi

## 19.3. Aksi export
Export harus memiliki 2 tombol utama:
- Salin ke Clipboard
- Simpan File

### Simpan file
- Windows: save dialog native
- Android: SAF / save file picker
- user bisa:
  - mengganti nama file
  - memilih lokasi penyimpanan

### Nama file default
- diambil dari judul proyek
- karakter ilegal filename dibersihkan
- ekstensi otomatis:
  - `.lrc` untuk lyric
  - `.srt` untuk subtitle

## 20. Autosave

## 20.1. Keputusan MVP
- Gunakan autosave 1 proyek terakhir.
- Arsitektur harus memungkinkan upgrade ke multi-project di masa depan.

## 20.2. Perilaku
Aplikasi menyimpan state proyek terakhir secara lokal.

Save dilakukan:
- secara berkala dengan debounce
- saat aplikasi masuk background/pause
- saat user keluar editor

## 20.3. Data yang disimpan
- project id
- title
- mode
- media path/uri
- lines
- lastPosition
- updatedAt

## 20.4. Data yang tidak disimpan
- file media itu sendiri
- hanya path/uri referensi media

## 20.5. Restore
Saat aplikasi dibuka:
- jika ada autosave, tampilkan tombol Lanjutkan Proyek

Saat restore:
- jika media masih bisa diakses: lanjut normal
- jika media tidak bisa diakses:
  - proyek tetap dibuka
  - transport disabled
  - user diminta memilih ulang file media

## 20.6. Buat proyek baru
Karena autosave MVP hanya 1 proyek:
- jika autosave lama ada dan user memilih Buat Lirik / Buat Subtitle:
  - tampilkan konfirmasi bahwa proyek autosave lama dapat tertimpa
- atau sediakan pilihan:
  - lanjutkan proyek lama
  - buat baru

## 21. Permissions

### Android
Tambahkan permission yang relevan:
- `READ_MEDIA_AUDIO`
- `READ_MEDIA_VIDEO`
- `READ_EXTERNAL_STORAGE` untuk Android lama jika diperlukan
- `WRITE_EXTERNAL_STORAGE` untuk Android lama jika diperlukan

### Strategi
- gunakan SAF/file picker bila memungkinkan
- minta permission saat user memilih media
- jika permission ditolak:
  - tampilkan pesan jelas
  - aplikasi tidak boleh crash

## 22. Edge Cases yang Harus Ditangani

Aplikasi harus tetap stabil untuk kondisi berikut:

### Media
- media belum dimuat
- media path hilang setelah restore autosave
- file tidak didukung
- user mengganti media di tengah proyek

### Timing
- user menekan timestamp saat pause
- user menekan timestamp berulang kali
- subtitle duration sangat pendek
- endTime sama dengan startTime
- baris belum punya timestamp tapi muncul di list

### Editing
- baris kosong
- teks panjang
- subtitle multiline
- reorder saat playback berjalan
- delete active line
- undo setelah reorder/delete

### Export
- tidak ada baris yang punya timestamp
- masih ada baris tanpa waktu
- judul kosong
- karakter judul tidak valid untuk filename

## 23. UI Tambahan yang Diperlukan

### Top bar
- tombol kembali
- judul editable
- tombol pilih media
- tombol/menu export

### Transport bar
- -5s
- play/pause
- +5s
- undo
- redo

### Panel selected line
Muncul saat ada baris terpilih.
Berisi minimal:
- indikator baris terpilih
- untuk subtitle:
  - selector Start/End
- tombol -100ms
- tombol +100ms

### Tombol timestamp besar
- harus menonjol
- mudah ditekan
- mendukung:
  - tap untuk lyric
  - hold untuk subtitle

## 24. Non-Goals untuk MVP

Jangan tambahkan fitur berikut pada tahap ini kecuali diminta secara eksplisit:
- dark mode
- custom shortcut
- multi-project autosave
- timeline block dengan drag edge start/end terpisah
- snapping timeline kompleks
- auto-scroll lyric tingkat lanjut dengan efek karaoke kompleks
- cloud storage
- database lirik online
- auto transcription
- auto detect tempo
- AI lyric generation

## 25. Deliverables Implementasi

Saat implementasi kode, hasil yang diharapkan:

1. `pubspec.yaml`
2. setup Android permissions
3. struktur folder modular
4. model data
5. service:
   - parser LRC/SRT/TXT
   - exporter LRC/SRT
   - autosave service
   - permission service/helper
   - file service
   - media service
6. provider/state management
7. screens:
   - Home
   - Editor
8. widgets:
   - lyric strip
   - subtitle timeline
   - transport bar
   - line editor list
   - timestamp button
9. shortcut handler
10. export dialog
11. import dialog
12. autosave restore flow

## 26. Aturan Kerja untuk AI Coding

AI yang mengerjakan project ini wajib mengikuti aturan berikut:

1. Baca seluruh PRD sebelum membuat kode.
2. Jangan mengubah scope tanpa konfirmasi.
3. Jika ada bagian ambigu, tanyakan dulu.
4. Kerjakan secara bertahap, bukan langsung seluruh aplikasi.
5. Setiap tahap harus jelas:
   - file yang dibuat/diubah
   - cara test
   - kriteria selesai
6. Jangan membuat placeholder.
7. Jangan membuat TODO.
8. Jangan mengarang API package.
9. Jika tidak yakin terhadap API tertentu, katakan tidak yakin dan gunakan pendekatan paling aman.
10. Jangan menghapus struktur modular yang sudah disepakati.
11. Jangan menyederhanakan fitur inti tanpa izin.
12. Setiap perubahan harus tetap sesuai PRD ini.

## 27. Definisi Selesai

Suatu fitur dianggap selesai jika:
- kode dapat dijalankan secara logis
- tidak ada TODO
- tidak ada placeholder
- tidak ada import yang hilang secara jelas
- perilaku sesuai PRD
- edge case dasar ditangani
- ada penjelasan cara test

## 28. Keputusan Final yang Sudah Dikunci

Ringkasan keputusan penting:

- Player utama: `media_kit`
- Mode ringan: audio tetap jalan, preview video off
- Home: Lanjutkan Proyek / Buat Lirik / Buat Subtitle / Buka File
- Lirik boleh tanpa media untuk mengetik
- Subtitle boleh tanpa media untuk mengetik/import
- Timing lyric/subtitle butuh media
- Timing-first boleh membuat baris kosong bertimestamp
- Timestamp lyric: tap
- Timestamp subtitle: hold down/up
- Shortcut timestamp: `Z`
- Shortcut play/pause: `Space`
- Undo/Redo: untuk timing & struktur, bukan teks per karakter
- Timeline lyric: horizontal strip, tap to seek
- Timeline subtitle: block timeline Level 2 + zoom sederhana
- Fine-tuning: pilih baris, pilih Start/End, lalu +/-100ms
- Reorder: drag handle khusus
- Long press: menu aksi
- Import TXT: baris kosong tetap dibuat item, dengan opsi skip
- Import LRC multiple timestamp: tanya user, default buat baris terpisah
- Export SRT: tanya multiline atau satu baris, default multiline
- Autosave: 1 proyek terakhir dulu
- Custom shortcut: fase 2
- Struktur kode: modular/split
