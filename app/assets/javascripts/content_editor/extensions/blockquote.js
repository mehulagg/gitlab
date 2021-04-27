import { Blockquote } from '@tiptap/extension-blockquote';
import { defaultMarkdownSerializer } from 'prosemirror-markdown/src/to_markdown';

export default Blockquote.extend({
  serializer: defaultMarkdownSerializer.nodes.blockquote,
});
