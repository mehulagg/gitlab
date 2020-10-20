import Vue from 'vue';
import SubscriptionSeats from './components/subscription_seats.vue';
import store from '../stores/index_seat_usage';

export default (containerId = 'js-seat-usage') => {
  const containerEl = document.getElementById(containerId);

  if (!containerEl) {
    return false;
  }

  return new Vue({
    el: containerEl,
    store,
    components: {
      SubscriptionSeats,
    },
    data() {
      const { dataset } = this.$options.el;
      const { namespaceId, namespaceName } = dataset;

      return {
        namespaceId,
        namespaceName,
      };
    },
    render(createElement) {
      return createElement('subscription-seats', {
        props: {
          namespaceId: this.namespaceId,
          namespaceName: this.namespaceName,
        },
      });
    },
  });
};
