import { ListItem } from '@tiptap/extension-list-item';
import { defaultMarkdownSerializer } from 'prosemirror-markdown/src/to_markdown';

export default ListItem.extend({
  serializer: defaultMarkdownSerializer.nodes.list_item,
});
