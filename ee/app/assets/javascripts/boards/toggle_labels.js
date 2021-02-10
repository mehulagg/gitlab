import Vue from '~/lib/vue_with_runtime_compiler';
import store from '~/boards/stores';
import ToggleLabels from './components/toggle_labels.vue';

export default () =>
  new Vue({
    el: document.getElementById('js-board-labels-toggle'),
    components: {
      ToggleLabels,
    },
    store,
    render: (createElement) => createElement('toggle-labels'),
  });
