import Vue from 'vue';
import VueRouter from 'vue-router';
import IterationCadenceForm from './components/iteration_cadence_form.vue';
import IterationCadenceList from './components/iteration_cadences_list.vue';

Vue.use(VueRouter);

const routes = [
  {
    name: 'new',
    path: '*/-/cadences/new',
    component: IterationCadenceForm,
  },
  {
    name: 'index',
    path: '*/-/cadences',
    component: IterationCadenceList,
  },
];

export default function createRouter() {
  const router = new VueRouter({
    mode: 'history',
    routes,
  });

  return router;
}
