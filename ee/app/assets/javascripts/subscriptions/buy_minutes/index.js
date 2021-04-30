import Vue from 'vue';
import ensureData from '~/ensure_data';
import App from './components/app.vue';
import apolloProvider from './graphql';
import { writeInitialDataToApolloCache } from './utils';

export default (el) => {
  if (!el) {
    return null;
  }

  const extendedApp = ensureData(App, {
    parseData: writeInitialDataToApolloCache.bind(null, apolloProvider),
    data: el.dataset,
    shouldLog: true,
  });

  return new Vue({
    el,
    apolloProvider,
    render(createElement) {
      return createElement(extendedApp);
    },
  });
};
