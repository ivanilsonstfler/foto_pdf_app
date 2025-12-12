# 📸 Foto → PDF (Flutter)

Aplicativo Flutter **mobile (Android)** que:

1. Abre a câmera do dispositivo  
2. Permite tirar uma foto  
3. Gera um **arquivo PDF** contendo essa foto em uma página A4  
4. Salva o PDF no armazenamento interno do app e tenta abrir com um leitor de PDF instalado no aparelho

---

## 🧰 Tecnologias

- **Flutter** (SDK 3.x)
- **Dart**
- **image_picker** – captura da câmera
- **pdf** – geração do arquivo PDF em memória
- **path_provider** – diretório para salvar o PDF
- **open_filex** – abre o PDF com o app padrão do sistema

---

## ✅ Pré-requisitos

Para rodar esse projeto você precisa:

1. **Flutter SDK** instalado e no PATH  
   - Verifique com:
     ```bash
     flutter --version
     ```

2. **Android SDK** (pode ser instalado junto com o Android Studio):
   - Comando para checar:
     ```bash
     flutter doctor
     ```
   - Resolva os itens marcados com `X` (principalmente **Android toolchain**).

3. **JDK 17+** instalado e configurado:
   - Verifique com:
     ```bash
     java -version
     ```
   - A variável `JAVA_HOME` deve apontar para a pasta do JDK  
     (por exemplo: `C:\Program Files\Android\Android Studio\jbr` ou `C:\Program Files\Java\jdk-17.x.x`).

4. **Dispositivo Android ou Emulador**
   - **Celular físico** com:
     - *Opções do desenvolvedor* ativadas
     - **Depuração USB** ativada
   - ou um **emulador Android** criado pelo Android Studio.

---

## 📦 Dependências do projeto

No `pubspec.yaml`, as dependências principais são:

```yaml
environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  image_picker: ^1.1.2
  pdf: ^3.11.0
  path_provider: ^2.1.4
  open_filex: ^4.4.0

dev_dependencies:
  flutter_test:
    sdk: flutter

Após editar o pubspec.yaml, rode:

flutter pub get

🔐 Permissões Android

Arquivo: android/app/src/main/AndroidManifest.xml

As permissões devem ficar logo após a tag <manifest>, fora da tag <application>:

<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
    <!-- Opcional para compatibilidade com Android mais antigo -->
    <uses-permission
        android:name="android.permission.WRITE_EXTERNAL_STORAGE"
        android:maxSdkVersion="29" />

    <application
        android:label="foto_pdf_app"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>

    <queries>
        <intent>
            <action android:name="android.intent.action.PROCESS_TEXT" />
            <data android:mimeType="text/plain" />
        </intent>
    </queries>

</manifest>

📂 Estrutura básica
foto_pdf_app/
├─ android/
├─ ios/
├─ lib/
│  └─ main.dart   # Tela principal, lógica de câmera e PDF
├─ pubspec.yaml
└─ README.md

lib/main.dart (resumo)

Mostra um texto: “Nenhuma foto tirada ainda” ou a miniatura da foto.

Botão Tirar Foto:

Usa image_picker com ImageSource.camera.

Armazena a foto em _capturedImage.

Botão Gerar PDF:

Se não houver foto, mostra SnackBar de aviso.

Lê os bytes da foto, cria um pw.Document().

Adiciona uma página A4 (PdfPageFormat.a4) com a imagem centralizada.

Salva em getApplicationDocumentsDirectory().

Atualiza _lastPdfPath e usa OpenFilex.open(pdfPath) para abrir.

▶️ Como rodar o app
1. Confirmar dispositivos disponíveis
flutter devices


Exemplo de saída:

SEU CELUAR (mobile) • xxxxxxxxx• android-arm64 • Android 12 (API 31)
emulator-5554       • emulator-5554 • android-x64   • Android 12 (API 31)
windows             • windows-x64
chrome              • web-javascript
edge                • web-javascript

2. Rodar no celular físico

Com o celular conectado via USB e Depuração USB ativa:

flutter run -d 000000000


(Substitua pelo ID do seu dispositivo.)

3. Rodar no emulador

Abra o Android Studio → Device Manager → inicie o emulador.

Depois rode:

flutter run -d emulator-5554

📄 Onde o PDF é salvo?

O PDF é salvo no diretório de documentos do app:

Android: algo como
.../Android/data/com.example.foto_pdf_app/files/

O caminho completo é mostrado no SnackBar e também em texto na parte de baixo da tela:

Último PDF:
< caminho completo >


Se houver um leitor de PDF instalado no dispositivo, o app tenta abrir o arquivo automaticamente via open_filex.

🛠️ Comandos úteis
Limpar build e dependências
flutter clean
flutter pub get

Gerar APK de release
flutter build apk --release


O APK ficará em:

build/app/outputs/flutter-apk/app-release.apk

🧪 Testes (opcional)

O projeto pode conter um teste simples em test/widget_test.dart que verifica se a tela inicial mostra:

Título “Foto → PDF (Flutter)”

Botões “Tirar Foto” e “Gerar PDF”

Rodar testes:

flutter test

🧷 Problemas comuns
1. Gradle task assembleDebug failed with exit code 1

Geralmente relacionado a:

Android SDK incompleto → abra o Android Studio e instale:

SDK Platform (API 31+)

Platform-Tools

Build-Tools

NDK corrompido → apagar a pasta
C:\Users\<usuario>\AppData\Local\Android\sdk\ndk\<versão>
e deixar o Android baixar novamente.

2. error: unexpected element <uses-permission> found in <manifest><application>.

As permissões <uses-permission> estão dentro de <application>.
Mova todas as <uses-permission> para logo após <manifest>, como mostrado acima.

3. Build failed due to use of deleted Android v1 embedding

Rode na raiz do projeto:

flutter create .


Isso atualiza os arquivos Android para o v2 embedding.
Depois recoloque as permissões no AndroidManifest.xml.