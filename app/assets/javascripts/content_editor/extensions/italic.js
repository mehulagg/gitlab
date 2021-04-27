import { Italic } from '@tiptap/extension-italic';

export default Italic.extend({
  serializer: { open: '_', close: '_', mixable: true, expelEnclosingWhitespace: true },
});
