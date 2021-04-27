import { HardBreak } from '@tiptap/extension-hard-break';
import { defaultMarkdownSerializer } from 'prosemirror-markdown/src/to_markdown';

export default HardBreak.extend({
  serializer: defaultMarkdownSerializer.nodes.hard_break,
});
