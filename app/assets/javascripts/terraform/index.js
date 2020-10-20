import Vue from 'vue';
import TerraformList from './components/terraform_list.vue';

export default () => {
  const el = document.querySelector('#js-terraform-state-list');

  if (!el) {
    return null;
  }

  return new Vue({
    el,
    render(createElement) {
      return createElement(TerraformList);
    },
  });
};
