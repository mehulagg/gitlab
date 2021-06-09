import { markInputRule } from '@tiptap/core';
import { Link } from '@tiptap/extension-link';
import { defaultMarkdownSerializer } from 'prosemirror-markdown/src/to_markdown';

const insertLinkInputRuleRegExp = /(?:^|\s)\[([\w|\s|-]+)\]\(.+?\)$/gm;

export const tiptapExtension = Link
  .extend({
    addInputRules() {
      return [
        markInputRule(insertLinkInputRuleRegExp, this.type, (match) => {
          const extractHrefRegExp = /\[([\w|\s|-]+)\]\((?<href>.+?)\)$/gm;

          return extractHrefRegExp.exec(match[0]).groups;
        }),
      ];
    }
  })
  .configure({
    openOnClick: false,
  });

export const serializer = defaultMarkdownSerializer.marks.link;
