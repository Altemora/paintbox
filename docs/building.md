# Paintbox: збірка, запуск і пакування

Як зібрати програму з джерел, запустити перевірки, зробити знімки вікна
й пакунки для Windows, Linux і macOS. Будова програми —
[architecture.md](architecture.md).

## Збірка і запуск

Потрібні Flutter 3.47 (Dart 3.13), стабільний Rust з `rustup` і, для
зміни моста, `flutter_rust_bridge_codegen` 2.13.0
(`cargo install flutter_rust_bridge_codegen --version 2.13.0`). Ядро
збирається разом із програмою: cargokit, підключений до плагіна
`paint_bridge`, викликає cargo під час `flutter build`, окремого кроку
немає.

```
cd app
flutter pub get
flutter run -d windows
flutter build windows --release
```

Зібрана програма — `app/build/windows/x64/runner/Release/paintbox.exe` з
`paintbox_bridge.dll` поруч. Аргументи командного рядка — файли, які
відкрити.

### Перевірка

```
tools/check.ps1 [-Build]
```

Скрипт робить `cargo fmt --check`, `cargo clippy -D warnings`,
`cargo test` для воркспейсу, збирає міст для тестів Flutter, потім у
`app/` — `flutter pub get`, `dart analyze --fatal-infos`, перевірку
формату й `flutter test` пакетів, що мають тести; з `-Build` — ще й
`flutter build windows --release`. Вручну те саме:

```
cargo build -p paintbox_bridge
cd app
dart analyze --fatal-infos .
melos run format:check
melos run test
```

Тести пакетів вантажать міст, зібраний cargo в `target/` кореня
(`BridgeLoader` у теці `test`): блоки й репозиторії перевіряються на
справжньому ядрі, а не на заглушці.

Після зміни `packages_tools/paint_bridge/rust/src/api` — `melos run
gen:bridge` (кодоген переписує `lib/src/rust` і `rust/src/frb_generated.rs`),
після зміни arb — `melos run gen:l10n`.

### Знімки

```
paintbox --screenshot=<шлях.png> [--scene=<назва>]
```

Програма відтворює сцени тими самими подіями, що й ввід користувача,
зберігає `<шлях>-<сцена>.png` і закривається. Сцени: `empty` — порожнє
полотно; `layers` — файл OpenRaster з двома шарами (градієнт і шар з
мазком та еліпсом, намальовані інструментами ядра), відкритий так само,
як File > Open, і еліптичне виділення, протягнуте вказівником; `effect`
— діалог Gaussian Blur з переглядом на виділенні; `text`, `lines`,
`transform` — Text, кінці й штрихи ліній, повернутий фрагмент; `effects`
— знімок на кожен ефект; `compact` — Colors у режимі Less і панель Text;
`strips` — панель параметрів кожного роду інструментів
(`strip-<інструмент>`). У режимі знімків
налаштування не читаються й не пишуться, буфер обміну — пам'ять процесу,
мова — українська.

## Кросплатформеність і пакування

Платформозалежного коду поза плагінами (`window_manager`,
`file_selector`, `pasteboard`, `desktop_drop`) і cargokit немає; вигляд
однаковий на всіх платформах, системні лише вікно і його панель.
Ідентифікатор програми — `dev.paintbox.Paintbox` (Linux `APPLICATION_ID`,
macOS `PRODUCT_BUNDLE_IDENTIFIER`, назва .desktop і AppStream); назва
вікна й пакунків — Paintbox. Значок малює `tools/make-icons.ps1`
(синя плитка, біла смуга пензля, жовта крапля) і записує всі розміри:
`app/windows/runner/resources/app_icon.ico`, набір `AppIcon` для macOS,
`packaging/icons` для MSIX і Linux. Готові пакунки лягають у `dist/`
(у `.gitignore`).

### Windows

```
tools/package-windows.ps1 [-SkipBuild] [-CertificatePath <pfx> -CertificatePassword <пароль> -Publisher "CN=..."]
```

