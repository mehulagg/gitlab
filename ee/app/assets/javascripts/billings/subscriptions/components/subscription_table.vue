<script>
import { escape } from 'lodash';
import { mapActions, mapState, mapGetters } from 'vuex';
import { GlButton, GlLoadingIcon } from '@gitlab/ui';
import { TABLE_TYPE_DEFAULT, TABLE_TYPE_FREE, TABLE_TYPE_TRIAL } from 'ee/billings/constants';
import { s__ } from '~/locale';
import SubscriptionTableRow from './subscription_table_row.vue';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';

const createButtonProps = (text, href, testId) => ({ text, href, testId });

export default {
  name: 'SubscriptionTable',
  components: {
    GlButton,
    GlLoadingIcon,
    SubscriptionTableRow,
  },
  mixins: [glFeatureFlagsMixin()],
  inject: {
    planUpgradeHref: {
      default: '',
    },
    planRenewHref: {
      default: '',
    },
    namespaceId: {
      default: '',
    },
    customerPortalUrl: {
      default: '',
    },
    namespaceName: {
      default: '',
    },
    addSeatsHref: {
      default: '',
    },
    planName: {
      default: '',
    },
  },
  computed: {
    ...mapState(['isLoadingSubscription', 'hasErrorSubscription', 'plan', 'tables', 'endpoint']),
    ...mapGetters(['isFreePlan']),
    subscriptionHeader() {
      const planName = this.isFreePlan ? s__('SubscriptionTable|Free') : escape(this.planName);
      const suffix = !this.isFreePlan && this.plan.trial ? s__('SubscriptionTable|Trial') : '';

      return `${this.namespaceName}: ${planName} ${suffix}`;
    },
    canAddSeats() {
      return this.glFeatures.saasAddSeatsButton && !this.isFreePlan;
    },
    canRenew() {
      return !this.isFreePlan;
    },
    canUpgrade() {
      return this.isFreePlan || this.plan.upgradable;
    },
    canUpgradeEEPlan() {
      return !this.isFreePlan && this.planUpgradeHref;
    },
    addSeatsButton() {
      return this.canAddSeats
        ? createButtonProps(
            s__('SubscriptionTable|Add seats'),
            this.addSeatsHref,
            'add-seats-button',
          )
        : null;
    },
    upgradeButton() {
      return this.canUpgrade
        ? createButtonProps(
            s__('SubscriptionTable|Upgrade'),
            this.upgradeButtonHref,
            'upgrade-button',
          )
        : null;
    },
    upgradeButtonHref() {
      return this.canUpgradeEEPlan ? this.planUpgradeHref : this.customerPortalUrl;
    },
    renewButton() {
      return this.canRenew
        ? createButtonProps(s__('SubscriptionTable|Renew'), this.planRenewHref, 'renew-button')
        : null;
    },
    manageButton() {
      return !this.isFreePlan
        ? createButtonProps(
            s__('SubscriptionTable|Manage'),
            this.customerPortalUrl,
            'manage-button',
          )
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
    isLast(index) {
      return index === this.visibleRows.length - 1;
    },
  },
};
</script>

<template>
  <div>
    <div
      v-if="!isLoadingSubscription && !hasErrorSubscription"
      class="card gl-mt-3 subscription-table js-subscription-table"
    >
      <div class="card-header" data-testid="subscription-header">
        <strong>{{ subscriptionHeader }}</strong>
        <div class="controls">
          <gl-button
            v-for="(button, index) in buttons"
            :key="button.text"
            :href="button.href"
            :class="{ 'gl-ml-3': index !== 0 }"
            :data-testid="button.testId"
            category="secondary"
            target="_blank"
            variant="info"
            >{{ button.text }}</gl-button
          >
        </div>
      </div>
      <div
        class="card-body gl-display-flex gl-flex-column gl-sm-flex-direction-row flex-lg-column flex-grid"
      >
        <subscription-table-row
          v-for="(row, i) in visibleRows"
          :key="`subscription-rows-${i}`"
          :last="isLast(i)"
          :header="row.header"
          :columns="row.columns"
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
