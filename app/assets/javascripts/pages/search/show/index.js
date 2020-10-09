import Search from './search';
import setHighlightClass from './highlight_blob_search_result';
import initSearchApp from '~/search';

document.addEventListener('DOMContentLoaded', () => {
  initSearchApp();
  setHighlightClass(); // Code Highlighting
  return new Search(); // Deprecated Dropdown (Projects)
});
