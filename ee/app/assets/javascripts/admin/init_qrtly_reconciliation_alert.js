import Vue from 'vue';
import QrtlyReconciliationAlert from './components/qrtly_reconciliation_alert.vue';

export const initQrtlyReconciliationAlert = (selector = '#js-qrtly-reconciliation-alert') => {
  const el = document.querySelector(selector);

  if (!el) {
    return false;
  }

  const { reconciliationDate, cookieKey } = el.dataset;

  return new Vue({
    el,
    render(createElement) {
      return createElement(QrtlyReconciliationAlert, {
        props: {
          date: new Date(reconciliationDate),
          cookieKey,
        },
      });
    },
  });
};
