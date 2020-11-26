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
    planUpgradeHref,
    customerPortalUrl,
    billableSeatsHref,
  } = containerEl.dataset;

  return new Vue({
    el: containerEl,
    store: new Vuex.Store(initialStore()),
    provide: {
      namespaceId,
      namespaceName,
      planUpgradeHref,
      customerPortalUrl,
      billableSeatsHref,
      apiBillableMemberListFeatureEnabled: gon?.features?.apiBillableMemberList || false,
    },
    render(createElement) {
      return createElement(SubscriptionApp);
    },
  });
};
