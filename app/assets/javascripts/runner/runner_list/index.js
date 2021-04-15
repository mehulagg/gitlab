import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import { resolvers } from '../graphql/resolvers';
import RunnerListApp from './runner_list_app.vue';

Vue.use(VueApollo);

const apolloProvider = new VueApollo({
  defaultClient: createDefaultClient(resolvers),
});

export const initRunnerList = (selector = '#js-runner-list') => {
  const el = document.querySelector(selector);

  if (!el) {
    return null;
  }

  return new Vue({
    el,
    apolloProvider,
    render(h) {
      return h(RunnerListApp, {});
    },
  });
};
