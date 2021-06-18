<script>
import { GlFormGroup, GlFormSelect, GlFormInput, GlSprintf, GlLink } from '@gitlab/ui';
import { isEmpty } from 'lodash';
import { STEPS } from 'ee/subscriptions/constants';
import UPDATE_STATE from 'ee/subscriptions/graphql/mutations/update_state.mutation.graphql';
import STATE_QUERY from 'ee/subscriptions/graphql/queries/state.query.graphql';
import { NEW_GROUP } from 'ee/subscriptions/new/constants';
import Step from 'ee/vue_shared/purchase_flow/components/step.vue';
import { GENERAL_ERROR_MESSAGE } from 'ee/vue_shared/purchase_flow/constants';
import createFlash from '~/flash';
import { getParameterValues } from '~/lib/utils/url_utility';
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
  data() {
    return {
      subscription: {},
      namespaces: [],
      customer: {},
      isSetupForCompany: null,
      isNewUser: null,
      selectedPlanId: null,
    };
  },
  apollo: {
    state: {
      query: STATE_QUERY,
      manual: true,
      result({ data, loading }) {
        if (loading) {
          return;
        }

        this.subscription = data.subscription;
        this.namespaces = data.namespaces;
        this.customer = data.customer;
        this.isSetupForCompany = data.isSetupForCompany;
        this.isNewUser = data.isNewUser;
        this.selectedPlanId = data.selectedPlanId;
      },
    },
  },
  computed: {
    selectedPlanModel: {
      get() {
        return this.selectedPlanId || this.plans[0].id;
      },
      set(planId) {
        this.updateState({ subscription: { planId } });
      },
    },
    selectedGroupModel: {
      get() {
        return this.subscription.namespaceId;
      },
      set(namespaceId) {
        const quantity =
          this.namespaces.find((namespace) => namespace.id === namespaceId)?.users || 1;

        this.updateState({ subscription: { namespaceId, quantity } });
      },
    },
    numberOfUsersModel: {
      get() {
        return this.selectedGroupUsers || 1;
      },
      set(number) {
        this.updateState({ subscription: { quantity: number } });
      },
    },
    companyModel: {
      get() {
        return this.customer.company;
      },
      set(company) {
        this.updateState({ customer: { company } });
      },
    },
    selectedPlan() {
      const selectedPlan = this.plans.find((plan) => plan.id === this.selectedPlanId);
      if (!selectedPlan) {
        return this.plans[0];
      }

      return selectedPlan;
    },
    selectedPlanTextLine() {
      return sprintf(this.$options.i18n.selectedPlan, { selectedPlanText: this.selectedPlan.id });
    },
    selectedGroup() {
      return this.namespaces.find((namespace) => namespace.id === this.subscription.namespaceId);
    },
    selectedGroupUsers() {
      return this.selectedGroup?.users || 1;
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
      if (this.isSetupForCompany) {
        return (
          this.isNumberOfUsersValid &&
          !isEmpty(this.selectedPlanId) &&
          (!isEmpty(this.customer.company) || this.isGroupSelected)
        );
      }

      return this.subscription.quantity === 1 && !isEmpty(this.selectedPlanId);
    },
    isShowingGroupSelector() {
      return !this.isNewUser && this.namespaces.length;
    },
    isNewGroupSelected() {
      return this.subscription.namespaceId === NEW_GROUP;
    },
    isShowingNameOfCompanyInput() {
      return this.isSetupForCompany && (!this.namespaces.length || this.isNewGroupSelected);
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
  mounted() {
    this.preselectPlan();
  },
  methods: {
    updateState(payload = {}) {
      this.$apollo
        .mutate({
          mutation: UPDATE_STATE,
          variables: {
            input: payload,
          },
        })
        .catch((error) => {
          createFlash({ message: GENERAL_ERROR_MESSAGE, error, captureError: true });
        });
    },
    toggleIsSetupForCompany() {
      this.updateSubscription({ isSetupForCompany: !this.isSetupForCompany });
    },
    preselectPlan() {
      if (this.selectedPlanId) {
        return;
      }

      let preselectedPlan = this.plans[0];

      const planIdFromSearchParams = getParameterValues('planId');

      if (planIdFromSearchParams.length > 0) {
        preselectedPlan =
          this.plans.find((plan) => plan.id === planIdFromSearchParams[0].id) || preselectedPlan;
      }

      this.updateState({ selectedPlanId: preselectedPlan.id });
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
    v-if="!$apollo.loading"
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
          value-field="id"
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
            :disabled="!isSetupForCompany"
            data-qa-selector="number_of_users"
          />
        </gl-form-group>
        <gl-form-group
          v-if="!isSetupForCompany"
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
      <div v-if="isSetupForCompany" ref="summary-line-2">
        {{ $options.i18n.group }}: {{ customer.company || selectedGroup.name }}
      </div>
      <div ref="summary-line-3">{{ $options.i18n.users }}: {{ subscription.quantity }}</div>
    </template>
  </step>
</template>
