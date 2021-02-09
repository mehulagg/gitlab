import { defaultDataIdFromObject } from 'apollo-cache-inmemory';
import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import resolvers from './graphql/resolvers';
import CorpusManagement from './components/corpus_management.vue';

Vue.use(VueApollo);

export default () => {
  const el = document.querySelector('.js-corpus-management');

  if (!el) {
    return undefined;
  }

  const defaultClient = createDefaultClient(resolvers, {
    cacheConfig: {
      dataIdFromObject: (object) => {
          return object.id || defaultDataIdFromObject(object)
      },
    },
  });

  const {
    dataset: { projectFullPath },
  } = el;

  const props = {
    projectFullPath,
  };

  return new Vue({
    el,
    apolloProvider: new VueApollo({ defaultClient }),
    render(h) {
      return h(CorpusManagement, {
        props,
      });
    },
  });
};
