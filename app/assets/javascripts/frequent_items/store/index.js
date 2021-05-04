import Vuex from 'vuex';
import { FREQUENT_ITEMS_DROPDOWNS } from '../constants';
import createFrequentItemsModule from './modules/frequent_items';

export const createStore = () => {
  return new Vuex.Store({
    modules: FREQUENT_ITEMS_DROPDOWNS.reduce(
      (acc, { namespace, vuexModule }) =>
        Object.assign(acc, {
          [vuexModule]: createFrequentItemsModule({ dropdownType: namespace }),
        }),
      {},
    ),
  });
};
