import Vue from 'vue';
import VueRouter from 'vue-router';
import { __ } from '~/locale';
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
      path: '/',
      component: {
        render(c) {
          return c('router-view');
        },
      },
      meta: {
        breadCrumb: __('Iteration cadences'),
      },
      children: [
        {
          name: 'index',
          path: '',
          component: IterationCadenceList,
        },
        {
          name: 'new',
          path: '/new',
          component: IterationCadenceForm,
          beforeEnter: checkPermission(permissions.canCreateCadence),
          meta: {
            breadCrumb: __('New cadence'),
          },
        },
        {
          name: 'edit',
          path: '/:cadenceId/edit',
          component: IterationCadenceForm,
          beforeEnter: checkPermission(permissions.canEditCadence),
          meta: {
            breadCrumb: () => 'cadsedit',
          },
        },
        {
          name: 'newIteration',
          path: '/:cadenceId/iterations/new',
          component: IterationForm,
          beforeEnter: checkPermission(permissions.canCreateIteration),
          meta: {
            breadCrumb: __('New iteration'),
          },
        },
        {
          name: 'iteration',
          path: '/:cadenceId/iterations/:iterationId',
          component: IterationReport,
          meta: {},
        },
        {
          name: 'editIteration',
          path: '/:cadenceId/iterations/:iterationId/edit',
          component: IterationForm,
          beforeEnter: checkPermission(permissions.canEditIteration),
          meta: {},
        },
        {
          path: '*',
          redirect: '/',
        },
      ],
    },
  ];

  const router = new VueRouter({
    base,
    mode: 'history',
    routes,
  });

  return router;
}
