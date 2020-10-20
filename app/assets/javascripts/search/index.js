import { queryToObject } from '~/lib/utils/url_utility';
import createStore from './store';
import initDropdownFilters from './dropdown_filter';
import initGroupFilter from './group_filter';
import initProjectFilter from './project_filter';

export default () => {
  const store = createStore({ query: queryToObject(window.location.search) });

  initDropdownFilters(store);
  initGroupFilter(store);
  initProjectFilter(store);
};
