import Vue from 'vue';
import VueRouter from 'vue-router';
import store from 'ee/insights/stores';
import { joinPaths } from '~/lib/utils/url_utility';

Vue.use(VueRouter);

export default function createRouter(base) {
  const router = new VueRouter({
    mode: 'hash',
    base: joinPaths(gon.relative_url_root || '', base),
    routes: [{ path: '/:tabId' }],
  });

  router.beforeEach((to, from, next) => {
    const page = to.path.substr(1);

    store.dispatch('insights/setActiveTab', page);

    next();
  });

  return router;
}
