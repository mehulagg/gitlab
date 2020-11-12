import { queryToObject, decodeUrlParameter } from '~/lib/utils/url_utility';
import createStore from './store';
import { initSidebar } from './sidebar';
import initGroupFilter from './group_filter';

export const initSearchApp = () => {
  const store = createStore({ query: queryToObject(decodeUrlParameter(window.location.search)) });

  initSidebar(store);
  initGroupFilter(store);
};
