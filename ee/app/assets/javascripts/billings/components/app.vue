<script>
import { mapActions, mapState } from 'vuex';
import SubscriptionTable from './subscription_table.vue';
import SubscriptionSeats from './subscription_seats.vue';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';

export default {
  name: 'SubscriptionApp',
  components: {
    SubscriptionTable,
    SubscriptionSeats,
  },
  mixins: [glFeatureFlagsMixin()],
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
    ...mapState('subscription', ['hasBillableGroupMembers']),
    isFeatureFlagEnabled() {
      return this.glFeatures?.apiBillableMemberList;
    },
  },
  created() {
    this.setNamespaceId(this.namespaceId);

    if (this.isFeatureFlagEnabled) {
      this.fetchHasBillableGroupMembers();
    }
  },
  methods: {
    ...mapActions('subscription', ['setNamespaceId', 'fetchHasBillableGroupMembers']),
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

    <subscription-seats
      v-if="isFeatureFlagEnabled && hasBillableGroupMembers"
      :namespace-name="namespaceName"
      :namespace-id="namespaceId"
      class="gl-mt-7"
    />
  </div>
</template>
