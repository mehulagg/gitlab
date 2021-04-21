import Link from '@tiptap/extension-link';
import { defaultExtensions as createDefaultExtensions } from '@tiptap/starter-kit';
import { Editor } from '@tiptap/vue-2';
import { isFunction, isString } from 'lodash';
import { PROVIDE_SERIALIZER_OR_RENDERER_ERROR } from '../constants';
import CodeBlockHighlight from '../extensions/code_block_highlight';
import Image from '../extensions/image';
import createMarkdownSerializer from './markdown_serializer';

const createEditor = async ({ content, renderMarkdown, serializer: customSerializer } = {}) => {
  if (!customSerializer && !isFunction(renderMarkdown)) {
    throw new Error(PROVIDE_SERIALIZER_OR_RENDERER_ERROR);
  }

  /**
   * TipTap default extensions provide support for the following
   * Commonmark content types:
   *
   * Text
   * Paragraph
   * Bold
   * Italic
   * Code
   * CodeBlock
   * Heading
   * HardBreak
   * Strike
   * Blockquote
   * HorizontalRule
   * BulletList
   * OrderedList
   */
  const defaultExtensions = createDefaultExtensions();
  const editor = new Editor({
    extensions: [...defaultExtensions, Link, Image, CodeBlockHighlight],
    editorProps: {
      attributes: {
        /*
         * Adds some padding to the contenteditable element where the user types.
         * Otherwise, the text cursor is not visible when its position is at the
         * beginning of a line.
         */
        class: 'gl-py-4 gl-px-5',
      },
    },
  });
  const serializer = customSerializer || createMarkdownSerializer({ render: renderMarkdown });

  editor.setSerializedContent = async (serializedContent) => {
    editor.commands.setContent(
      await serializer.deserialize({ schema: editor.schema, content: serializedContent }),
    );
  };

  editor.getSerializedContent = () => {
    return serializer.serialize({ schema: editor.schema, content: editor.getJSON() });
  };

  if (isString(content)) {
    await editor.setSerializedContent(content);
  }

  return editor;
};

export default createEditor;
