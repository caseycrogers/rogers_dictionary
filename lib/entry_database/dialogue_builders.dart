import 'package:rogers_dictionary/util/default_map.dart';
import 'package:rogers_dictionary/protobufs/dialogues.pb.dart';

typedef DialogueSubChapter = DialogueChapter_SubChapter;
typedef Dialogue = DialogueChapter_Dialogue;

class DialogueChapterBuilder {
  final int chapterId;
  final String englishTitle;
  final String spanishTitle;

  final Map<String, DialogueSubChapterBuilder> subChapters = {};

  DialogueChapterBuilder({
    required this.chapterId,
    required this.englishTitle,
    required this.spanishTitle,
  });

  DialogueChapter build() =>
      DialogueChapter(
        chapterId: chapterId,
        englishTitle: englishTitle,
        spanishTitle: spanishTitle,
        dialogueSubChapters: subChapters.values.map((b) => b.build()),
      );

  DialogueChapterBuilder addDialogue(String englishSubChapter,
      String spanishSubchapter,
      String englishDialogue,
      String spanishDialogue,) {
    subChapters
        .getOrElse(
        englishSubChapter,
        DialogueSubChapterBuilder(
            englishTitle: englishSubChapter,
            spanishTitle: spanishSubchapter))
        .addDialogue(englishDialogue, spanishDialogue);
    return this;
  }
}

class DialogueSubChapterBuilder {
  final String englishTitle;
  final String spanishTitle;

  List<Dialogue> dialogues = [];

  DialogueSubChapterBuilder({
    required this.englishTitle,
    required this.spanishTitle,
  });

  DialogueSubChapterBuilder addDialogue(String englishContent,
      String spanishContent) {
    dialogues.add(Dialogue(
      englishContent: englishContent,
      spanishContent: spanishContent,
    ));
    return this;
  }

  DialogueSubChapter build() =>
      DialogueSubChapter(
        englishTitle: englishTitle,
        spanishTitle: spanishTitle,
        dialogues: dialogues,
      );
}
