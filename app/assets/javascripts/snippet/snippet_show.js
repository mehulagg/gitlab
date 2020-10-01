import initNotes from '~/init_notes';
import loadAwardsHandler from '~/awards_handler';
import { SnippetShowInit } from '~/snippets';

document.addEventListener('DOMContentLoaded', () => {
  SnippetShowInit();
  initNotes();
  loadAwardsHandler();
});
