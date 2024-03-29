import 'dart:async';
import 'dart:convert';

import 'package:device_frame/device_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rogers_dictionary/clients/dialogue_builders.dart';
import 'package:rogers_dictionary/clients/local_persistence.dart';
import 'package:rogers_dictionary/dictionary_app.dart';
import 'package:rogers_dictionary/i18n.dart' as i18n;
import 'package:rogers_dictionary/main.dart';
import 'package:rogers_dictionary/models/dialogues_page_model.dart';
import 'package:rogers_dictionary/models/dictionary_model.dart';
import 'package:rogers_dictionary/models/entry_search_model.dart';
import 'package:rogers_dictionary/models/translation_mode.dart';
import 'package:rogers_dictionary/pages/dialogues_page.dart';
import 'package:rogers_dictionary/protobufs/dialogues.pb.dart';
import 'package:rogers_dictionary/protobufs/entry.pb.dart';
import 'package:rogers_dictionary/screenshot_template.dart';
import 'package:rogers_dictionary/util/collection_utils.dart';
import 'package:rogers_dictionary/util/string_utils.dart';
import 'package:rogers_dictionary/widgets/dialogues_page/chapter_view.dart';
import 'package:rogers_dictionary/widgets/dictionary_page/dictionary_tab.dart';
import 'package:rogers_dictionary/widgets/search_page/entry_view.dart';
import 'package:rogers_dictionary/widgets/search_page/selected_entry_switcher.dart';
import 'package:rogers_dictionary/widgets/translation_mode_switcher.dart';

import '../test_driver/screenshots_test.dart';

const Locale en = Locale('en', '');
const Locale es = Locale('es', '');

