<script>
import { GlFormGroup, GlFormInput } from '@gitlab/ui';
import { mapState } from 'vuex';
import { isSafeURL } from '~/lib/utils/url_utility';
import { __, s__ } from '~/locale';
import BranchesSelect from './branches_select.vue';

export default {
  components: {
    BranchesSelect,
    GlFormGroup,
    GlFormInput,
  },
  props: {
    branches: {
      type: Array,
      required: false,
      default: () => [],
    },
    name: {
      type: String,
      required: false,
      default: '',
    },
    serverValidationErrors: {
      type: Array,
      required: false,
      default: () => [],
    },
    showValidation: {
      type: Boolean,
      required: false,
      default: false,
    },
    url: {
      type: String,
      required: false,
      default: '',
    },
  },
  data() {
    return {
      branchesToAdd: [],
    };
  },
  computed: {
    ...mapState({
      projectId: ({ settings }) => settings.projectId,
    }),
    invalidUrl() {
      if (this.serverValidationErrors.includes('External url has already been taken')) {
        return this.$options.i18n.validations.urlTaken;
      }

      if (!this.url || !isSafeURL(this.url)) {
        return this.$options.i18n.validations.invalidUrl;
      }

      return '';
    },
    invalidName() {
      if (this.serverValidationErrors.includes('Name has already been taken')) {
        return this.$options.i18n.validations.nameTaken;
      }

      if (!this.name) {
        return this.$options.i18n.validations.nameMissing;
      }

      return '';
    },
    invalidBranches() {
      if (this.branches.some((id) => typeof id !== 'number')) {
        return this.$options.i18n.validations.branchesRequired;
      }

      return '';
    },
    isValidName() {
      return !this.showValidation || !this.invalidName;
    },
    isValidBranches() {
      return !this.showValidation || !this.invalidBranches;
    },
    isValidUrl() {
      return !this.showValidation || !this.invalidUrl;
    },
  },
  watch: {
    branchesToAdd(value) {
      this.$emit('update:branches', value ? [value] : []);
    },
  },
  i18n: {
    form: {
      addStatusChecks: s__('StatusCheck|API to check'),
      statusChecks: s__('StatusCheck|Status to check'),
      statusChecksDescription: s__(
        'StatusCheck|Invoke an external API as part of the pipeline process.',
      ),
      nameLabel: s__('StatusCheck|Service name'),
      nameDescription: s__('StatusCheck|Examples: QA, Security.'),
      protectedBranchLabel: s__('StatusCheck|Target branch'),
      protectedBranchDescription: s__(
        'StatusCheck|Apply this status check to any branch or a specific protected branch.',
      ),
    },
    validations: {
      branchesRequired: __('Please select a valid target branch.'),
      nameTaken: __('Name is already taken.'),
      nameMissing: __('Please provide a name.'),
      urlTaken: s__('StatusCheck|External API is already in use by another status check.'),
      invalidUrl: __('Please provide a valid URL.'),
    },
  },
};
</script>

<template>
  <form novalidate>
    <gl-form-group
      :label="$options.i18n.form.nameLabel"
      :description="$options.i18n.form.nameDescription"
      :state="isValidName"
      :invalid-feedback="invalidName"
      data-testid="name-group"
    >
      <gl-form-input
        :value="name"
        :state="isValidName"
        data-qa-selector="rule_name_field"
        data-testid="name"
        @input="$emit('update:name', $event)"
      />
    </gl-form-group>
    <gl-form-group
      :label="$options.i18n.form.addStatusChecks"
      :description="$options.i18n.form.statusChecksDescription"
      :state="isValidUrl"
      :invalid-feedback="invalidUrl"
      data-testid="url-group"
    >
      <gl-form-input
        :value="url"
        :state="isValidUrl"
        type="url"
        :placeholder="`https://api.gitlab.com/`"
        data-qa-selector="external_url_field"
        data-testid="url"
        @input="$emit('update:url', $event)"
      />
    </gl-form-group>
    <gl-form-group
      :label="$options.i18n.form.protectedBranchLabel"
      :description="$options.i18n.form.protectedBranchDescription"
      :state="isValidBranches"
      :invalid-feedback="invalidBranches"
      data-testid="branches-group"
    >
      <branches-select
        v-model="branchesToAdd"
        :project-id="projectId"
        :is-invalid="!isValidBranches"
        :selected-branches="branches"
      />
    </gl-form-group>
  </form>
</template>
