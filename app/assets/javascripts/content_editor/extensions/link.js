import { Link } from '@tiptap/extension-link';
import { defaultMarkdownSerializer } from 'prosemirror-markdown/src/to_markdown';

export default Link.extend({
  serializer: defaultMarkdownSerializer.marks.link,
});