Future<void> main() async {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late DictionaryModel dictionaryModel;

  Future<void>? isInitialized;

  Future<void> _initialize() async {
    if (isInitialized != null) {
      await isInitialized;
    } else {
      WidgetsApp.debugAllowBannerOverride = false;
      await initialize();
      await DictionaryApp.analytics.setAnalyticsCollectionEnabled(false);
      await binding.convertFlutterSurfaceToImage();
    }
    dictionaryModel = DictionaryModel.instance;
  }

  // Used instead of `setUpAll` because that doesn't support a future.
  setUp(_initialize);

  tearDown(() {
    LocalPersistence.instance.reset();
    dictionaryModel.englishPageModel.dialoguesPageModel.reset();
    dictionaryModel.spanishPageModel.dialoguesPageModel.reset();
    DictionaryModel.reset();
    EntrySearchModel.reset();
  });

  for (final Locale locale in [
    en,
    es,
  ]) {
    for (final ScreenshotConfig config in [
      // ios.
      // https://help.apple.com/app-store-connect/#/devd274dd925
      ScreenshotConfig(
        category: '6.5',
        device: Devices.ios.iPhone13ProMax,
        outputWidth: 1284,
        outputHeight: 2778,
      ),
      ScreenshotConfig(
        category: '5.8',
        device: Devices.ios.iPhone13,
        outputWidth: 1170,
        outputHeight: 2532,
      ),
      ScreenshotConfig(
        category: '5.5',
        // Technically not the correct device but it's the same aspect ratio.
        device: Devices.ios.iPhoneSE,
        outputWidth: 1242,
        outputHeight: 2208,
      ),
      ScreenshotConfig(
        category: '12.9 gen2',
        device: Devices.ios.iPad12InchesGen2,
        outputHeight: 2732,
        outputWidth: 2048,
      ),
      ScreenshotConfig(
        category: '12.9 gen4',
        device: Devices.ios.iPad12InchesGen4,
        outputHeight: 2732,
        outputWidth: 2048,
      ),
      // Android.
      //ScreenshotConfig(
      //  category: '',
      //  device: Devices.android.onePlus8Pro,
      //  outputHeight: 3168,
      //  outputWidth: 1440,
      //),
      //ScreenshotConfig(
      //  category: '10',
      //  device: Devices.android.largeTablet,
      //),
      //ScreenshotConfig(
      //  category: '7',
      //  device: Devices.android.mediumTablet,
      //),
    ]) {
      String screenshotName(String suffix) {
        return jsonEncode(
          ScreenshotIdentifier(
            path: [
              // ignore: prefer_interpolation_to_compose_strings
              config.device.identifier.platform.name.enumString,
              '${config.device.identifier.name} (${config.category})',
              locale.languageCode,
              suffix,
            ],
            width: config.outputWidth.toInt(),
            height: config.outputHeight.toInt(),
            offsetY: kTopPad.toInt(),
          ),
        );
      }

      testWidgets('($locale) (${config.device.name}) - English search page.',
          (WidgetTester tester) async {
        // English search page.
        await tester.pumpWidget(
          DictionaryScreenshotTemplate(
            headerText: const i18n.Message(
              'Translate over 16K English medical terms to Spanish!',
              '¡Traduzca más de 16K términos médicos en inglés al español!',
            ),
            config: config,
            locale: locale,
          ),
        );
        final BuildContext context = await pumpUntilFound(
          tester,
          find.byHeadword('abdomen'),
          msg: 'abdomen',
        );
        if (config.isLargeScreen) {
          dictionaryModel.onHeadwordSelected(context, 'abdomen');
          // Wait until the widget has animated out of view.
          await pumpUntilNotFound(
            tester,
            find.byType(NoEntryBackground),
            msg: 'NoEntryBackground',
          );
        }
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 200));
        await binding.takeScreenshot(
          screenshotName('01-az_en'),
        );
      });

      testWidgets('($locale) (${config.device.name}) - Spanish search page.',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          DictionaryScreenshotTemplate(
            headerText: const i18n.Message(
              '...and over 16K Spanish medical terms to English!',
              '¡...y más de 16K términos médicos del español al inglés!',
            ),
            config: config,
            locale: locale,
          ),
        );
        dictionaryModel.onTranslationModeChanged();
        // `Abandono del tabaco` doesn't show up on some small screen devices.
        final String targetHeadword =
            config.isLargeScreen ? 'abandono del tabaco' : 'abandonar';
        final BuildContext context = await pumpUntilFound(
          tester,
          find.byHeadword(targetHeadword),
          msg: targetHeadword,
        );
        if (config.isLargeScreen) {
          dictionaryModel.onHeadwordSelected(context, targetHeadword);
          await pumpUntilNotFound(
            tester,
            find.byType(NoEntryBackground),
            msg: 'NoEntryBackground',
          );
        }
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 200));
        await binding.takeScreenshot(
          screenshotName('02-az_es'),
        );
      });

      testWidgets('($locale) (${config.device.name}) - Bookmarks.',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          DictionaryScreenshotTemplate(
            headerText: const i18n.Message(
              'Bookmark words you want to study!',
              '¡Marque las palabras que quiere estudiar!',
            ),
            config: config,
            locale: locale,
          ),
        );
        dictionaryModel.onTranslationModeChanged();
        BuildContext context = await pumpUntilFound(
          tester,
          find.byHeadword('abandonar'),
          msg: 'abandonar',
        );
        context = await findAndBookmark(
            context, tester, TranslationMode.Spanish, 'pie');
        context = await findAndBookmark(
            context, tester, TranslationMode.Spanish, 'brazo');
        context = await findAndBookmark(
            context, tester, TranslationMode.Spanish, 'pierna');
        context = await findAndBookmark(
            context, tester, TranslationMode.Spanish, 'rodilla');
        context = await findAndBookmark(
            context, tester, TranslationMode.Spanish, 'cabeza');
        context = await findAndBookmark(
            context, tester, TranslationMode.Spanish, 'nariz');

        dictionaryModel.currentTab.value = DictionaryTab.bookmarks;
        if (config.isLargeScreen) {
          dictionaryModel.onHeadwordSelected(context, 'pie');
          await pumpUntilNotFound(
            tester,
            find.byType(NoEntryBackground),
            msg: 'NoEntryBackground',
          );
        }
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 200));
        await binding.takeScreenshot(
          screenshotName('03-bookmarks_es'),
        );
      });

      testWidgets('($locale) (${config.device.name}) - Dialogue Chapters.',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          DictionaryScreenshotTemplate(
            headerText: const i18n.Message(
              'Browse translations of typical medical dialogues!',
              '¡Explore las traducciones de diálogos médicos típicos!',
            ),
            config: config,
            locale: locale,
          ),
        );
        dictionaryModel.currentTab.value = DictionaryTab.dialogues;
        if (locale == es) {
          dictionaryModel.onTranslationModeChanged();
        }
        await pumpUntilFound(
          tester,
          find.byType(DialoguesPage),
          msg: 'DialoguesPage',
        );
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 200));
        await binding.takeScreenshot(
          screenshotName('04-chapters_${locale.languageCode}'),
        );
      });

      testWidgets('($locale) (${config.device.name}) - Dialogues.',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          DictionaryScreenshotTemplate(
            headerText: const i18n.Message(
              'Browse translations of typical medical dialogues!',
              '¡Explore las traducciones de diálogos médicos típicos!',
            ),
            config: config,
            locale: locale,
          ),
        );
        final DialoguesPageModel dialoguesModel =
            dictionaryModel.translationModel.value.dialoguesPageModel;
        dictionaryModel.currentTab.value = DictionaryTab.dialogues;
        if (locale == es) {
          dictionaryModel.onTranslationModeChanged();
        }
        final DialogueChapter chapter = await pumpUntil(
          tester,
          () {
            return dialoguesModel.dialogues
                .where((chapter) {
                  return chapter.englishTitle == 'History and Physical';
                })
                .emptyToNull
                ?.first;
          },
          msg: 'chapter: \'History and Physical\'',
        );
        final DialogueSubChapter subChapter =
            chapter.dialogueSubChapters.firstWhere((subChapter) {
          return subChapter.englishTitle == 'Past Medical History';
        });
        final BuildContext context = await pumpUntilFound(
          tester,
          find.byType(DialoguesPage),
          msg: 'DialoguesPage',
        );
        dialoguesModel.onChapterSelected(context, chapter, subChapter);
        await pumpUntilFound(
          tester,
          find.byType(ChapterView),
          msg: 'ChapterView',
        );
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 200));
        await binding.takeScreenshot(
          screenshotName('05-dialogues_${locale.languageCode}'),
        );
      });

      testWidgets('($locale) (${config.device.name}) - Fullscreen entry.',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          DictionaryScreenshotTemplate(
            headerText: const i18n.Message(
              'Translations are detailed and comprehensive!',
              '¡Las traducciones son detalladas y completas!',
            ),
            config: config,
            locale: locale,
          ),
        );
        final BuildContext context = await pumpUntilFound(
          tester,
          find.byHeadword('abdomen'),
          msg: 'abdomen',
        );
        // Necessary or else the search string won't update consistently
        // for reasons unknown.
        await tester.pumpAndSettle();
        dictionaryModel.currTranslationModel.searchModel.entrySearchModel
            .onSearchStringChanged(
          context: context,
          newSearchString: 'str',
        );
        dictionaryModel.onHeadwordSelected(context, 'strain');
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 200));
        await binding.takeScreenshot(
          screenshotName('06-complex_entry_en'),
        );
      });

      testWidgets('($locale) (${config.device.name}) - Regional entry.',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          DictionaryScreenshotTemplate(
            headerText: const i18n.Message(
              '...and include regional terms and colloquialisms!',
              '¡...e incluyen regionalismos y coloquialismos!',
            ),
            config: config,
            locale: locale,
          ),
        );
        BuildContext context = await pumpUntilFound(
          tester,
          find.byHeadword('abdomen'),
          msg: 'abdomen',
        );
        // Necessary or else the search string won't update consistently
        // for reasons unknown.
        await tester.pumpAndSettle();
        dictionaryModel.currTranslationModel.searchModel.entrySearchModel
            .onSearchStringChanged(
          context: context,
          newSearchString: 'bug',
        );
        context = await pumpUntilFound(
          tester,
          find.byHeadword('kissing bug'),
          msg: 'kissing bug',
        );
        dictionaryModel.onHeadwordSelected(context, 'kissing bug');
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 200));
        await binding.takeScreenshot(
          screenshotName('07-regional_en'),
        );
      });

      testWidgets('($locale) (${config.device.name}) - dark mode.',
          (WidgetTester tester) async {
        dictionaryModel.onDarkModeToggled();
        await tester.pumpWidget(
          DictionaryScreenshotTemplate(
            headerText: const i18n.Message(
              'Dark mode reduces eye strain!',
              '¡El modo oscuro reduce la fatiga visual!',
            ),
            config: config,
            locale: locale,
          ),
        );
        late BuildContext context;
        if (locale == es) {
          dictionaryModel.onTranslationModeChanged();
        }
        context = await pumpUntilFound(
          tester,
          find.byHeadword(locale == en ? 'abdomen' : 'abandonar'),
          msg: locale == en ? 'abdomen' : 'abandonar',
        );
        // Necessary or else the search string won't update consistently
        // for reasons unknown.
        await tester.pumpAndSettle();
        dictionaryModel.currTranslationModel.searchModel.entrySearchModel
            .onSearchStringChanged(
          context: context,
          newSearchString: locale == en ? 'fl' : 'gri',
        );
        final String headword = locale == en ? 'flu' : 'gripe';
        context = await pumpUntilFound(
          tester,
          find.byHeadword(headword),
          msg: headword,
        );
        if (config.isLargeScreen) {
          dictionaryModel.onHeadwordSelected(context, headword);
          await pumpUntilNotFound(
            tester,
            find.byType(NoEntryBackground),
            msg: 'NoEntryBackground',
          );
        }
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 200));
        await binding.takeScreenshot(
          screenshotName('08-dark_${locale.languageCode}'),
        );
      });
    }
  }
}

