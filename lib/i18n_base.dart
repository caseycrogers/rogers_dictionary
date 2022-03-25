import 'package:rogers_dictionary/util/string_utils.dart';

//  Localization for DictionaryPage.
_CapMessage english = _CapMessage('english', 'inglés');
_CapMessage spanish = _CapMessage('spanish', 'español');

_CapMessage dictionary = _CapMessage('terms', 'términos');
_CapMessage bookmarks = _CapMessage('bookmarks', 'marcadores');
_CapMessage dialogues = _CapMessage('dialogues', 'diálogos');

// Localizations for the about page.
_CapMessage about = _CapMessage('about', 'sobre');
Message aboutPassage = const Message(
  'Hi, welcome to my English/Spanish medical translation app, the digital '
      'version of the 5th edition of my bilingual medical dictionary to be '
      'published later this year (2022). The app translates any medical term'
      ' likely to come up in a conversation between a health professional and '
      'a patient, including slang, regionalisms, and more.\n\n'
      'It also provides an extensive sample dialogue section based on my '
      '30-plus year history as an internist with Spanish-speaking patients in '
      'outpatient, Med-Surg ward, and ICU settings.\n',
  'Hola, bienvenido a mi applicación de traducción médica inglés/español, '
      'la versión digital de la 5ta edición de mi diccionario médico bilingüe '
      'que se publicará a finales de este año (2022). La app traduce cualquier '
      'término médico que pueda surgir en una conversación entre un '
      'profesional de la salud y un paciente, incluyendo jergas, regionalismos '
      'y más.\n\n'
      'También proporciona una amplia sección de diálogos de muestra '
      'basada en mi experiencia de más de 30 años como internista con '
      'pacientes hispanohablantes en entornos ambulatorios y hospitalarios, '
      'incluso en la UCI.\n',
);
Message enjoyTheApp = const Message('Enjoy the app!', '¡Disfruta de la app!');

// Localization for EntryList.
_CapMessage search = _CapMessage('search', 'buscar');
Message enterTextHint = const Message(
    'Enter text above to search for a translation ',
    'Ingrese texto arriba para buscar una traducción ');
Message noBookmarksHint = const Message(
    'No results! Try bookmarking an entry first ',
    '¡No hay entradas! Intenta aplicar marcador a un artículo primero ');
Message typosHint = const Message('No results! Check for typos ',
    '¡No hay resultados! Compruebe si hay errores ortográficos ');
Message swipeForSpanish = const Message('or swipe left for spanish mode.',
    'o desliza a la izquierda para traducir términos en español.');
Message swipeForEnglish = const Message('or swipe right for english mode.',
    'o desliza a la derecha para traducir términos en inglés.');

// Localizations for EntryView.
Message irregularInflections =
    const Message('Irregular Inflections', 'Inflexiones Irregulares');
Message examplePhrases = const Message('Example Phrases', 'Frases de Ejemplo');
Message editorialNotes = const Message('Editorial Notes', 'Notas Editoriales');
Message related = const Message('Related', 'Relacionado');

// Localization for the help menu.
Message giveFeedback = const Message('give feedback', 'dar opinión');
Message aboutThisApp = const Message('about this app', 'sobre la app');

// Localization for getting feedback.
_CapMessage feedback = _CapMessage('feedback', 'comentarios');
_CapMessage feedbackType = _CapMessage('feedback type', 'tipo de comentarios');
_CapMessage submit = _CapMessage('submit', 'enviar');
Message feedbackError = const Message(
    'Unknown error, failed to submit feedback',
    'Error desconocido, no se pudo enviar comentarios');

_CapMessage translationError =
    _CapMessage('translation error', 'error de traducción');
_CapMessage bugReport = _CapMessage('bug report', 'error informático');
_CapMessage featureRequest =
    _CapMessage('feature request', 'solicitud de función');
_CapMessage other = _CapMessage('other', 'otro');

