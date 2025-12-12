
import 'package:flutter_test/flutter_test.dart';
import 'package:foto_pdf_app/main.dart';

void main() {
  testWidgets('Tela inicial mostra título e botões principais',
      (WidgetTester tester) async {
    // Monta o app
    await tester.pumpWidget(const MyApp());

    // Confere se o título do AppBar aparece
    expect(find.text('Foto → PDF (Flutter)'), findsOneWidget);

    // Confere se os botões existem na tela
    expect(find.text('Tirar Foto'), findsOneWidget);
    expect(find.text('Gerar PDF'), findsOneWidget);
  });
}
