import Vue from 'vue';
import VueRouter from 'vue-router';

Vue.use(VueRouter);

export default function createRouter() {
  const router = new VueRouter({
    base: window.location.pathname,
    mode: 'history',
    routes: [],
  });

  return router;
}
