import { CodeBlockLowlight } from '@tiptap/extension-code-block-lowlight';
import { defaultMarkdownSerializer } from 'prosemirror-markdown/src/to_markdown';

const extractLanguage = (element) => element.firstElementChild?.getAttribute('lang');

export default CodeBlockLowlight.extend({
  addAttributes() {
    return {
      language: {
        default: null,
        parseHTML: (element) => {
          return {
            language: extractLanguage(element),
          };
        },
        renderHTML: (attributes) => {
          if (!attributes.language) {
            return null;
          }

          return {
            class: this.options.languageClassPrefix + attributes.language,
          };
        },
      },
      params: {
        parseHTML: (element) => {
          return {
            params: extractLanguage(element),
          };
        },
      },
    };
  },
  serializer: defaultMarkdownSerializer.nodes.code_block,
});
