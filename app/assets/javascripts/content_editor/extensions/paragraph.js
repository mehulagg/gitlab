import { Paragraph } from '@tiptap/extension-paragraph';
import { defaultMarkdownSerializer } from 'prosemirror-markdown/src/to_markdown';

export default Paragraph.extend({
  serializer: defaultMarkdownSerializer.nodes.paragraph,
});
