import Vue from 'vue';
import DevopsAdoptionApp from './components/devops_adoption_app.vue';
import { createApolloProvider } from './graphql';

export default () => {
  const el = document.querySelector('.js-devops-adoption');

  if (!el) return false;

  const { groupId, groupName } = el.dataset;

  return new Vue({
    el,
    apolloProvider: createApolloProvider(groupId),
    provide: {
      isGroup: Boolean(groupId?.length),
      group: {
        id: parseInt(groupId, 10),
        full_name: groupName,
        // eslint-disable-next-line @gitlab/require-i18n-strings
        __typename: 'Group',
      },
    },
    render(h) {
      return h(DevopsAdoptionApp);
    },
  });
};
