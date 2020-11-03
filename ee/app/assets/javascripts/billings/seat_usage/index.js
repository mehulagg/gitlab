import Vue from 'vue';
import Vuex from 'vuex';
import SubscriptionSeats from './components/subscription_seats.vue';
import store from '../stores/index_seat_usage';

Vue.use(Vuex);

export default (containerId = 'js-seat-usage') => {
  const containerEl = document.getElementById(containerId);

  if (!containerEl) {
    return false;
  }

  const { namespaceId, namespaceName } = containerEl.dataset;

  return new Vue({
    el: containerEl,
    store,
    provide: {
      namespaceId,
      namespaceName,
    },
    render(createElement) {
      return createElement(SubscriptionSeats);
    },
  });
};
