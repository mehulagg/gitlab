import { Editor } from '@tiptap/core';
import Document from '@tiptap/extension-document';
import Dropcursor from '@tiptap/extension-dropcursor';
import Gapcursor from '@tiptap/extension-gapcursor';
import History from '@tiptap/extension-history';
import { isFunction, isString, upperFirst } from 'lodash';
import { PROVIDE_SERIALIZER_OR_RENDERER_ERROR } from '../constants';
import Blockquote from '../extensions/blockquote';
import Bold from '../extensions/bold';
import BulletList from '../extensions/bullet_list';
import Code from '../extensions/code';
import CodeBlockHighlight from '../extensions/code_block_highlight';
import HardBreak from '../extensions/hard_break';
import Heading from '../extensions/heading';
import HorizontalRule from '../extensions/horizontal_rule';
import Image from '../extensions/image';
import Italic from '../extensions/italic';
import Link from '../extensions/link';
import ListItem from '../extensions/list_item';
import OrderedList from '../extensions/ordered_list';
import Paragraph from '../extensions/paragraph';
import Text from '../extensions/text';
import markdownSerializer from './markdown_serializer';

const createSerializerSpecs = (editorExtensions) => {
  return editorExtensions
    .filter(({ config }) => config.serializer)
    .reduce(
      (serializers, { name, type, config: { serializer } }) => {
        const collection = `${type}s`;

        return {
          ...serializers,
          [collection]: {
            ...serializers[collection],
            [name]: serializer,
          },
        };
      },
      {
        nodes: {},
        marks: {},
      },
    );
};

const createEditor = async ({
  content,
  renderMarkdown,
  serializer: customSerializer,
  ...options
} = {}) => {
  if (!customSerializer && !isFunction(renderMarkdown)) {
    throw new Error(PROVIDE_SERIALIZER_OR_RENDERER_ERROR);
  }

  const extensions = [
    Dropcursor,
    Gapcursor,
    History,
    Document,
    Text,
    HardBreak,
    Paragraph,
    Bold,
    Italic,
    Code,
    Link,
    Heading,
    BulletList,
    OrderedList,
    ListItem,
    Blockquote,
    HorizontalRule,
    Image,
    CodeBlockHighlight,
  ];
  const editor = new Editor({
    extensions,
    editorProps: {
      attributes: {
        class: 'gl-outline-0!',
      },
    },
    ...options,
  });
  const serializer = customSerializer || markdownSerializer({ render: renderMarkdown });
  const serializerSpec = createSerializerSpecs(extensions);

  Object.assign(editor, {
    toggleContentType: (contentTypeName) => {
      const commandName = `toggle${upperFirst(contentTypeName)}`;

      editor.chain()[commandName]().focus().run();
    },
    setSerializedContent: async (serializedContent) => {
      editor.commands.setContent(
        await serializer.deserialize({
          schema: editor.schema,
          content: serializedContent,
        }),
      );
    },
    getSerializedContent: () => {
      return serializer.serialize({
        serializerSpec,
        schema: editor.schema,
        content: editor.getJSON(),
      });
    },
  });

  if (isString(content)) {
    await editor.setSerializedContent(content);
  }

  return editor;
};

export default createEditor;
