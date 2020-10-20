<script>
import { mapActions } from 'vuex';
import SubscriptionTable from './subscription_table.vue';

export default {
  name: 'SubscriptionApp',
  components: {
    SubscriptionTable,
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
    billableSeatsHref: {
      type: String,
      required: false,
      default: '',
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
  <subscription-table
    :namespace-name="namespaceName"
    :plan-upgrade-href="planUpgradeHref"
    :customer-portal-url="customerPortalUrl"
    :billable-seats-href="billableSeatsHref"
  />
</template>
