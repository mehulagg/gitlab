<script>
import { mapActions } from 'vuex';
import SubscriptionTable from './subscription_table.vue';

export default {
  name: 'SubscriptionApp',
  components: {
    SubscriptionTable,
  },
  inject: ['planUpgradeHref', 'planRenewHref', 'namespaceId', 'customerPortalUrl', 'namespaceName'],
  created() {
    this.setNamespaceId(this.namespaceId);
  },
  methods: {
    ...mapActions(['setNamespaceId']),
  },
};
</script>

<template>
  <subscription-table
    :namespace-name="namespaceName"
    :plan-upgrade-href="planUpgradeHref"
    :plan-renew-href="planRenewHref"
    :customer-portal-url="customerPortalUrl"
  />
</template>
