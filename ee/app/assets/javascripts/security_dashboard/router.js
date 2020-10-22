import Vue from 'vue';
import VueRouter from 'vue-router';

Vue.use(VueRouter);

// Unfortunately Vue Router doesn't work without at least a fake component
// If you do only data handling
const EmptyRouterComponent = {
  render(createElement) {
    return createElement('div');
  },
};

export default () => {
  const routes = [{ path: '/', name: 'dashboard', component: EmptyRouterComponent }];
  const router = new VueRouter({
    mode: 'history',
    base: window.location.pathname,
    routes,
  });

  return router;
};
