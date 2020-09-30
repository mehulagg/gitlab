import Search from './search';
import initSearchApp from '~/search';
import initStateFilter from '~/search/state_filter';
import initConfidentialFilter from '~/search/confidential_filter';

document.addEventListener('DOMContentLoaded', () => {
  initSearchApp();
  initStateFilter();
  initConfidentialFilter();

  return new Search();
});
