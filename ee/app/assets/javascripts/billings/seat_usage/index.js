import Vue from 'vue';
import Vuex from 'vuex';
import SubscriptionSeats from './components/subscription_seats.vue';
import initialStore from '../stores';

Vue.use(Vuex);

export default (containerId = 'js-seat-usage') => {
  const containerEl = document.getElementById(containerId);

  if (!containerEl) {
    return false;
  }

  const { namespaceId, namespaceName } = containerEl.dataset;

  return new Vue({
    el: containerEl,
    store: new Vuex.Store(initialStore()),
    provide: {
      namespaceId,
      namespaceName,
    },
    render(createElement) {
      return createElement(SubscriptionSeats);
    },
  });
};
