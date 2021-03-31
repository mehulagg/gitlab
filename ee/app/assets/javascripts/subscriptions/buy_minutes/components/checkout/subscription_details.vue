<script>
import { GlFormGroup, GlFormSelect, GlFormInput, GlSprintf, GlLink } from '@gitlab/ui';
import gql from 'graphql-tag';
import { isEmpty } from 'lodash';
import { NEW_GROUP } from 'ee/subscriptions/new/constants';
import { sprintf, s__ } from '~/locale';
import autofocusonshow from '~/vue_shared/directives/autofocusonshow';
import Step from './step.vue';

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
      default: () => [],
    },
    namespaces: {
      type: Array,
      required: true,
      default: () => [],
    },
    isNewUser: {
      type: Boolean,
      required: false,
      default: false,
    },
    isSetupForCompany: {
      type: Boolean,
      required: false,
      default: false,
    },
    selectedNamespaceId: {
      type: String,
      required: false,
      default: '',
    },
    selectedPlanId: {
      type: String,
      required: false,
      default: '',
    },
    minimumNumberOfUsers: {
      type: Number,
      required: false,
      default: 1,
    },
  },
  data() {
    return {
      selectedNamespace: { value: this.selectedNamespaceId, text: '' },
      selectedPlan: { value: this.selectedPlanId, text: '' },
      numberOfUsers: this.minimumNumberOfUsers,
      organizationName: '',
    };
  },
  computed: {
    selectedPlanTextLine() {
      return sprintf(this.$options.i18n.selectedPlan, { selectedPlanText: this.selectedPlanText });
    },
    isValid() {
      if (this.isSetupForCompany) {
        return (
          !isEmpty(this.selectedPlan) &&
          (!isEmpty(this.organizationName) || this.isGroupSelected) &&
          this.numberOfUsers > 0 &&
          this.numberOfUsers >= this.selectedGroupUsers
        );
      }
      return !isEmpty(this.selectedPlan) && this.numberOfUsers === 1;
    },
    isShowingGroupSelector() {
      return !this.isNewUser && this.namespaces.length;
    },
    isShowingNameOfCompanyInput() {
      return this.isSetupForCompany && (!this.namespaces.length || this.selectedNamespace.value === NEW_GROUP);
    },
    groupOptionsWithDefault() {
      return [
        {
          text: this.$options.i18n.groupSelectPrompt,
          value: null,
        },
        ...this.namespaces,
        {
          text: this.$options.i18n.groupSelectCreateNewOption,
          value: NEW_GROUP,
        },
      ];
    },
    groupSelectDescription() {
      return this.selectedNamespace.value === NEW_GROUP
        ? this.$options.i18n.createNewGroupDescription
        : this.$options.i18n.selectedGroupDescription;
    },
    selectedNamespaceUsers() {
      return 1;
    },
  },
  methods: {
    toggleIsSetupForCompany() {

    },
  },
  i18n: {
    stepTitle: s__('Checkout|Subscription details'),
    nextStepButtonText: s__('Checkout|Continue to billing'),
    selectedPlanLabel: s__('Checkout|GitLab plan'),
    selectedGroupLabel: s__('Checkout|GitLab group'),
    groupSelectPrompt: s__('Checkout|Select'),
    groupSelectCreateNewOption: s__('Checkout|Create a new group'),
    selectedGroupDescription: s__('Checkout|Your subscription will be applied to this group'),
    createNewGroupDescription: s__("Checkout|You'll create your new group after checkout"),
    organizationNameLabel: s__('Checkout|Name of company or organization using GitLab'),
    numberOfUsersLabel: s__('Checkout|Number of users'),
    needMoreUsersLink: s__('Checkout|Need more users? Purchase GitLab for your %{company}.'),
    companyOrTeam: s__('Checkout|company or team'),
    selectedPlan: s__('Checkout|%{selectedPlanText} plan'),
    group: s__('Checkout|Group'),
    users: s__('Checkout|Users'),
  },
};
</script>

<template>
  <step
    step="subscriptionDetails"
    :title="$options.i18n.stepTitle"
    :is-valid="isValid"
    :next-step-button-text="$options.i18n.nextStepButtonText"
  >
    <template #body>
      <gl-form-group :label="$options.i18n.selectedPlanLabel" label-size="sm" class="mb-3">
        <gl-form-select
          v-model="selectedPlan"
          v-autofocusonshow
          :options="plans"
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
          v-model="selectedNamespace"
          :options="groupOptionsWithDefault"
          data-qa-selector="group_name"
        />
      </gl-form-group>
      <gl-form-group
        v-if="isShowingNameOfCompanyInput"
        :label="$options.i18n.organizationNameLabel"
        label-size="sm"
        class="mb-3"
      >
        <gl-form-input ref="organization-name" v-model="organizationName" type="text" />
      </gl-form-group>
      <div class="combined d-flex">
        <gl-form-group :label="$options.i18n.numberOfUsersLabel" label-size="sm" class="number">
          <gl-form-input
            ref="number-of-users"
            v-model.number="numberOfUsers"
            type="number"
            :min="selectedNamespaceUsers"
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
        {{ $options.i18n.group }}: {{ organizationName || selectedGroupName }}
      </div>
      <div ref="summary-line-3">{{ $options.i18n.users }}: {{ numberOfUsers }}</div>
    </template>
  </step>
</template>
