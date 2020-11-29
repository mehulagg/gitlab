<script>
import { escape } from 'lodash';
import { mapActions, mapState, mapGetters } from 'vuex';
import { GlLoadingIcon } from '@gitlab/ui';
import { TABLE_TYPE_DEFAULT, TABLE_TYPE_FREE, TABLE_TYPE_TRIAL } from 'ee/billings/constants';
import { s__ } from '~/locale';
import SubscriptionTableRow from './subscription_table_row.vue';

export default {
  name: 'SubscriptionTable',
  components: {
    SubscriptionTableRow,
    GlLoadingIcon,
  },
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
  },
  computed: {
    ...mapState(['isLoadingSubscription', 'hasErrorSubscription', 'plan', 'tables', 'endpoint']),
    ...mapGetters(['isFreePlan']),
    subscriptionHeader() {
      const planName = this.isFreePlan ? s__('SubscriptionTable|Free') : escape(this.plan.name);
      const suffix = !this.isFreePlan && this.plan.trial ? s__('SubscriptionTable|Trial') : '';

      return `${this.namespaceName}: ${planName} ${suffix}`;
    },
    upgradeButton() {
      if (!this.isFreePlan && !this.plan.upgradable) {
        return null;
      }

      return {
        text: s__('SubscriptionTable|Upgrade'),
        href:
          !this.isFreePlan && this.planUpgradeHref ? this.planUpgradeHref : this.customerPortalUrl,
      };
    },
    manageButton() {
      if (this.isFreePlan) {
        return null;
      }

      return {
        text: s__('SubscriptionTable|Manage'),
        href: this.customerPortalUrl,
      };
    },
    buttons() {
      return [this.upgradeButton, this.manageButton].filter(Boolean);
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
