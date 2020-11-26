import Vue from 'vue';

import Translate from '~/vue_shared/translate';

import GroupMemberStore from './store/group_member_store';

import GroupMemberContributionsApp from './components/app.vue';

Vue.use(Translate);

export default () => {
  const el = document.getElementById('js-group-member-contributions');

  if (!el) {
    return false;
  }

  const { memberContributionsPath } = el.dataset;
  const store = new GroupMemberStore(memberContributionsPath);

  store.fetchContributedMembers();

  return new Vue({
    el,
    components: {
      GroupMemberContributionsApp,
    },
    data() {
      return {
        store,
      };
    },
    render(createElement) {
      return createElement('group-member-contributions-app', {
        props: {
          store: this.store,
          service: this.service,
        },
      });
    },
  });
};
