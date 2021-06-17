import Vue from 'vue';
import VueRouter from 'vue-router';
import IterationCadenceForm from './components/iteration_cadence_form.vue';
import IterationCadenceList from './components/iteration_cadences_list.vue';
import IterationForm from './components/iteration_form.vue';
import IterationReport from './components/iteration_report.vue';

Vue.use(VueRouter);

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
      beforeEnter: (to, from, next) => {
        if (!permissions.canCreateCadence) {
          next({ path: '/' });
        } else {
          next();
        }
      },
    },
    {
      name: 'edit',
      path: '/:cadenceId/edit',
      component: IterationCadenceForm,
      beforeEnter: (to, from, next) => {
        if (!permissions.canEditCadence) {
          next({ path: '/' });
        } else {
          next();
        }
      },
    },
    {
      name: 'newIteration',
      path: '/:cadenceId/iterations/new',
      component: IterationForm,
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
