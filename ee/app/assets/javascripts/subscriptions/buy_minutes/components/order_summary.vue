<script>
import { GlIcon } from '@gitlab/ui';
import STATE_QUERY from 'ee/subscriptions/graphql/queries/state.query.graphql';
import { TAX_RATE, NEW_GROUP } from 'ee/subscriptions/new/constants';
import formattingMixins from 'ee/subscriptions/new/formatting_mixins';
import { sprintf, s__ } from '~/locale';
import SummaryDetails from './order_summary/summary_details.vue';

export default {
  components: {
    SummaryDetails,
    GlIcon,
  },
  mixins: [formattingMixins],
  apollo: {
    state: {
      query: STATE_QUERY,
    },
  },
  data() {
    return {
      collapsed: true,
    };
  },
  computed: {
    selectedPlan() {
      return this.state.plans.find((plan) => plan.code === this.state.subscription.planId);
    },
    selectedPlanPrice() {
      return this.selectedPlan.pricePerYear;
    },
    selectedGroup() {
      return this.state.namespaces.find(
        (group) => group.id === this.state.subscription.namespaceId,
      );
    },
    totalExVat() {
      return this.state.subscription.quantity * this.selectedPlanPrice;
    },
    vat() {
      return TAX_RATE * this.totalExVat;
    },
    totalAmount() {
      return this.totalExVat + this.vat;
    },
    usersPresent() {
      return this.state.subscription.quantity > 0;
    },
    isGroupSelected() {
      return (
        this.state.subscription.namespaceId && this.state.subscription.namespaceId !== NEW_GROUP
      );
    },
    isSelectedGroupPresent() {
      return (
        this.isGroupSelected &&
        this.state.namespaces.some(
          (namespace) => namespace.id === this.state.subscription.namespaceId,
        )
      );
    },
    name() {
      if (this.state.isSetupForCompany && this.state.customer.company) {
        return this.state.customer.company;
      }

      if (this.isGroupSelected && this.isSelectedGroupPresent) {
        return this.selectedGroup.name;
      }

      if (this.state.isSetupForCompany) {
        return s__('Checkout|Your organization');
      }

      return this.state.fullName;
    },
    titleWithName() {
      return sprintf(this.$options.i18n.title, { name: this.name });
    },
  },
  methods: {
    toggleCollapse() {
      this.collapsed = !this.collapsed;
    },
  },
  i18n: {
    title: s__("Checkout|%{name}'s GitLab subscription"),
  },
  taxRate: TAX_RATE,
};
</script>
<template>
  <div
    v-if="!isGroupSelected || isSelectedGroupPresent"
    class="order-summary gl-display-flex gl-flex-direction-column gl-flex-grow-1 gl-mt-2 mt-lg-5"
  >
    <div class="d-lg-none">
      <div @click="toggleCollapse">
        <h4 class="d-flex justify-content-between gl-font-lg" :class="{ 'gl-mb-7': !collapsed }">
          <div class="d-flex">
            <gl-icon v-if="collapsed" name="chevron-right" :size="18" use-deprecated-sizes />
            <gl-icon v-else name="chevron-down" :size="18" use-deprecated-sizes />
            <div>{{ titleWithName }}</div>
          </div>
          <div class="gl-ml-3">{{ formatAmount(totalAmount, usersPresent) }}</div>
        </h4>
      </div>
      <summary-details
        v-show="!collapsed"
        :vat="vat"
        :total-ex-vat="totalExVat"
        :users-present="usersPresent"
        :selected-plan-text="selectedPlan.name"
        :selected-plan-price="selectedPlanPrice"
        :total-amount="totalAmount"
        :number-of-users="state.subscription.quantity"
        :tax-rate="$options.taxRate"
      />
    </div>
    <div class="d-none d-lg-block">
      <div class="append-bottom-20">
        <h4>
          {{ titleWithName }}
        </h4>
      </div>
      <summary-details
        :vat="vat"
        :total-ex-vat="totalExVat"
        :users-present="usersPresent"
        :selected-plan-text="selectedPlan.name"
        :selected-plan-price="selectedPlanPrice"
        :total-amount="totalAmount"
        :number-of-users="state.subscription.quantity"
        :tax-rate="$options.taxRate"
      />
    </div>
  </div>
</template>
