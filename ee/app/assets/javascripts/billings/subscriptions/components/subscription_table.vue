<script>
import { escape } from 'lodash';
import { mapActions, mapState, mapGetters } from 'vuex';
import { GlLoadingIcon } from '@gitlab/ui';
import { TABLE_TYPE_DEFAULT, TABLE_TYPE_FREE, TABLE_TYPE_TRIAL } from 'ee/billings/constants';
import { s__ } from '~/locale';
import SubscriptionTableRow from './subscription_table_row.vue';
import glFeatureFlagMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';

export default {
  name: 'SubscriptionTable',
  components: {
    SubscriptionTableRow,
    GlLoadingIcon,
  },
  mixins: [glFeatureFlagMixin()],
  props: {
    namespaceName: {
      type: String,
      required: true,
    },
    customerPortalUrl: {
      type: String,
      required: false,
      default: '',
    },
    planUpgradeHref: {
      type: String,
      required: false,
      default: '',
    },
    planRenewHref: {
      type: String,
      required: false,
      default: '',
    },
  },
  inject: {
    addSeatsHref: {
      default: '',
    },
  },
  computed: {
    ...mapState(['isLoadingSubscription', 'hasErrorSubscription', 'plan', 'tables', 'endpoint']),
    ...mapGetters(['isFreePlan']),
    subscriptionHeader() {
      const planName = this.isFreePlan ? s__('SubscriptionTable|Free') : escape(this.plan.name);
      const suffix = !this.isFreePlan && this.plan.trial ? s__('SubscriptionTable|Trial') : '';

      return `${this.namespaceName}: ${planName} ${suffix}`;
    },
    canAddSeats() {
      return this.glFeatures.saasAddSeatsButton && !this.isFreePlan;
    },
    canUpgrade() {
      return this.isFreePlan || this.plan.upgradable;
    },
    canRenew() {
      return this.glFeatures.saasManualRenewButton && !this.isFreePlan;
    },
    addSeatsButton() {
      return this.canAddSeats
        ? {
            text: s__('SubscriptionTable|Add Seats'),
            href: this.addSeatsHref,
            testId: 'add-seats',
          }
        : null;
    },
    upgradeButton() {
      return this.canUpgrade
        ? {
            text: s__('SubscriptionTable|Upgrade'),
            href: this.upgradeButtonHref,
          }
        : null;
    },
    upgradeButtonHref() {
      return !this.isFreePlan && this.planUpgradeHref
        ? this.planUpgradeHref
        : this.customerPortalUrl;
    },
    renewButton() {
      return this.canRenew
        ? {
            text: s__('SubscriptionTable|Renew'),
            href: this.planRenewHref,
          }
        : null;
    },
    manageButton() {
      return !this.isFreePlan
        ? {
            text: s__('SubscriptionTable|Manage'),
            href: this.customerPortalUrl,
          }
        : null;
    },
    buttons() {
      return [this.upgradeButton, this.addSeatsButton, this.renewButton, this.manageButton].filter(
        Boolean,
      );
    },
    visibleRows() {
      let tableKey = TABLE_TYPE_DEFAULT;

      if (this.plan.code === null) {
        tableKey = TABLE_TYPE_FREE;
      } else if (this.plan.trial) {
        tableKey = TABLE_TYPE_TRIAL;
      }

      return this.tables[tableKey].rows;
    },
  },
  mounted() {
    this.fetchSubscription();
  },
  methods: {
    ...mapActions(['fetchSubscription']),
  },
};
</script>

<template>
  <div>
    <div
      v-if="!isLoadingSubscription && !hasErrorSubscription"
      class="card gl-mt-3 subscription-table js-subscription-table"
    >
      <div class="js-subscription-header card-header">
        <strong>{{ subscriptionHeader }}</strong>
        <div class="controls">
          <a
            v-for="(button, index) in buttons"
            :key="button.text"
            :href="button.href"
            target="_blank"
            rel="noopener noreferrer"
            class="btn btn-inverted-secondary"
            :class="{ 'ml-2': index !== 0 }"
            :data-testid="button.testId"
            >{{ button.text }}</a
          >
        </div>
      </div>
      <div class="card-body flex-grid d-flex flex-column flex-sm-row flex-md-row flex-lg-column">
        <subscription-table-row
          v-for="(row, i) in visibleRows"
          :key="`subscription-rows-${i}`"
          :header="row.header"
          :columns="row.columns"
          :is-free-plan="isFreePlan"
        />
      </div>
    </div>

    <gl-loading-icon
      v-else-if="isLoadingSubscription && !hasErrorSubscription"
      :label="s__('SubscriptionTable|Loading subscriptions')"
      size="lg"
      class="gl-mt-3 gl-mb-3"
    />
  </div>
</template>
