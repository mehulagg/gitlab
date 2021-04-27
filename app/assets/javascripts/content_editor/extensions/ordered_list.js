import { OrderedList } from '@tiptap/extension-ordered-list';
import { defaultMarkdownSerializer } from 'prosemirror-markdown/src/to_markdown';

export default OrderedList.extend({
  serializer: defaultMarkdownSerializer.nodes.ordered_list,
});
