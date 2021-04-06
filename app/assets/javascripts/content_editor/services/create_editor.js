import { Editor } from 'tiptap';
import { Bold, Code } from 'tiptap-extensions';

const createEditor = async ({ content, serializer } = {}) => {
  const editor = new Editor({
    extensions: [new Bold(), new Code()],
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
