import initSearchApp from '~/search';
import Search from './search';

document.addEventListener('DOMContentLoaded', () => {
  initSearchApp();
  return new Search(); // Deprecated Dropdown (Projects)
});
