import Search from './search';
import { queryToObject } from '~/lib/utils/url_utility';
import createStore from '~/search/store';
import initDropdownFilters from '~/search/dropdown_filter';

document.addEventListener('DOMContentLoaded', () => {
  const store = createStore({ query: queryToObject(window.location.search) });

  initDropdownFilters(store);

  return new Search();
});
