import { Image } from '@tiptap/extension-image';
import { defaultMarkdownSerializer } from 'prosemirror-markdown/src/to_markdown';

export default Image.extend({
  defaultOptions: { inline: true },
  serializer: defaultMarkdownSerializer.nodes.image,
});
