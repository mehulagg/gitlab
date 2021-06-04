import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import DastConfigurationApp from './components/app.vue';

export default function init() {
  const el = document.querySelector('.js-dast-configuration');

  if (!el) {
    return undefined;
  }

  Vue.use(VueApollo);

  const apolloProvider = new VueApollo({
    defaultClient: createDefaultClient(),
  });

  const {
    securityConfigurationPath,
    fullPath,
    dastDocumentationPath,
    gitlabCiYamlEditPath,
  } = el.dataset;

  return new Vue({
    el,
    apolloProvider,
    provide: {
      securityConfigurationPath,
      fullPath,
      dastDocumentationPath,
      gitlabCiYamlEditPath,
    },
    render(createElement) {
      return createElement(DastConfigurationApp);
    },
  });
}
