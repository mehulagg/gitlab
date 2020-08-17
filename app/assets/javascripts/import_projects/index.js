import Vue from 'vue';
import Translate from '../vue_shared/translate';
import ImportProjectsTable from './components/import_projects_table.vue';
import { parseBoolean } from '../lib/utils/common_utils';
import createStore from './store';

Vue.use(Translate);

export function initStoreFromElement(element) {
  const {
    ciCdOnly,
    canSelectNamespace,
    provider,

    reposPath,
    jobsPath,
    importPath,
    namespacesPath,
  } = element.dataset;

  return createStore({
    initialState: {
      defaultTargetNamespace: gon.current_username,
      ciCdOnly: parseBoolean(ciCdOnly),
      canSelectNamespace: parseBoolean(canSelectNamespace),
      provider,
    },
    endpoints: {
      reposPath,
      jobsPath,
      importPath,
      namespacesPath,
    },
  });
}

export function initPropsFromElement(element) {
  return {
    providerTitle: element.dataset.providerTitle,
    filterable: parseBoolean(element.dataset.filterable),
  };
}

export default function mountImportProjectsTable(mountElement) {
  if (!mountElement) return undefined;

  const store = initStoreFromElement(mountElement);
  const props = initPropsFromElement(mountElement);

  return new Vue({
    el: mountElement,
    store,
    render(createElement) {
      return createElement(ImportProjectsTable, { props });
    },
  });
}
