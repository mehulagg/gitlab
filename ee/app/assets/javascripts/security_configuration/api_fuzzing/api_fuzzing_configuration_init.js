import Vue from 'vue';
import { apolloProvider } from './graphql/provider';
import ApiFuzzingApp from './components/app.vue';

export const initApiFuzzingConfiguration = () => {
  const el = document.querySelector('.js-api-fuzzing-configuration');

  if (!el) {
    return undefined;
  }

  return new Vue({
    el,
    apolloProvider,
    provide: {
      fullPath: 'Commit451/security-reports', // TODO: replace with real value
    },
    render(createElement) {
      return createElement(ApiFuzzingApp);
    },
  });
};
