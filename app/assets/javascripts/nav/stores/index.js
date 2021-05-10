import Vuex from 'vuex';
import { PROJECTS_NAMESPACE, GROUPS_NAMESPACE } from '~/frequent_items/constants';
import { createFrequentItemsModule } from '~/frequent_items/store';

export const createStoreOptions = () => ({
  modules: {
    frequentProjects: createFrequentItemsModule({ dropdownType: PROJECTS_NAMESPACE }),
    frequentGroups: createFrequentItemsModule({ dropdownType: GROUPS_NAMESPACE }),
  },
});

export const createStore = () => new Vuex.Store(createStoreOptions());
