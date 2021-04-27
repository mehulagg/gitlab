import { Code } from '@tiptap/extension-code';
import { defaultMarkdownSerializer } from 'prosemirror-markdown/src/to_markdown';

export default Code.extend({
  serializer: defaultMarkdownSerializer.marks.code,
});
