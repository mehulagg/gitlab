import { insertMarkdownText } from '~/lib/utils/text_markdown';

describe('init markdown', () => {
  let textArea;

  beforeAll(() => {
    textArea = document.createElement('textarea');
    document.querySelector('body').appendChild(textArea);
    textArea.focus();
  });

  afterAll(() => {
    textArea.parentNode.removeChild(textArea);
  });

  describe('without selection', () => {
    it('inserts the tag on an empty line', () => {
      const initialValue = '';

      textArea.value = initialValue;
      textArea.selectionStart = 0;
      textArea.selectionEnd = 0;

      insertMarkdownText({
        textArea,
        text: textArea.value,
        tag: '*',
        blockTag: null,
        selected: '',
        wrap: false,
      });

      expect(textArea.value).toEqual(`${initialValue}* `);
    });

    it('inserts the tag on a new line if the current one is not empty', () => {
      const initialValue = 'some text';

      textArea.value = initialValue;
      textArea.setSelectionRange(initialValue.length, initialValue.length);

      insertMarkdownText({
        textArea,
        text: textArea.value,
        tag: '*',
        blockTag: null,
        selected: '',
        wrap: false,
      });

      expect(textArea.value).toEqual(`${initialValue}\n* `);
    });

    it('inserts the tag on the same line if the current line only contains spaces', () => {
      const initialValue = '  ';

      textArea.value = initialValue;
      textArea.setSelectionRange(initialValue.length, initialValue.length);

      insertMarkdownText({
        textArea,
        text: textArea.value,
        tag: '*',
        blockTag: null,
        selected: '',
        wrap: false,
      });

      expect(textArea.value).toEqual(`${initialValue}* `);
    });

    it('inserts the tag on the same line if the current line only contains tabs', () => {
      const initialValue = '\t\t\t';

      textArea.value = initialValue;
      textArea.setSelectionRange(initialValue.length, initialValue.length);

      insertMarkdownText({
        textArea,
        text: textArea.value,
        tag: '*',
        blockTag: null,
        selected: '',
        wrap: false,
      });

      expect(textArea.value).toEqual(`${initialValue}* `);
    });
  });

  describe('with selection', () => {
    const text = 'initial selected value';
    const selected = 'selected';
    beforeEach(() => {
      textArea.value = text;
      const selectedIndex = text.indexOf(selected);
      textArea.setSelectionRange(selectedIndex, selectedIndex + selected.length);
    });

    it('applies the tag to the selected value', () => {
      insertMarkdownText({
        textArea,
        text: textArea.value,
        tag: '*',
        blockTag: null,
        selected,
        wrap: true,
      });

      expect(textArea.value).toEqual(text.replace(selected, `*${selected}*`));
    });

    it('replaces the placeholder in the tag', () => {
      insertMarkdownText({
        textArea,
        text: textArea.value,
        tag: '[{text}](url)',
        blockTag: null,
        selected,
        wrap: false,
      });

      expect(textArea.value).toEqual(text.replace(selected, `[${selected}](url)`));
    });

    describe('and text to be selected', () => {
      const tag = '[{text}](url)';
      const select = 'url';

      it('selects the text', () => {
        insertMarkdownText({
          textArea,
          text: textArea.value,
          tag,
          blockTag: null,
          selected,
          wrap: false,
          select,
        });

        const expectedText = text.replace(selected, `[${selected}](url)`);

        expect(textArea.value).toEqual(expectedText);
        expect(textArea.selectionStart).toEqual(expectedText.indexOf(select));
        expect(textArea.selectionEnd).toEqual(expectedText.indexOf(select) + select.length);
      });

      it('selects the right text when multiple tags are present', () => {
        const initialValue = `${tag} ${tag} ${selected}`;
        textArea.value = initialValue;
        const selectedIndex = initialValue.indexOf(selected);
        textArea.setSelectionRange(selectedIndex, selectedIndex + selected.length);
        insertMarkdownText({
          textArea,
          text: textArea.value,
          tag,
          blockTag: null,
          selected,
          wrap: false,
          select,
        });

        const expectedText = initialValue.replace(selected, `[${selected}](url)`);

        expect(textArea.value).toEqual(expectedText);
        expect(textArea.selectionStart).toEqual(expectedText.lastIndexOf(select));
        expect(textArea.selectionEnd).toEqual(expectedText.lastIndexOf(select) + select.length);
      });
    });
  });
});
