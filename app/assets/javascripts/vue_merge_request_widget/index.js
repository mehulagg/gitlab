// This is a false violation of @gitlab/no-runtime-template-compiler, since it
// creates a new Vue instance by spreading a _valid_ Vue component definition
// into the Vue constructor.
/* eslint-disable @gitlab/no-runtime-template-compiler */
import Vue from 'vue';
import VueApollo from 'vue-apollo';
import MrWidgetOptions from 'ee_else_ce/vue_merge_request_widget/mr_widget_options.vue';
import createDefaultClient from '~/lib/graphql';
import Translate from '../vue_shared/translate';

Vue.use(Translate);
Vue.use(VueApollo);

const apolloProvider = new VueApollo({
  defaultClient: createDefaultClient(
    {},
    {
      useGet: true,
      assumeImmutableResults: true,
    },
  ),
});

export default () => {
  const el = document.getElementById('js-vue-mr-widget');

  if (gl.mrWidget || !el) return;

  gl.mrWidgetData.gitlabLogo = gon.gitlab_logo;
  gl.mrWidgetData.defaultAvatarUrl = gon.default_avatar_url;
  gl.mrWidgetData.etagCaching = el.dataset.graphqlResourceEtag;

  const vm = new Vue({
    el,
    ...MrWidgetOptions,
    apolloProvider,
  });

  window.gl.mrWidget = {
    checkStatus: vm.checkStatus,
  };
};
