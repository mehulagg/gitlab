import Vue from 'vue';
import Vuex from 'vuex';
import EditUserList from 'ee/user_lists/components/edit_user_list.vue';
import createStore from 'ee/user_lists/store/edit';

Vue.use(Vuex);

document.addEventListener('DOMContentLoaded', () => {
  const el = document.getElementById('js-edit-user-list');
  const { userListsDocsPath } = el.dataset;
  return new Vue({
    el,
    store: createStore(el.dataset),
    provide: { userListsDocsPath },
    render(h) {
      return h(EditUserList, {});
    },
  });
});
