/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See https://github.com/microsoft/monaco-languages/blob/master/LICENSE.md
 *--------------------------------------------------------------------------------------------*/

// Based on handlebars template in https://github.com/microsoft/monaco-languages/blob/master/src/handlebars/handlebars.ts
// Look for "vuejs template attributes" in this file for Vue specific syntax.

import { languages } from 'monaco-editor';

/* eslint-disable no-useless-escape */
/* eslint-disable @gitlab/require-i18n-strings */

const EMPTY_ELEMENTS = [
  'area',
  'base',
  'br',
  'col',
  'embed',
  'hr',
  'img',
  'input',
  'keygen',
  'link',
  'menuitem',
  'meta',
  'param',
  'source',
  'track',
  'wbr',
];

const conf = {
  wordPattern: /(-?\d*\.\d\w*)|([^\`\~\!\@\$\^\&\*\(\)\=\+\[\{\]\}\\\|\;\:\'\"\,\.\<\>\/\s]+)/g,

  comments: {
    blockComment: ['{{!--', '--}}'],
  },

  brackets: [['<!--', '-->'], ['<', '>'], ['{{', '}}'], ['{', '}'], ['(', ')']],

  autoClosingPairs: [
    { open: '{', close: '}' },
    { open: '[', close: ']' },
    { open: '(', close: ')' },
    { open: '"', close: '"' },
    { open: "'", close: "'" },
  ],

  surroundingPairs: [
    { open: '<', close: '>' },
    { open: '"', close: '"' },
    { open: "'", close: "'" },
  ],

  onEnterRules: [
    {
      beforeText: new RegExp(
        `<(?!(?:${EMPTY_ELEMENTS.join('|')}))(\\w[\\w\\d]*)([^/>]*(?!/)>)[^<]*$`,
        'i',
      ),
      afterText: /^<\/(\w[\w\d]*)\s*>$/i,
      action: { indentAction: languages.IndentAction.IndentOutdent },
    },
    {
      beforeText: new RegExp(
        `<(?!(?:${EMPTY_ELEMENTS.join('|')}))(\\w[\\w\\d]*)([^/>]*(?!/)>)[^<]*$`,
        'i',
      ),
      action: { indentAction: languages.IndentAction.Indent },
    },
  ],
};

const language = {
  defaultToken: '',
  tokenPostfix: '',
  // ignoreCase: true,

  // The main tokenizer for our languages
  tokenizer: {
    root: [
      [/\{\{/, { token: '@rematch', switchTo: '@handlebarsInSimpleState.root' }],
      [/<!DOCTYPE/, 'metatag.html', '@doctype'],
      [/<!--/, 'comment.html', '@comment'],
      [/(<)([\w]+)(\/>)/, ['delimiter.html', 'tag.html', 'delimiter.html']],
      [/(<)(script)/, ['delimiter.html', { token: 'tag.html', next: '@script' }]],
      [/(<)(style)/, ['delimiter.html', { token: 'tag.html', next: '@style' }]],
      [/(<)([:\w]+)/, ['delimiter.html', { token: 'tag.html', next: '@otherTag' }]],
      [/(<\/)([\w]+)/, ['delimiter.html', { token: 'tag.html', next: '@otherTag' }]],
      [/</, 'delimiter.html'],
      [/\{/, 'delimiter.html'],
      [/[^<{]+/], // text
    ],

    doctype: [
      [/\{\{/, { token: '@rematch', switchTo: '@handlebarsInSimpleState.comment' }],
      [/[^>]+/, 'metatag.content.html'],
      [/>/, 'metatag.html', '@pop'],
    ],

    comment: [
      [/\{\{/, { token: '@rematch', switchTo: '@handlebarsInSimpleState.comment' }],
      [/-->/, 'comment.html', '@pop'],
      [/[^-]+/, 'comment.content.html'],
      [/./, 'comment.content.html'],
    ],

    otherTag: [
      [/\{\{/, { token: '@rematch', switchTo: '@handlebarsInSimpleState.otherTag' }],
      [/\/?>/, 'delimiter.html', '@pop'],

      // -- BEGIN vuejs template attributes
      [/(v-|@|:)[\w\-\.\:\[\]]+="([^"]*)"/, 'variable'],
      [/(v-|@|:)[\w\-\.\:\[\]]+='([^']*)'/, 'variable'],

      [/"([^"]*)"/, 'attribute.value'],
      [/'([^']*)'/, 'attribute.value'],

      [/[\w\-\.\:\[\]]+/, 'attribute.name'],
      // -- END vuejs template attributes

      [/=/, 'delimiter'],
      [/[ \t\r\n]+/], // whitespace
    ],

    // -- BEGIN <script> tags handling

    // After <script
    script: [
      [/\{\{/, { token: '@rematch', switchTo: '@handlebarsInSimpleState.script' }],
      [/type/, 'attribute.name', '@scriptAfterType'],
      [/"([^"]*)"/, 'attribute.value'],
      [/'([^']*)'/, 'attribute.value'],
      [/[\w\-]+/, 'attribute.name'],
      [/=/, 'delimiter'],
      [
        />/,
        {
          token: 'delimiter.html',
          next: '@scriptEmbedded.text/javascript',
          nextEmbedded: 'text/javascript',
        },
      ],
      [/[ \t\r\n]+/], // whitespace
      [
        /(<\/)(script\s*)(>)/,
        ['delimiter.html', 'tag.html', { token: 'delimiter.html', next: '@pop' }],
      ],
    ],

    // After <script ... type
    scriptAfterType: [
      [/\{\{/, { token: '@rematch', switchTo: '@handlebarsInSimpleState.scriptAfterType' }],
      [/=/, 'delimiter', '@scriptAfterTypeEquals'],
      [
        />/,
        {
          token: 'delimiter.html',
          next: '@scriptEmbedded.text/javascript',
          nextEmbedded: 'text/javascript',
        },
      ], // cover invalid e.g. <script type>
      [/[ \t\r\n]+/], // whitespace
      [/<\/script\s*>/, { token: '@rematch', next: '@pop' }],
    ],

    // After <script ... type =
    scriptAfterTypeEquals: [
      [/\{\{/, { token: '@rematch', switchTo: '@handlebarsInSimpleState.scriptAfterTypeEquals' }],
      [/"([^"]*)"/, { token: 'attribute.value', switchTo: '@scriptWithCustomType.$1' }],
      [/'([^']*)'/, { token: 'attribute.value', switchTo: '@scriptWithCustomType.$1' }],
      [
        />/,
        {
          token: 'delimiter.html',
          next: '@scriptEmbedded.text/javascript',
          nextEmbedded: 'text/javascript',
        },
      ], // cover invalid e.g. <script type=>
      [/[ \t\r\n]+/], // whitespace
      [/<\/script\s*>/, { token: '@rematch', next: '@pop' }],
    ],

    // After <script ... type = $S2
    scriptWithCustomType: [
      [
        /\{\{/,
        { token: '@rematch', switchTo: '@handlebarsInSimpleState.scriptWithCustomType.$S2' },
      ],
      [/>/, { token: 'delimiter.html', next: '@scriptEmbedded.$S2', nextEmbedded: '$S2' }],
      [/"([^"]*)"/, 'attribute.value'],
      [/'([^']*)'/, 'attribute.value'],
      [/[\w\-]+/, 'attribute.name'],
      [/=/, 'delimiter'],
      [/[ \t\r\n]+/], // whitespace
      [/<\/script\s*>/, { token: '@rematch', next: '@pop' }],
    ],

    scriptEmbedded: [
      [
        /\{\{/,
        {
          token: '@rematch',
          switchTo: '@handlebarsInEmbeddedState.scriptEmbedded.$S2',
          nextEmbedded: '@pop',
        },
      ],
      [/<\/script/, { token: '@rematch', next: '@pop', nextEmbedded: '@pop' }],
    ],

    // -- END <script> tags handling

    // -- BEGIN <style> tags handling

    // After <style
    style: [
      [/\{\{/, { token: '@rematch', switchTo: '@handlebarsInSimpleState.style' }],
      [/type/, 'attribute.name', '@styleAfterType'],
      [/"([^"]*)"/, 'attribute.value'],
      [/'([^']*)'/, 'attribute.value'],
      [/[\w\-]+/, 'attribute.name'],
      [/=/, 'delimiter'],
      [/>/, { token: 'delimiter.html', next: '@styleEmbedded.text/css', nextEmbedded: 'text/css' }],
      [/[ \t\r\n]+/], // whitespace
      [
        /(<\/)(style\s*)(>)/,
        ['delimiter.html', 'tag.html', { token: 'delimiter.html', next: '@pop' }],
      ],
    ],

    // After <style ... type
    styleAfterType: [
      [/\{\{/, { token: '@rematch', switchTo: '@handlebarsInSimpleState.styleAfterType' }],
      [/=/, 'delimiter', '@styleAfterTypeEquals'],
      [/>/, { token: 'delimiter.html', next: '@styleEmbedded.text/css', nextEmbedded: 'text/css' }], // cover invalid e.g. <style type>
      [/[ \t\r\n]+/], // whitespace
      [/<\/style\s*>/, { token: '@rematch', next: '@pop' }],
    ],

    // After <style ... type =
    styleAfterTypeEquals: [
      [/\{\{/, { token: '@rematch', switchTo: '@handlebarsInSimpleState.styleAfterTypeEquals' }],
      [/"([^"]*)"/, { token: 'attribute.value', switchTo: '@styleWithCustomType.$1' }],
      [/'([^']*)'/, { token: 'attribute.value', switchTo: '@styleWithCustomType.$1' }],
      [/>/, { token: 'delimiter.html', next: '@styleEmbedded.text/css', nextEmbedded: 'text/css' }], // cover invalid e.g. <style type=>
      [/[ \t\r\n]+/], // whitespace
      [/<\/style\s*>/, { token: '@rematch', next: '@pop' }],
    ],

    // After <style ... type = $S2
    styleWithCustomType: [
      [/\{\{/, { token: '@rematch', switchTo: '@handlebarsInSimpleState.styleWithCustomType.$S2' }],
      [/>/, { token: 'delimiter.html', next: '@styleEmbedded.$S2', nextEmbedded: '$S2' }],
      [/"([^"]*)"/, 'attribute.value'],
      [/'([^']*)'/, 'attribute.value'],
      [/[\w\-]+/, 'attribute.name'],
      [/=/, 'delimiter'],
      [/[ \t\r\n]+/], // whitespace
      [/<\/style\s*>/, { token: '@rematch', next: '@pop' }],
    ],

    styleEmbedded: [
      [
        /\{\{/,
        {
          token: '@rematch',
          switchTo: '@handlebarsInEmbeddedState.styleEmbedded.$S2',
          nextEmbedded: '@pop',
        },
      ],
      [/<\/style/, { token: '@rematch', next: '@pop', nextEmbedded: '@pop' }],
    ],

    // -- END <style> tags handling

    handlebarsInSimpleState: [
      [/\{\{\{?/, 'delimiter.handlebars'],
      [/\}\}\}?/, { token: 'delimiter.handlebars', switchTo: '@$S2.$S3' }],
      { include: 'handlebarsRoot' },
    ],

    handlebarsInEmbeddedState: [
      [/\{\{\{?/, 'delimiter.handlebars'],
      [/\}\}\}?/, { token: 'delimiter.handlebars', switchTo: '@$S2.$S3', nextEmbedded: '$S3' }],
      { include: 'handlebarsRoot' },
    ],

    handlebarsRoot: [
      [/"[^"]*"/, 'string.handlebars'],
      [/[#/][^\s}]+/, 'keyword.helper.handlebars'],
      [/else\b/, 'keyword.helper.handlebars'],
      [/[\s]+/],
      [/[^}]/, 'variable.parameter.handlebars'],
    ],
  },
};

export default {
  id: 'vue',
  extensions: ['.vue'],
  aliases: ['Vue', 'vue'],
  mimetypes: ['text/x-vue-template'],
  conf,
  language,
};
