import setHighlightClass from './highlight_blob_search_result';
import initSearchApp from '~/search';

document.addEventListener('DOMContentLoaded', () => {
  setHighlightClass(); // Code Highlighting
  initSearchApp();
});
