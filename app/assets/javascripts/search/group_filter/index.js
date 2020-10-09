import Vue from 'vue';
import Translate from '~/vue_shared/translate';
import GroupFilter from './components/group_filter.vue';

Vue.use(Translate);

export default store => {
  const el = document.getElementById('js-search-group-dropdown');

  return new Vue({
    el,
    store,
    render(createElement) {
      return createElement(GroupFilter);
    },
  });
};
