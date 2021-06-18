import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:rogers_dictionary/util/string_utils.dart';

//  Localization for DictionaryPage.
_CapMessage english = _CapMessage('english', 'inglés');
_CapMessage spanish = _CapMessage('spanish', 'español');

_CapMessage dictionary = _CapMessage('dictionary', 'diccionario');
_CapMessage favorites = _CapMessage('favorites', 'favoritos');
_CapMessage dialogues = _CapMessage('dialogues', 'diálogos');

// Localization for EntryList.
_CapMessage search = _CapMessage('search', 'buscar');
_Message enterTextHint = _Message(
    'Enter text above to search for a translation!',
    '¡Ingrese el texto arriba para buscar una traducción!');
_Message noFavoritesHint = _Message(
    'No results! Try favoriting an entry first.',
    '¡No hay resultados! Primero, intenta marcar una entrada como favorita.');
_Message typosHint = _Message('No results! Check for typos.',
    '¡No hay resultados! Compruebe si hay errores tipográficos.');
_Message swipeLeft = _Message('Or swipe left for spanish mode.',
    'O desliza el dedo hacia la izquierda para al modo español.');
_Message swipeRight = _Message('Or swipe right for english mode.',
    'O deslice hacia la derecha para al modo inglés.');

// Localization for the help menu.
_Message giveFeedback = _Message('give feedback', 'dar opinion');
_Message aboutThisApp = _Message('about this app', 'acerca de esta aplicación');

// Localization for getting feedback.
_CapMessage feedback = _CapMessage('feedback', 'comentarios');
_CapMessage feedbackType = _CapMessage('feedback type', 'tipo de comentarios');
_CapMessage summary = _CapMessage('summary', 'resumen');
_CapMessage submit = _CapMessage('submit', 'enviar');
_Message opensEmail = _Message(
    '(opens your email app)', '(abre tu aplicación de correo electrónico)');

_CapMessage translationError =
    _CapMessage('translation error', 'error de traducción');
_CapMessage bugReport = _CapMessage('bug report', 'informe de error');
_CapMessage featureRequest =
    _CapMessage('feature request', 'solicitud de función');
_CapMessage other = _CapMessage('other', 'otro');

// Misc.
_CapMessage loading = _CapMessage('loading', 'cargando');

class _Message {
  _Message(this._en, this._es);

  String get(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'es' ? _es : _en;
  }

  final String _en;
  final String _es;
}

class _CapMessage extends _Message {
  _CapMessage(String english, String spanish, [_Message? cap])
      : cap = cap ??
            _Message(
              english.capitalizeFirst,
              spanish.capitalizeFirst,
            ),
        super(english, spanish);

  final _Message cap;
}
