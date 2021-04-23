<script>
import { GlFormGroup, GlFormSelect, GlFormInput, GlSprintf, GlLink } from '@gitlab/ui';
import { isEmpty } from 'lodash';
import UPDATE_STATE from 'ee/subscriptions/graphql/mutations/update_state.mutation.graphql';
import STATE_QUERY from 'ee/subscriptions/graphql/queries/state.query.graphql';
import { NEW_GROUP, STEPS } from 'ee/subscriptions/new/constants';
import Step from 'ee/vue_shared/purchase_flow/components/step.vue';
import { sprintf, s__, __ } from '~/locale';
import autofocusonshow from '~/vue_shared/directives/autofocusonshow';

export default {
  components: {
    GlFormGroup,
    GlFormSelect,
    GlFormInput,
    GlSprintf,
    GlLink,
    Step,
  },
  directives: {
    autofocusonshow,
  },
  props: {
    plans: {
      type: Array,
      required: true,
    },
  },
  apollo: {
    state: {
      query: STATE_QUERY,
    },
  },
  computed: {
    subscription() {
      return this.state.subscription;
    },
    namespaces() {
      return this.state.namespaces;
    },
    selectedPlanModel: {
      get() {
        return this.subscription.planId;
      },
      set(planId) {
        this.updateSubscription({ subscription: { planId } });
      },
    },
    selectedGroupModel: {
      get() {
        return this.subscription.namespaceId;
      },
      set(namespaceId) {
        const quantity =
          this.namespaces.find((namespace) => namespace.id === namespaceId)?.users || 1;

        this.updateSubscription({ subscription: { namespaceId, quantity } });
      },
    },
    numberOfUsersModel: {
      get() {
        return this.selectedGroupUsers || 1;
      },
      set(number) {
        this.updateSubscription({ subscription: { quantity: number } });
      },
    },
    companyModel: {
      get() {
        return this.state.customer.company;
      },
      set(company) {
        this.updateSubscription({ customer: { company } });
      },
    },
    selectedPlan() {
      const selectedPlan = this.plans.find((plan) => plan.code === this.subscription.planId);
      if (!selectedPlan) {
        return this.plans[0];
      }

      return selectedPlan;
    },
    selectedPlanTextLine() {
      return sprintf(this.$options.i18n.selectedPlan, { selectedPlanText: this.selectedPlan.code });
    },
    selectedGroupUsers() {
      return (
        this.namespaces.find((namespace) => namespace.id === this.subscription.namespaceId)
          ?.users || 1
      );
    },
    isGroupSelected() {
      return this.subscription.namespaceId !== null;
    },
    isNumberOfUsersValid() {
      return (
        this.subscription.quantity > 0 && this.subscription.quantity >= this.selectedGroupUsers
      );
    },
    isValid() {
      if (this.state.isSetupForCompany) {
        return (
          !isEmpty(this.subscription.planId) &&
          (!isEmpty(this.state.customer.company) || this.isNewGroupSelected) &&
          this.isNumberOfUsersValid
        );
      }

      return !isEmpty(this.subscription.planId) && this.subscription.quantity === 1;
    },
    isShowingGroupSelector() {
      return !this.state.isNewUser && this.namespaces.length;
    },
    isNewGroupSelected() {
      return this.subscription.namespaceId === NEW_GROUP;
    },
    isShowingNameOfCompanyInput() {
      return this.state.isSetupForCompany && (!this.namespaces.length || this.isNewGroupSelected);
    },
    groupOptionsWithDefault() {
      return [
        {
          name: this.$options.i18n.groupSelectPrompt,
          id: null,
        },
        ...this.namespaces,
        {
          name: this.$options.i18n.groupSelectCreateNewOption,
          id: NEW_GROUP,
        },
      ];
    },
    groupSelectDescription() {
      return this.isNewGroupSelected
        ? this.$options.i18n.createNewGroupDescription
        : this.$options.i18n.selectedGroupDescription;
    },
  },
  methods: {
    updateSubscription(payload = {}) {
      this.$apollo.mutate({
        mutation: UPDATE_STATE,
        variables: {
          input: payload,
        },
      });
    },
    toggleIsSetupForCompany() {
      this.updateSubscription({ isSetupForCompany: !this.state.isSetupForCompany });
    },
  },
  i18n: {
    stepTitle: s__('Checkout|Subscription details'),
    nextStepButtonText: s__('Checkout|Continue to billing'),
    selectedPlanLabel: s__('Checkout|GitLab plan'),
    selectedGroupLabel: s__('Checkout|GitLab group'),
    groupSelectPrompt: __('Select'),
    groupSelectCreateNewOption: s__('Checkout|Create a new group'),
    selectedGroupDescription: s__('Checkout|Your subscription will be applied to this group'),
    createNewGroupDescription: s__("Checkout|You'll create your new group after checkout"),
    organizationNameLabel: s__('Checkout|Name of company or organization using GitLab'),
    numberOfUsersLabel: s__('Checkout|Number of users'),
    needMoreUsersLink: s__('Checkout|Need more users? Purchase GitLab for your %{company}.'),
    companyOrTeam: s__('Checkout|company or team'),
    selectedPlan: s__('Checkout|%{selectedPlanText} plan'),
    group: __('Group'),
    users: __('Users'),
  },
  stepId: STEPS[0].id,
};
</script>
<template>
  <step
    :step-id="$options.stepId"
    :title="$options.i18n.stepTitle"
    :is-valid="isValid"
    :next-step-button-text="$options.i18n.nextStepButtonText"
  >
    <template #body>
      <gl-form-group :label="$options.i18n.selectedPlanLabel" label-size="sm" class="mb-3">
        <gl-form-select
          v-model="selectedPlanModel"
          v-autofocusonshow
          :options="plans"
          value-field="code"
          text-field="name"
          data-qa-selector="plan_name"
        />
      </gl-form-group>
      <gl-form-group
        v-if="isShowingGroupSelector"
        :label="$options.i18n.selectedGroupLabel"
        :description="groupSelectDescription"
        label-size="sm"
        class="mb-3"
      >
        <gl-form-select
          ref="group-select"
          v-model="selectedGroupModel"
          :options="groupOptionsWithDefault"
          value-field="id"
          text-field="name"
          data-qa-selector="group_name"
        />
      </gl-form-group>
      <gl-form-group
        v-if="isShowingNameOfCompanyInput"
        :label="$options.i18n.organizationNameLabel"
        label-size="sm"
        class="mb-3"
      >
        <gl-form-input ref="organization-name" v-model="companyModel" type="text" />
      </gl-form-group>
      <div class="combined d-flex">
        <gl-form-group :label="$options.i18n.numberOfUsersLabel" label-size="sm" class="number">
          <gl-form-input
            ref="number-of-users"
            v-model.number="numberOfUsersModel"
            type="number"
            :min="selectedGroupUsers"
            :disabled="!state.isSetupForCompany"
            data-qa-selector="number_of_users"
          />
        </gl-form-group>
        <gl-form-group
          v-if="!state.isSetupForCompany"
          ref="company-link"
          class="label ml-3 align-self-end"
        >
          <gl-sprintf :message="$options.i18n.needMoreUsersLink">
            <template #company>
              <gl-link @click="toggleIsSetupForCompany">{{ $options.i18n.companyOrTeam }}</gl-link>
            </template>
          </gl-sprintf>
        </gl-form-group>
      </div>
    </template>
    <template #summary>
      <strong ref="summary-line-1">
        {{ selectedPlanTextLine }}
      </strong>
      <div v-if="state.isSetupForCompany" ref="summary-line-2">
        {{ $options.i18n.group }}: {{ customer.company || selectedGroupName }}
      </div>
      <div ref="summary-line-3">{{ $options.i18n.users }}: {{ subscription.quantity }}</div>
    </template>
  </step>
</template>
