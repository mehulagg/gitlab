import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import RunnerDetailsApp from './runner_list_app.vue';

Vue.use(VueApollo);

export const initRunnerList = (selector = '#js-runner-list') => {
  const el = document.querySelector(selector);

  if (!el) {
    return null;
  }

  const { registrationToken } = el.dataset;

  const apolloProvider = new VueApollo({
    defaultClient: createDefaultClient(
      {},
      {
        assumeImmutableResults: true,
      },
    ),
  });

  return new Vue({
    el,
    apolloProvider,
    render(h) {
      return h(RunnerDetailsApp, {
        props: {
          registrationToken,
        },
      });
    },
  });
};
