import { PROVIDE_SERIALIZER_OR_RENDERER_ERROR } from '~/content_editor/constants';
import createEditor from '~/content_editor/services/create_editor';
import createMarkdownSerializer from '~/content_editor/services/markdown_serializer';

jest.mock('~/content_editor/services/markdown_serializer');

describe('content_editor/services/create_editor', () => {
  const renderMarkdown = () => true;
  const buildMockSerializer = () => ({
    serialize: jest.fn(),
    deserialize: jest.fn(),
  });
  const spyOnChainOfCommands = (editor, commands = []) => {
    jest.spyOn(editor, 'chain');

    const chainOfCommands = commands.reduce((chain, command) => {
      return Object.assign(chain, {
        [command]: jest.fn(() => chain),
      });
    }, {});

    editor.chain.mockReturnValue(chainOfCommands);
  };
  const assertChainOfCommandsExecution = (editor, commands = []) => {
    expect(editor.chain).toHaveBeenCalled();

    commands.forEach((command) => {
      expect(editor.chain()[command]).toHaveBeenCalled();
    });
  };
  const restoreChainOfCommands = (editor) => {
    editor.chain.mockRestore();
  };

  it('sets gl-outline-0! class selector to editor attributes', async () => {
    const editor = await createEditor({ renderMarkdown });

    expect(editor.options.editorProps).toMatchObject({
      attributes: {
        class: 'gl-outline-0!',
      },
    });
  });

  describe('creating an editor', () => {
    it('uses markdown serializer when a renderMarkdown function is provided', async () => {
      const mockSerializer = buildMockSerializer();
      createMarkdownSerializer.mockReturnValueOnce(mockSerializer);

      await createEditor({ renderMarkdown });

      expect(createMarkdownSerializer).toHaveBeenCalledWith({ render: renderMarkdown });
    });

    it('uses custom serializer when it is provided', async () => {
      const mockSerializer = buildMockSerializer();
      const serializedContent = '**bold**';

      mockSerializer.serialize.mockReturnValueOnce(serializedContent);

      const editor = await createEditor({ serializer: mockSerializer });

      expect(editor.getSerializedContent()).toBe(serializedContent);
    });

    it('throws an error when neither a serializer or renderMarkdown fn are provided', async () => {
      await expect(createEditor()).rejects.toThrow(PROVIDE_SERIALIZER_OR_RENDERER_ERROR);
    });
  });

  describe('toggleContentType', () => {
    it('runs the content type toggle command and focus command', async () => {
      const contentType = 'bold';
      const expectedCommands = ['toggleBold', 'focus', 'run'];
      const editor = await createEditor({ renderMarkdown });

      spyOnChainOfCommands(editor, expectedCommands);
      editor.toggleContentType(contentType);
      assertChainOfCommandsExecution(editor, expectedCommands);
      restoreChainOfCommands(editor, expectedCommands);
    });
  });
});
