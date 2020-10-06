<script>
import { mapActions } from 'vuex';
import SubscriptionTable from './subscription_table.vue';
import SubscriptionSeatsTable from './subscription_seats_table.vue';

export default {
  name: 'SubscriptionApp',
  components: {
    SubscriptionTable,
    SubscriptionSeatsTable,
  },
  props: {
    planUpgradeHref: {
      type: String,
      required: false,
      default: '',
    },
    namespaceId: {
      type: String,
      required: false,
      default: '',
    },
    customerPortalUrl: {
      type: String,
      required: false,
      default: '',
    },
    namespaceName: {
      type: String,
      required: true,
    },
  },
  computed: {
    // TODO
    seatsInUse() {
      return true;
    },
  },
  created() {
    this.setNamespaceId(this.namespaceId);
  },
  methods: {
    ...mapActions('subscription', ['setNamespaceId']),
  },
};
</script>

<template>
  <div>
    <subscription-table
      :namespace-name="namespaceName"
      :plan-upgrade-href="planUpgradeHref"
      :customer-portal-url="customerPortalUrl"
    />
    <subscription-seats-table
      v-if="seatsInUse"
      :namespace-id="namespaceId"
      :namespace-name="namespaceName"
      class="gl-mt-7"
    />
  </div>
</template>
