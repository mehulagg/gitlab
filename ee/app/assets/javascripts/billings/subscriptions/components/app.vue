<script>
import { mapActions } from 'vuex';
import SubscriptionTable from './subscription_table.vue';

export default {
  name: 'SubscriptionApp',
  components: {
    SubscriptionTable,
  },
  inject: ['planUpgradeHref', 'namespaceId', 'customerPortalUrl', 'namespaceName'],
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
    :customer-portal-url="customerPortalUrl"
  />
</template>
