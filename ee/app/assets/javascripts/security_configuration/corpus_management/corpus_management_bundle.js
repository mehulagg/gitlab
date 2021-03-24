import { defaultDataIdFromObject } from 'apollo-cache-inmemory';
import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import CorpusManagement from './components/corpus_management.vue';
import resolvers from './graphql/resolvers';

Vue.use(VueApollo);

export default () => {
  const el = document.querySelector('.js-corpus-management');

  if (!el) {
    return undefined;
  }

  const defaultClient = createDefaultClient(resolvers, {
    cacheConfig: {
      dataIdFromObject: (object) => {
        return object.id || defaultDataIdFromObject(object);
      },
    },
  });

  const {
    dataset: { projectFullPath, corpusHelpPath },
  } = el;

  const props = {
    projectFullPath,
    corpusHelpPath,
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
