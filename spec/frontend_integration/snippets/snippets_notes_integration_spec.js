import { screen } from '@testing-library/dom';
import initGFMInput from '~/behaviors/markdown/gfm_auto_complete';
import initNotes from '~/init_notes';

describe('integration Snippets notes', () => {
  preloadFixtures('snippets/show.html');

  beforeEach(() => {
    loadFixtures('snippets/show.html');

    // Check if we have to Load GFM Input
    const gfmInputs = document.querySelectorAll('.js-gfm-input:not(.js-gfm-input-initialized)');
    console.log(gfmInputs.length);
    gfmInputs.forEach(initGFMInput);

    // TODO put snippet_show.js into a function
    initNotes();
  });

  const findAtwhoResult = async () => {
    const container = await screen.findByText('smile_cat', { selector: '.atwho-view li' });

    return Array.from(container.closest('.atwho-view').querySelectorAll('li')).map(
      (x) => x.innerText,
    );
  };
  const findNoteTextarea = () => document.getElementById('note_note');
  const fillNoteTextarea = (val) => {
    const textarea = findNoteTextarea();

    textarea.dispatchEvent(new Event('focus'));
    textarea.value = val;
    textarea.dispatchEvent(new Event('input'));
    textarea.dispatchEvent(new Event('click'));
  };

  it('silly', async () => {
    fillNoteTextarea(':smil');

    const result = await findAtwhoResult();

    expect(result).toBe('');
  });
});
