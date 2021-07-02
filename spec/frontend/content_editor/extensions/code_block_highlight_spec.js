import { tiptapExtension as CodeBlockHighlight } from '~/content_editor/extensions/code_block_highlight';
import { loadMarkdownApiResult } from '../markdown_processing_examples';
import { createTestEditor, createDocBuilder } from '../test_utils';

describe('content_editor/extensions/code_block_highlight', () => {
  let codeBlockHtmlFixture;
  let parsedCodeBlockHtmlFixture;
  let tiptapEditor;
  let builders;
  let eq;

  const parseHTML = (html) => new DOMParser().parseFromString(html, 'text/html');
  const preElement = () => parsedCodeBlockHtmlFixture.querySelector('pre');

  beforeEach(() => {
    const { html } = loadMarkdownApiResult('code_block');

    tiptapEditor = createTestEditor({ extensions: [CodeBlockHighlight] });
    codeBlockHtmlFixture = html;
    parsedCodeBlockHtmlFixture = parseHTML(codeBlockHtmlFixture);

    ({ builders, eq } = createDocBuilder({
      tiptapEditor,
      names: { code: { nodeType: CodeBlockHighlight.name } },
    }));

    tiptapEditor.commands.setContent(codeBlockHtmlFixture);
  });

  it('extracts language and params attributes from Markdown API output', () => {
    const language = preElement().getAttribute('lang');

    expect(tiptapEditor.getJSON().content[0].attrs).toMatchObject({
      language,
      params: language,
    });
  });

  it('adds code, highlight, and js-syntax-highlight to code block element', () => {
    const editorHtmlOutput = parseHTML(tiptapEditor.getHTML()).querySelector('pre');

    expect(editorHtmlOutput.classList.toString()).toContain('code highlight js-syntax-highlight');
  });

  describe('insertOrToggleCodeBlock command', () => {
    let doc;
    let p;
    let codeBlock;

    beforeEach(() => {
      ({ doc, p, codeBlock } = builders);
    });
    describe('when node is last node', () => {
      it('appends an empty paragraph to the node converted into code block', () => {
        const initialDoc = doc(p(''));
        const expectedDoc = doc(codeBlock(), p(''));

        tiptapEditor.commands.setContent(initialDoc.toJSON());
        tiptapEditor.commands.toggleCodeBlockAndAppendParagraph();

        expect(eq(tiptapEditor.state.doc, expectedDoc)).toBe(true);
      });
    });

    describe('when node is not last node', () => {
      it('does not an empty paragraph', () => {
        const text = 'This is text';
        const initialDoc = doc(p(text), p(''));
        const expectedDoc = doc(codeBlock(text), p(''));

        tiptapEditor.commands.setContent(initialDoc.toJSON());
        tiptapEditor.commands.setTextSelection(1);
        tiptapEditor.commands.toggleCodeBlockAndAppendParagraph();

        expect(eq(tiptapEditor.state.doc, expectedDoc)).toBe(true);
      });
    });
  });
});
