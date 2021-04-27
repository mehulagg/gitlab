import { HorizontalRule } from '@tiptap/extension-horizontal-rule';
import { defaultMarkdownSerializer } from 'prosemirror-markdown/src/to_markdown';

export default HorizontalRule.extend({
  serializer: defaultMarkdownSerializer.nodes.horizontal_rule,
});
