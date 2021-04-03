import { GlToast } from '@gitlab/ui';
import Vue from 'vue';
import Vuex from 'vuex';
import { parseDataAttributes } from 'ee_else_ce/members/utils';
import App from './components/app.vue';
import membersStore from './store';

export const initMembersApp = (
  el,
  {
    tableFields = [],
    tableAttrs = {},
    tableSortableFields = [],
    requestFormatter = () => {},
    filteredSearchBar = { show: false },
  },
) => {
  if (!el) {
    return () => {};
  }

  Vue.use(Vuex);
  Vue.use(GlToast);

  const { sourceId, canManageMembers, ...vuexStoreAttributes } = parseDataAttributes(el);

  const store = new Vuex.Store(
    membersStore({
      ...vuexStoreAttributes,
      tableFields,
      tableAttrs,
      tableSortableFields,
      requestFormatter,
      filteredSearchBar,
    }),
  );

  return new Vue({
    el,
    components: { App },
    store,
    provide: {
      currentUserId: gon.current_user_id || null,
      sourceId,
      canManageMembers,
    },
    render: (createElement) => createElement('app'),
  });
};
