import { Heading } from '@tiptap/extension-heading';
import { defaultMarkdownSerializer } from 'prosemirror-markdown/src/to_markdown';

export default Heading.extend({
  serializer: defaultMarkdownSerializer.nodes.heading,
});
