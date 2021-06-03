import Cookie from 'js-cookie';
import Vue from 'vue';
import QrtlyReconciliationAlert from './components/qrtly_reconciliation_alert.vue';

function shouldShowAlert(userId = null, namespaceId = null) {
  const cookieName = [userId, namespaceId].filter(Boolean);
  const cookieValue = Cookie.get('qrtly_reconciliation_alert_#{}');

  return Cookie.get('qrtly_reconciliation_alert_#{}');
}

export const initQrtlyReconciliationAlert = (selector = '#js-qrtly-reconciliation-alert') => {
  const el = document.querySelector(selector);

  if (!el) {
    return false;
  }

  return new Vue({
    el,
    render(createElement) {
      return createElement(QrtlyReconciliationAlert, {
        props: {
          date: new Date(el.dataset.date),
        },
      });
    },
  });
};
