import Vue from 'vue';
import { parseBoolean } from '~/lib/utils/common_utils';
import ForkGroupsList from './components/fork_groups_list.vue';

document.addEventListener('DOMContentLoaded', () => {
  const mountElement = document.getElementById('fork-groups-mount-element');

  const { endpoint } = mountElement.dataset;

  return new Vue({
    el: mountElement,
    render(h) {
      return h(ForkGroupsList, {
        props: {
          endpoint,
        },
      });
    },
  });
});
