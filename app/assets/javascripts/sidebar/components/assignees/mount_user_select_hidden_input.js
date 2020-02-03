import Vue from 'vue';
import UserSelectHiddenInput from './user_select_hidden_inputs.vue';

export default () => {
  const el = document.getElementById('js-test');

  if (!el) return;

  // eslint-disable-next-line no-new
  new Vue({
    el,
    components: {
      UserSelectHiddenInput,
    },
    render: createElement =>
      createElement('user-select-hidden-input', {}),
  });
}
