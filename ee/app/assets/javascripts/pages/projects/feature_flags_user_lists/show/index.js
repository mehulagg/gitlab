import Vue from 'vue';
import Vuex from 'vuex';
import UserList from 'ee/user_lists/components/user_list.vue';
import createStore from 'ee/user_lists/store/show';

Vue.use(Vuex);

document.addEventListener('DOMContentLoaded', () => {
  const el = document.getElementById('js-edit-user-list');
  return new Vue({
    el,
    store: createStore(el.dataset),
    render(h) {
      const { emptyStatePath } = el.dataset;
      return h(UserList, { props: { emptyStatePath } });
    },
  });
});
