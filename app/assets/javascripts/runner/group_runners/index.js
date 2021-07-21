import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import GroupRunnersApp from './group_runners_app.vue';

Vue.use(VueApollo);

export const initGroupRunners = (selector = '#js-group-runners') => {
  const el = document.querySelector(selector);

  if (!el) {
    return null;
  }

  const { groupFullPath } = el.dataset;

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
      return h(GroupRunnersApp, {
        props: {
          groupFullPath,
        },
      });
    },
  });
};
