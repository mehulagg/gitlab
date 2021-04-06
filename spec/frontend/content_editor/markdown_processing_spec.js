import { createEditor, createMarkdownSerializer } from '~/content_editor';
import { loadMarkdownApiExamples, loadMarkdownApiResult } from './markdown_processing_examples';

describe('markdown processing', () => {
  // Ensure we generate same markdown that was provided to Markdown API.
  it.each(loadMarkdownApiExamples())('correctly handles %s', async (testName, markdown) => {
    const { html } = loadMarkdownApiResult(testName);
    const serializer = createMarkdownSerializer({ render: () => html });
    const editor = await createEditor({ content: markdown, serializer });

    expect(editor.getSerializedContent()).toBe(markdown);
  });
});
