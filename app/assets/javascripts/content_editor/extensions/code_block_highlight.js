import { CodeBlockLowlight } from '@tiptap/extension-code-block-lowlight';
import * as lowlight from 'lowlight';
import { defaultMarkdownSerializer } from 'prosemirror-markdown/src/to_markdown';

const extractLanguage = (element) => element.getAttribute('lang');

const ExtendedCodeBlockLowlight = CodeBlockLowlight.extend({
  addAttributes() {
    return {
      language: {
        default: null,
        parseHTML: (element) => {
          return {
            language: extractLanguage(element),
          };
        },
      },
      /* `params` is the name of the attribute that
        prosemirror-markdown uses to extract the language
        of a codeblock.
        https://github.com/ProseMirror/prosemirror-markdown/blob/master/src/to_markdown.js#L62
      */
      params: {
        parseHTML: (element) => {
          return {
            params: extractLanguage(element),
          };
        },
      },
      class: {
        default: 'code highlight js-syntax-highlight',
      },
    };
  },
  addCommands() {
    return {
      ...this.parent?.(),
      toggleCodeBlockAndAppendParagraph: () => ({ chain }) => {
        const { $from } = this.editor.state.selection;
        const chainedCommands = chain();
        const isLastChild = this.editor.state.doc.lastChild === $from.parent;

        chainedCommands.toggleCodeBlock();

        if (isLastChild) {
          chainedCommands
            .insertContent({ type: 'paragraph', content: [] })
            .setTextSelection($from.pos);
        }
      },
    };
  },
  addKeyboardShortcuts() {
    return {
      ...this.parent?.(),
      'Mod-Alt-c': () => this.editor.commands.toggleCodeBlockAndAppendParagraph(),
    };
  },
  renderHTML({ HTMLAttributes }) {
    return ['pre', HTMLAttributes, ['code', {}, 0]];
  },
}).configure({
  lowlight,
});

export const tiptapExtension = ExtendedCodeBlockLowlight;
export const serializer = defaultMarkdownSerializer.nodes.code_block;
