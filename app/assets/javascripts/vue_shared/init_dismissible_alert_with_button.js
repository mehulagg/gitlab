import Vue from 'vue';
import DismissibleAlertWithButton from '~/vue_shared/components/dismissible_alert_with_button.vue';

export default function initDismissibleAlert() {
  const el = document.querySelector('.js-dismissible-alert');

  if (!el) {
    return false;
  }

  return new Vue({
    el,
    render: (createElement) =>
      createElement(DismissibleAlertWithButton, {
        props: {
          ...el.dataset,
        },
      }),
  });
}
