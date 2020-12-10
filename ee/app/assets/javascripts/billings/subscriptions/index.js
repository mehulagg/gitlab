import Vue from 'vue';
import Vuex from 'vuex';
import SubscriptionApp from './components/app.vue';
import initialStore from './store';

Vue.use(Vuex);

export default (containerId = 'js-billing-plans') => {
  const containerEl = document.getElementById(containerId);

  if (!containerEl) {
    return false;
  }

  const {
    namespaceId,
    namespaceName,
    isGroup,
    planUpgradeHref,
    planRenewHref,
    customerPortalUrl,
    billableSeatsHref,
  } = containerEl.dataset;

  return new Vue({
    el: containerEl,
    store: new Vuex.Store(initialStore()),
    provide: {
      namespaceId,
      namespaceName,
      isGroup,
      planUpgradeHref,
      planRenewHref,
      customerPortalUrl,
      billableSeatsHref,
    },
    render(createElement) {
      return createElement(SubscriptionApp);
    },
  });
};
