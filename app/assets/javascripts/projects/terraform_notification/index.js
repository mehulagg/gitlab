import Vue from 'vue';
import TerraformNotification from './components/terraform_notification.vue';

export default () => {
  const el = document.querySelector('#js-terraform-notification');

  if (!el) {
    return false;
  }

  const { projectId, docsUrl } = el.dataset;

  return new Vue({
    el,
    provide: {
      projectId,
      docsUrl,
    },
    render: (createElement) => createElement(TerraformNotification),
  });
};
