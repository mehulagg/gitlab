/* eslint-disable class-methods-use-this */

import { defaultMarkdownSerializer } from 'prosemirror-markdown';
import { Mark } from 'tiptap';
import { HIGHER_PARSE_RULE_PRIORITY } from '../constants';

// Transforms generated HTML back to GFM for Banzai::Filter::MathFilter
export default class MathMark extends Mark {
  get name() {
    return 'math';
  }

  get schema() {
    return {
      parseDOM: [
        // Matches HTML generated by Banzai::Filter::MathFilter
        {
          tag: 'code.code.math[data-math-style=inline]',
          priority: HIGHER_PARSE_RULE_PRIORITY,
        },
        // Matches HTML after being transformed by app/assets/javascripts/behaviors/markdown/render_math.js
        {
          tag: 'span.katex',
          contentElement: 'annotation[encoding="application/x-tex"]',
        },
      ],
      toDOM: () => ['code', { class: 'code math', 'data-math-style': 'inline' }, 0],
    };
  }

  get toMarkdown() {
    return {
      escape: false,
      open(state, mark, parent, index) {
        return `$${defaultMarkdownSerializer.marks.code.open(state, mark, parent, index)}`;
      },
      close(state, mark, parent, index) {
        return `${defaultMarkdownSerializer.marks.code.close(state, mark, parent, index)}$`;
      },
    };
  }
}
