import { Text } from '@tiptap/extension-text';
import { defaultMarkdownSerializer } from 'prosemirror-markdown/src/to_markdown';

export default Text.extend({
  serializer: defaultMarkdownSerializer.nodes.text,
});
