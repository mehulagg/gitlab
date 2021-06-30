import Vue from 'vue';
import VueRouter from 'vue-router';
import IterationCadenceForm from './components/iteration_cadence_form.vue';
import IterationCadenceList from './components/iteration_cadences_list.vue';
import IterationForm from './components/iteration_form.vue';
import IterationReport from './components/iteration_report.vue';

Vue.use(VueRouter);

function checkPermission(permission) {
  return (to, from, next) => {
    if (permission) {
      next();
    } else {
      next({ path: '/' });
    }
  };
}

export default function createRouter({ base, permissions = {} }) {
  const routes = [
    {
      name: 'index',
      path: '/',
      component: IterationCadenceList,
    },
    {
      name: 'new',
      path: '/new',
      component: IterationCadenceForm,
      beforeEnter: checkPermission(permissions.canCreateCadence),
    },
    {
      name: 'edit',
      path: '/:cadenceId/edit',
      component: IterationCadenceForm,
      beforeEnter: checkPermission(permissions.canEditCadence),
    },
    {
      name: 'newIteration',
      path: '/:cadenceId/iterations/new',
      component: IterationForm,
      beforeEnter: checkPermission(permissions.canCreateIteration),
    },
    {
      name: 'iteration',
      path: '/:cadenceId/iterations/:iterationId',
      component: IterationReport,
    },
    {
      name: 'editIteration',
      path: '/:cadenceId/iterations/:iterationId/edit',
      component: IterationForm,
      beforeEnter: checkPermission(permissions.canEditIteration),
    },
    {
      path: '*',
      redirect: '/',
    },
  ];

  const router = new VueRouter({
    base,
    mode: 'history',
    routes,
  });

  return router;
}
