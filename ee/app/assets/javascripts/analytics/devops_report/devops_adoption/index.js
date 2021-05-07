import Vue from 'vue';
import { convertToGraphQLId, TYPE_GROUP } from '~/graphql_shared/utils';
import DevopsAdoptionApp from './components/devops_adoption_app.vue';
import { createApolloProvider } from './graphql';

export default () => {
  const el = document.querySelector('.js-devops-adoption');

  if (!el) return false;

  const { emptyStateSvgPath, groupId } = el.dataset;

  const isGroup = Boolean(groupId);

  return new Vue({
    el,
    apolloProvider: createApolloProvider(groupId),
    provide: {
      emptyStateSvgPath,
      isGroup,
      groupGid: isGroup ? convertToGraphQLId(TYPE_GROUP, groupId) : null,
    },
    render(h) {
      return h(DevopsAdoptionApp);
    },
  });
};
