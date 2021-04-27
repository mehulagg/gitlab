import { BulletList } from '@tiptap/extension-bullet-list';
import { defaultMarkdownSerializer } from 'prosemirror-markdown/src/to_markdown';

export default BulletList.extend({
  serializer: defaultMarkdownSerializer.nodes.bullet_list,
});