extension FinderUtils on CommonFinders {
  Finder byHeadword(String headword) {
    return find.byWidgetPredicate((widget) =>
        widget is EntryViewPreview && widget.entry.headword.text == headword);
  }

  Finder byEntry(Entry entry) {
    return find.byWidgetPredicate(
        (widget) => widget is EntryViewPreview && widget.entry == entry);
  }

  Finder byTranslationMode(TranslationMode mode) {
    return find.byWidgetPredicate((widget) =>
        widget is TranslationModelProvider &&
        widget.translationModel.translationMode == mode);
  }
}

Future<Element> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 5),
  required String msg,
}) {
  return pumpUntil(
    tester,
    () {
      final Iterable<Element> elements = finder.evaluate();
      return elements.isEmpty ? null : elements.first;
    },
    msg: msg,
  );
}

Future<void> pumpUntilNotFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 5),
  required String msg,
}) {
  return pumpUntil(
    tester,
    () {
      final Iterable<Element> elements = finder.evaluate();
      // Return an arbitrary non-null object once the item is no longer found
      // to short-circuit `pumpUntil`.
      return elements.isEmpty ? Object() : null;
    },
    msg: 'not $msg',
  );
}

Future<T> pumpUntil<T extends Object>(
  WidgetTester tester,
  T? Function() test, {
  Duration timeout = const Duration(seconds: 5),
  required String msg,
}) async {
  bool timerDone = false;
  final timer = Timer(
    timeout,
    () {
      throw TimeoutException('Pump until has timed out trying to find: $msg');
    },
  );
  T? result;
  while (timerDone != true) {
    await tester.pump();
    result = test();
    if (result != null) {
      timerDone = true;
    }
  }
  timer.cancel();
  // If we've broken out of the for loop result must be non-null.
  return result!;
}

Future<BuildContext> findAndBookmark(
  BuildContext context,
  WidgetTester tester,
  TranslationMode mode,
  String headword,
) async {
  // Necessary or else the search string won't update consistently
  // for reasons unknown.
  await tester.pumpAndSettle();
  DictionaryModel.instance.currTranslationModel.searchModel.entrySearchModel
      .onSearchStringChanged(
    context: context,
    newSearchString: headword,
  );
  final Element element = await pumpUntilFound(
    tester,
    find.byHeadword(headword),
    msg: 'bookmarking: \'$headword\'',
  );
  final Entry entry = (element.widget as EntryViewPreview).entry;
  await DictionaryApp.db.setBookmark(TranslationMode.Spanish, entry, true);
  return element;
}
