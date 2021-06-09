import { tiptapExtension as Link } from '~/content_editor/extensions/link';
import { createTestEditor } from '../test_utils';

describe('content_editor/extensions/link', () => {
  let tiptapEditor;

  beforeEach(() => {
    tiptapEditor = createTestEditor({ extensions: [Link] });
  });

  it.each`
    input
    ${'[gitlab](https://gitlab.com)'}
  `('creates a link when the input rule matches $input', ({ input }) => {
    const { view } = tiptapEditor;
    const { selection } = view.state;

    tiptapEditor.chain().insertContent(input).run();

    /**
     * Calls the event handler that executes the input rule
     * https://github.com/ProseMirror/prosemirror-inputrules/blob/master/src/inputrules.js#L65
     * */
    view.someProp('handleTextInput', (f) => f(view, selection.from, selection.to, input));

    const serializedDoc = tiptapEditor.getJSON();

    console.log(serializedDoc.content[0].content[0])
  });
});
