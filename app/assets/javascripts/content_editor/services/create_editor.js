import { Editor } from 'tiptap';
import {
  Bold,
  Italic,
  Code,
  Link,
  Image,
  Heading,
  Blockquote,
  HorizontalRule,
  BulletList,
  OrderedList,
  ListItem,
  CodeBlock,
} from 'tiptap-extensions';

const createEditor = async ({ content, serializer } = {}) => {
  const editor = new Editor({
    extensions: [
      new Bold(),
      new Italic(),
      new Code(),
      new Link(),
      new Image(),
      new Heading({ levels: [1, 2, 3, 4, 5, 6] }),
      new Blockquote(),
      new HorizontalRule(),
      new BulletList(),
      new ListItem(),
      new OrderedList(),
      new CodeBlock(),
    ],
  });

  editor.setSerializedContent = async (serializedContent) => {
    editor.setContent(
      await serializer.deserialize({ schema: editor.schema, content: serializedContent }),
    );
  };

  editor.getSerializedContent = () => {
    return serializer.serialize({ schema: editor.schema, content: editor.getJSON() });
  };

  await editor.setSerializedContent(content);

  return editor;
};

export default createEditor;
