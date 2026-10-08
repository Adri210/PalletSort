import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palletsort/main.dart';

void main() {
  void expectNoFlutterException(WidgetTester tester) {
    final exception = tester.takeException();
    if (exception is FlutterError) {
      fail(exception.toStringDeep());
    }
    expect(exception, isNull);
  }

  Future<void> setViewport(WidgetTester tester, {required Size size}) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('fluxo principal funciona em uma tela de celular', (
    tester,
  ) async {
    await setViewport(tester, size: const Size(390, 844));
    await tester.pumpWidget(const MyApp());

    expect(
      find.text('Pallets organizados.\nOperação em movimento.'),
      findsOneWidget,
    );
    expect(find.text('Começar agora'), findsOneWidget);
    expectNoFlutterException(tester);

    await tester.tap(find.text('Começar agora'));
    await tester.pumpAndSettle();

    expect(find.text('Bem-vindo de volta'), findsOneWidget);
    expect(find.byKey(const Key('emailField')), findsOneWidget);
    expectNoFlutterException(tester);

    await tester.tap(find.byKey(const Key('forgotPasswordButton')));
    await tester.pumpAndSettle();

    expect(find.text('Recuperar senha'), findsOneWidget);
    expect(find.byKey(const Key('recoveryEmailField')), findsOneWidget);
    expectNoFlutterException(tester);
  });

  testWidgets('layout inicial se adapta a uma tela desktop', (tester) async {
    await setViewport(tester, size: const Size(1440, 900));
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text('GESTÃO INTELIGENTE DE PALLETS'), findsOneWidget);
    expect(find.text('Em qualquer tela'), findsOneWidget);
    expect(find.text('Identificação em segundos'), findsOneWidget);
    expectNoFlutterException(tester);

    await tester.tap(find.text('Começar agora'));
    await tester.pumpAndSettle();

    expect(
      find.text('Sua operação começa com uma visão clara.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('emailField')), findsOneWidget);
    expectNoFlutterException(tester);
  });

  testWidgets('tela inicial continua utilizável em celular compacto', (
    tester,
  ) async {
    await setViewport(tester, size: const Size(320, 568));
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text('Começar agora'), findsOneWidget);
    expectNoFlutterException(tester);

    await tester.drag(
      find.byType(SingleChildScrollView).first,
      const Offset(0, -420),
    );
    await tester.pump();
    expectNoFlutterException(tester);
  });

  testWidgets('formulário de login apresenta validação acessível', (
    tester,
  ) async {
    await setViewport(tester, size: const Size(390, 844));
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Começar agora'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Entrar'));
    await tester.pump();

    expect(find.text('Informe seu e-mail'), findsOneWidget);
    expect(find.text('Informe sua senha'), findsOneWidget);
    expectNoFlutterException(tester);
  });

  testWidgets('fluxo responsivo funciona em diferentes formatos de celular', (
    tester,
  ) async {
    const viewports = <String, Size>{
      'compacto': Size(280, 653),
      'pequeno': Size(320, 568),
      'grande': Size(430, 932),
      'paisagem': Size(667, 375),
    };

    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final viewport in viewports.entries) {
      tester.view.physicalSize = viewport.value;
      await tester.pumpWidget(const MyApp());
      await tester.pump();

      expect(
        find.text('Começar agora'),
        findsOneWidget,
        reason: 'Tela inicial no formato ${viewport.key}',
      );
      expectNoFlutterException(tester);

      await tester.ensureVisible(find.text('Começar agora'));
      await tester.tap(find.text('Começar agora'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('emailField')),
        findsOneWidget,
        reason: 'Login no formato ${viewport.key}',
      );
      expectNoFlutterException(tester);

      await tester.ensureVisible(find.byKey(const Key('forgotPasswordButton')));
      await tester.tap(find.byKey(const Key('forgotPasswordButton')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('recoveryEmailField')),
        findsOneWidget,
        reason: 'Recuperação de senha no formato ${viewport.key}',
      );
      expectNoFlutterException(tester);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    }
  });

  testWidgets('celular compacto suporta texto ampliado', (tester) async {
    await setViewport(tester, size: const Size(320, 568));
    tester.platformDispatcher.textScaleFactorTestValue = 1.4;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(const MyApp());
    await tester.pump();
    expectNoFlutterException(tester);

    await tester.ensureVisible(find.text('Começar agora'));
    await tester.tap(find.text('Começar agora'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('emailField')), findsOneWidget);
    expectNoFlutterException(tester);
  });
}
