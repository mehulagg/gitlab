import Vue from 'vue';
import VueApollo from 'vue-apollo';
import GetSnippetQuery from 'shared_queries/snippet/snippet.query.graphql';

import Translate from '~/vue_shared/translate';
import createDefaultClient from '~/lib/graphql';

import { SNIPPET_LEVELS_MAP, SNIPPET_VISIBILITY_PRIVATE } from '~/snippets/constants';

Vue.use(VueApollo);
Vue.use(Translate);

export default function appFactory(el, Component) {
  if (!el) {
    return false;
  }

  const apolloProvider = new VueApollo({
    defaultClient: createDefaultClient({}, { batchMax: 1 }),
  });

  const {
    visibilityLevels = '[]',
    selectedLevel,
    multipleLevelsRestricted,
    ...restDataset
  } = el.dataset;

  apolloProvider.clients.defaultClient.cache.writeData({
    data: {
      visibilityLevels: JSON.parse(visibilityLevels),
      selectedLevel: SNIPPET_LEVELS_MAP[selectedLevel] ?? SNIPPET_VISIBILITY_PRIVATE,
      multipleLevelsRestricted: 'multipleLevelsRestricted' in el.dataset,
    },
  });

  const snippetViewApp = () =>
    new Vue({
      el,
      apolloProvider,
      render(createElement) {
        return createElement(Component, {
          props: {
            ...restDataset,
          },
        });
      },
    });

  if (el.dataset.snippetGid && window.gl.startup_graphql_calls) {
    const query = window.gl.startup_graphql_calls.find(
      call => call.operationName === 'GetSnippetQuery',
    );
    if (query) {
      return query.fetchCall
        .then(res => res.json())
        .then(res => {
          apolloProvider.clients.defaultClient.writeQuery({
            query: GetSnippetQuery,
            data: res.data,
            variables: {
              ids: el.dataset.snippetGid,
            },
          });
        })
        .catch(() => {})
        .finally(() => snippetViewApp());
    }
    return Promise.resolve(() => snippetViewApp());
  } else {
    return Promise.resolve(() => snippetViewApp());
  }
}
