<script>
import { GlIcon, GlCollapse, GlCollapseToggleDirective } from '@gitlab/ui';
import stateQuery from 'ee/subscriptions/graphql/queries/state.query.graphql';
import { TAX_RATE, NEW_GROUP } from 'ee/subscriptions/new/constants';
import formattingMixins from 'ee/subscriptions/new/formatting_mixins';
import { sprintf, s__ } from '~/locale';
import SummaryDetails from './order_summary/summary_details.vue';

export default {
  components: {
    SummaryDetails,
    GlIcon,
    GlCollapse,
  },
  directives: {
    GlCollapseToggle: GlCollapseToggleDirective,
  },
  mixins: [formattingMixins],
  props: {
    plans: {
      type: Array,
      required: true,
    },
  },
  apollo: {
    state: {
      query: stateQuery,
      manual: true,
      result({ data }) {
        this.subscription = data.subscription;
        this.namespaces = data.namespaces;
        this.isSetupForCompany = data.isSetupForCompany;
        this.fullName = data.fullName;
        this.customer = data.customer;
        this.selectedPlanId = data.selectedPlanId;
      },
    },
  },
  data() {
    return {
      subscription: {},
      namespaces: [],
      isSetupForCompany: false,
      isBottomSummaryVisible: false,
      fullName: null,
      customer: {},
      selectedPlanId: null,
    };
  },
  computed: {
    selectedPlan() {
      return this.plans.find((plan) => plan.id === this.selectedPlanId);
    },
    selectedPlanPrice() {
      return this.selectedPlan.pricePerYear;
    },
    selectedGroup() {
      return this.namespaces.find((group) => group.id === this.subscription.namespaceId);
    },
    totalExVat() {
      return this.subscription.quantity * this.selectedPlanPrice;
    },
    vat() {
      return TAX_RATE * this.totalExVat;
    },
    totalAmount() {
      return this.totalExVat + this.vat;
    },
    usersPresent() {
      return this.subscription.quantity > 0;
    },
    isGroupSelected() {
      return this.subscription.namespaceId && this.subscription.namespaceId !== NEW_GROUP;
    },
    isSelectedGroupPresent() {
      return (
        this.isGroupSelected &&
        this.namespaces.some((namespace) => namespace.id === this.subscription.namespaceId)
      );
    },
    name() {
      if (this.isSetupForCompany && this.customer.company) {
        return this.customer.company;
      }

      if (this.isGroupSelected && this.isSelectedGroupPresent) {
        return this.selectedGroup.name;
      }

      if (this.isSetupForCompany) {
        return s__('Checkout|Your organization');
      }

      return this.fullName;
    },
    titleWithName() {
      return sprintf(this.$options.i18n.title, { name: this.name });
    },
    isVisible() {
      return (
        !this.$apollo.loading &&
        (!this.isGroupSelected || this.isSelectedGroupPresent) &&
        this.selectedPlan
      );
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
    v-if="isVisible"
    class="order-summary gl-display-flex gl-flex-direction-column gl-flex-grow-1 gl-mt-2 mt-lg-5"
  >
    <div class="d-lg-none">
      <div v-gl-collapse-toggle.summary-details>
        <h4 class="d-flex justify-content-between gl-font-lg">
          <div class="d-flex">
            <gl-icon v-if="isBottomSummaryVisible" name="chevron-down" />
            <gl-icon v-else name="chevron-right" />
            <div>{{ titleWithName }}</div>
          </div>
          <div class="gl-ml-3">{{ formatAmount(totalAmount, usersPresent) }}</div>
        </h4>
      </div>
      <gl-collapse id="summary-details" v-model="isBottomSummaryVisible">
        <summary-details
          :vat="vat"
          :total-ex-vat="totalExVat"
          :users-present="usersPresent"
          :selected-plan-text="selectedPlan.name"
          :selected-plan-price="selectedPlanPrice"
          :total-amount="totalAmount"
          :number-of-users="subscription.quantity"
          :tax-rate="$options.taxRate"
        />
      </gl-collapse>
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
        :number-of-users="subscription.quantity"
        :tax-rate="$options.taxRate"
      />
    </div>
  </div>
</template>