Скрипт збирає `flutter build windows --release` (стандартний раннер не
відкриває консоль: вона з'являється лише під налагоджувачем), прибирає з
копії `data/flutter_assets/kernel_blob.bin` (ядро Dart, яке налагоджувальний
запуск лишає в спільній теці ресурсів; release виконує AOT `app.so`) і
робить:

- **переносний zip** `Paintbox-<версія>-windows-x64.zip` — тека збірки як
  є (`paintbox.exe`, `paintbox_bridge.dll`, `flutter_windows.dll`,
  плагіни, `data`), записаний `tar` (стандартні `/` у назвах, на відміну від
  `Compress-Archive` Windows PowerShell); розпакувати й запустити.
- **MSIX** `Paintbox-<версія>-windows-x64.msix` через `makeappx` з Windows
  SDK: маніфест `packaging/windows/AppxManifest.xml` (повна довіра,
  асоціації .ora, .png, .jpg, .bmp, .tga, .webp; плитки зі значка).
  **Без підпису** Windows його не встановить. Для підпису потрібен
  сертифікат підпису коду (.pfx) з темою, що збігається з `Publisher`
  маніфесту: від центру сертифікації (OV/EV, для розповсюдження) або
  власний для своїх машин (`New-SelfSignedCertificate -Type CodeSigningCert
  -Subject "CN=Paintbox"`, тоді його треба додати в «Довірені особи» машини);
  скрипт підписує `signtool` з тієї ж теки SDK з позначкою часу (підпис
  лишається чинним після закінчення сертифіката), коли передано
  `-CertificatePath`. Для Microsoft Store підписує сам Store.
- **інсталятор Inno Setup** `Paintbox-<версія>-windows-x64-setup.exe` за
  `packaging/windows/paintbox.iss` — лише коли Inno Setup 6
  встановлено (`winget install JRSoftware.InnoSetup`); інакше крок
  пропускається з повідомленням. Інсталятор ставить для поточного
  користувача без прав адміністратора (діалог пропонує й для всіх),
  ярлик у меню «Пуск», за бажанням — на робочому столі й асоціацію .ora.
  Непідписаний інсталятор SmartScreen зустрічає попередженням; підпис —
  той самий сертифікат (`signtool sign` над готовим .exe або
  `SignTool=` у сценарії).

Версія береться з `pubspec.yaml` (`0.1.0+1` → MSIX `0.1.0.1`).

### Linux

```
packaging/linux/build-appimage.sh
```

Скрипт збирає `flutter build linux --release` і пакує AppImage
`Paintbox-<версія>-linux-<арх>.AppImage` через `linuxdeploy` (завантажує
його в `dist/tools`, якщо змінна `LINUXDEPLOY` не вказує на
власний), з .desktop і AppStream-описом з `packaging/linux` і
значками hicolor 48–512; linuxdeploy береться з гілки `continuous`
(для відтворюваної збірки — закріпити версію в `LINUXDEPLOY`). Для збірки потрібні Flutter 3.47 для Linux,
Rust, `clang`, `cmake`, `ninja-build`, `pkg-config`, `libgtk-3-dev`
(їх же беруть `window_manager` і `screen_retriever`), `curl`; для
запуску — GTK 3 (`libgtk-3-0`), `libglib2.0-0`, `libstdc++6`, а AppImage —
ще `libfuse2` (або `--appimage-extract-and-run`). Бібліотеки GTK
лишаються системними (скрипт виключає GTK, GDK, Pango, Cairo, ATK,
HarfBuzz, epoxy: без середовища плагіна GTK вкладені вони ламаються на
інших дистрибутивах), `.so` плагінів і
`libpaintbox_bridge.so` їдуть у пакунку. `file_selector` показує діалог
GTK. `pasteboard` на Linux не пише зображення в буфер (лише читає):
копіювати в чужі програми там не вийде, доки плагін не замінено
(кандидат — `super_clipboard`). Перетягування файлів під Wayland і
нормування колеса — перевірити на справжній машині.

**Не виконано**: на машині розробки немає Linux із Flutter (у WSL видно
лише Windows-Flutter через `/mnt/c`, без `clang`), тож скрипт написано,
але не запущено.

### macOS

```
SIGN_IDENTITY="Developer ID Application: <ім'я> (<team id>)" NOTARY_PROFILE=paintbox packaging/macos/package-macos.sh
```

Скрипт збирає `flutter build macos --release` (`Paintbox.app`; cargokit
будує ядро через `build_pod.sh` для обох архітектур і вшиває його
статичною бібліотекою у `paint_bridge.framework` — потрібні Xcode і
`rustup target add aarch64-apple-darwin x86_64-apple-darwin`), підписує
зсередини назовні (`find -depth`: вкладене раніше за фреймворк, потім
програму) з hardened
runtime і `Release.entitlements`, надсилає zip на нотаризацію
(`xcrun notarytool submit --wait`), пришиває квиток (`stapler staple`) і
робить zip та dmg. Без `SIGN_IDENTITY` зупиняється після збірки.
Потрібні: обліковий запис Apple Developer, сертифікат «Developer ID
Application» у зв'язці ключів і профіль `notarytool store-credentials`.

Entitlements (`macos/Runner/*.entitlements`): без пісочниці. Програма
поширюється з Developer ID, а не через Mac App Store, тож пісочниця не
потрібна, а з нею збереження не працювало б: файл пишеться поруч як
`<назва>.part` і перейменовується, а пісочниця дає доступ лише до самого
вибраного файлу, не до теки; «Нещодавні файли» після перезапуску теж
вимагали б security-scoped bookmarks. Hardened runtime для нотаризації —
з параметрів `codesign`. У DebugProfile лишаються `allow-jit` і
`network.server` для налагодження Flutter. Для Mac App Store знадобились
би пісочниця, `files.user-selected.read-write`, запис на місці замість
`.part` і закладки для нещодавніх файлів.
Ctrl у клавішах програми на macOS зараховує й Cmd.

**Не виконано**: машини з macOS немає — скрипт і документ, без запуску.

