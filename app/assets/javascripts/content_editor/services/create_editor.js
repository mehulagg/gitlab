import { Editor } from '@tiptap/core';
import Blockquote from '@tiptap/extension-blockquote';
import Bold from '@tiptap/extension-bold';
import BulletList from '@tiptap/extension-bullet-list';
import Code from '@tiptap/extension-code';
import Document from '@tiptap/extension-document';
import Dropcursor from '@tiptap/extension-dropcursor';
import Gapcursor from '@tiptap/extension-gapcursor';
import HardBreak from '@tiptap/extension-hard-break';
import Heading from '@tiptap/extension-heading';
import History from '@tiptap/extension-history';
import HorizontalRule from '@tiptap/extension-horizontal-rule';
import Image from '@tiptap/extension-image';
import Italic from '@tiptap/extension-italic';
import Link from '@tiptap/extension-link';
import ListItem from '@tiptap/extension-list-item';
import OrderedList from '@tiptap/extension-ordered-list';
import Paragraph from '@tiptap/extension-paragraph';
import Strike from '@tiptap/extension-strike';
import Text from '@tiptap/extension-text';
import { isFunction, isString, upperFirst } from 'lodash';
import { PROVIDE_SERIALIZER_OR_RENDERER_ERROR } from '../constants';
import CodeBlockHighlight from '../extensions/code_block_highlight';
import createMarkdownSerializer from './markdown_serializer';

const createEditor = async ({
  content,
  renderMarkdown,
  serializer: customSerializer,
  ...options
} = {}) => {
  if (!customSerializer && !isFunction(renderMarkdown)) {
    throw new Error(PROVIDE_SERIALIZER_OR_RENDERER_ERROR);
  }

  const editor = new Editor({
    extensions: [
      Dropcursor,
      Gapcursor,
      History,
      Document,
      Text,
      Paragraph,
      Bold,
      Italic,
      Code,
      Link,
      Heading,
      HardBreak,
      Strike,
      Blockquote,
      HorizontalRule,
      BulletList,
      OrderedList,
      ListItem,
      Image.configure({ inline: true }),
      CodeBlockHighlight,
    ],
    editorProps: {
      attributes: {
        class: 'gl-outline-0!',
      },
    },
    ...options,
  });
  const serializer = customSerializer || createMarkdownSerializer({ render: renderMarkdown });

  Object.assign(editor, {
    toggleContentType: (contentTypeName) => {
      const commandName = `toggle${upperFirst(contentTypeName)}`;

      editor.chain()[commandName]().focus().run();
    },
    setSerializedContent: async (serializedContent) => {
      editor.commands.setContent(
        await serializer.deserialize({ schema: editor.schema, content: serializedContent }),
      );
    },
    getSerializedContent: () => {
      return serializer.serialize({ schema: editor.schema, content: editor.getJSON() });
    },
  });

  if (isString(content)) {
    await editor.setSerializedContent(content);
  }

  return editor;
};

export default createEditor;