// Parts of speech
Message adjective = const Message('adjective', 'adjetivo');
Message adverb = const Message('adverb', 'adverbio');
Message conjunction = const Message('conjunction', 'conjunción');
Message degree = const Message('degree', 'grado');
Message feminineNoun = const Message('feminine noun', 'nombre femenino');
Message femininePluralNoun =
    const Message('feminine plural noun', 'nombre femenino plural');
Message femininePluralNounParen =
    const Message('feminine (plural) noun', 'nombre femenino (plural)');
Message infinitive = const Message('infinitive', 'infinitivo');
Message interjection = const Message('interjection', 'interjección');
Message masculineNoun = const Message('masculine noun', 'nombre masculino');
Message masculineFeminineNoun =
    const Message('masculine/feminine noun', 'nombre masculino/femenino');
Message masculinePluralNoun =
    const Message('masculine plural noun', 'nombre masculino plural');
Message masculineFemininePluralNoun = const Message(
    'masculine/feminine plural noun', 'nombre masculino/femenino plural');
Message masculinePluralNounParen =
    const Message('masculine (plural) noun', 'nombre masculino (plural)');
Message noun = const Message('noun', 'nombre');
Message pluralNoun = const Message('plural noun', 'nombre plural');
Message pluralNounParen = const Message('(plural) noun', 'nombre (plural)');
Message prefix = const Message('prefix', 'prefijo');
Message preposition = const Message('preposition', 'preposición');
Message verb = const Message('verb', 'verbo');
Message intransitiveVerb =
    const Message('intransitive verb', 'verbo intransitivo');
Message reflexiveVerb = const Message('reflexive verb', 'verbo reflexivo');
Message transitiveVerb = const Message('transitive verb', 'verbo transitivo');
Message phrase = const Message('phrase', 'frase');
Message blank = const Message('', '');

Message adjectivePhrase = const Message('adjective phrase', 'frase adjectival');
Message adverbPhrase = const Message('adverb phrase', 'frase adverbial');
Message degreePhrase = const Message('degree phrase', 'frase de grado');
Message nounPhrase = const Message('noun phrase', 'frase nominal');
Message pluralNounPhrase = const Message('plural noun phrase', 'frase nominal');
Message prepositionPhrase =
    const Message('prepositional phrase', 'frase preposicional');
Message verbPhrase = const Message('verb phrase', 'frase verbal');
Message feminineNounPhrase =
    const Message('feminine noun phrase', 'frase nominal femenina');
Message femininePluralNounPhrase =
    const Message('feminine plural noun phrase', 'frase nominal femenina');
Message masculineFeminineNounPhrase = const Message(
    'masculine/feminine noun phrase', 'frase nominal masculina/femenina');
Message masculineFemininePluralNounPhrase = const Message(
    'masculine/feminine plural noun phrase',
    'frase nominal masculina/femenina');
Message masculineNounPhrase =
    const Message('masculine noun phrase', 'frase nominal masculina');
Message masculinePluralNounPhrase =
    const Message('masculine plural phrase', 'frase nominal masculina');
Message masculinePluralNounPhraseParen =
    const Message('masculine (plural) phrase', 'frase nominal masculina');

// Misc.
_CapMessage loading = _CapMessage('loading', 'cargando');
_CapMessage dismiss = _CapMessage('dismiss', 'despedir');
_CapMessage or = _CapMessage('or', 'o');

Message audioPlaybackTimeoutMsg = const Message(
  'Audio playback timed out, check internet connection.',
  'Se agotó el tiempo de reproducción de audio, verifique la conexión a '
      'Internet.',
);
Message invalidEntry = const Message('Invalid entry', 'Entrada inválida');
Message reportBug = const Message('report bug', 'reporte un error');
Message retry = const Message('retry', 'rever');

class Message {
  const Message(this.en, this.es);

  String getFor(bool isSpanish) {
    return isSpanish ? es : en;
  }

  final String en;
  final String es;
}

class _CapMessage extends Message {
  _CapMessage(String english, String spanish, [Message? cap])
      : cap = cap ??
            Message(
              english.capitalizeFirst,
              spanish.capitalizeFirst,
            ),
        super(english, spanish);

  final Message cap;
}
