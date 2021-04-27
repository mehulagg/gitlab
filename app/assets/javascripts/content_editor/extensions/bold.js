import { Bold } from '@tiptap/extension-bold';
import { defaultMarkdownSerializer } from 'prosemirror-markdown/src/to_markdown';

export default Bold.extend({
  serializer: defaultMarkdownSerializer.marks.strong,
});
