<script>
import { GlFormGroup, GlFormInput } from '@gitlab/ui';
import { isSafeURL } from '~/lib/utils/url_utility';
import { __, s__ } from '~/locale';
import { NAME_TAKEN_SERVER_ERROR, URL_TAKEN_SERVER_ERROR } from '../constants';
import BranchesSelect from './branches_select.vue';

export default {
  components: {
    BranchesSelect,
    GlFormGroup,
    GlFormInput,
  },
  props: {
    projectId: {
      type: String,
      required: true,
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
    statusCheck: {
      type: Object,
      required: true,
    },
  },
  data() {
    return this.initializeData(this.statusCheck);
  },
  computed: {
    formData() {
      const { branches, name, url } = this;

      return {
        branches,
        name,
        url,
      };
    },
    isValid() {
      return this.isValidBranches && this.isValidName && this.isValidUrl;
    },
    isValidBranches() {
      return !this.branches.some((id) => typeof id !== 'number');
    },
    isValidName() {
      return Boolean(this.name);
    },
    isValidUrl() {
      return Boolean(this.url) && isSafeURL(this.url);
    },
    branchesState() {
      return !this.showValidation || this.isValidBranches;
    },
    nameState() {
      return (
        !this.showValidation ||
        (this.isValidName && !this.serverValidationErrors.includes(NAME_TAKEN_SERVER_ERROR))
      );
    },
    urlState() {
      return (
        !this.showValidation ||
        (this.isValidUrl && !this.serverValidationErrors.includes(URL_TAKEN_SERVER_ERROR))
      );
    },
    invalidNameMessage() {
      if (this.serverValidationErrors.includes(NAME_TAKEN_SERVER_ERROR)) {
        return this.$options.i18n.validations.nameTaken;
      }

      return this.$options.i18n.validations.nameMissing;
    },
    invalidUrlMessage() {
      if (this.serverValidationErrors.includes(URL_TAKEN_SERVER_ERROR)) {
        return this.$options.i18n.validations.urlTaken;
      }

      return this.$options.i18n.validations.invalidUrl;
    },
  },
  watch: {
    branchesToAdd(value) {
      this.branches = value ? [value] : [];
    },
    statusCheck(statusCheck) {
      const { branches, branchesToAdd, name, url } = this.initializeData(statusCheck);

      this.branches = branches;
      this.name = name;
      this.url = url;
      this.branchesToAdd(branchesToAdd);
    },
  },
  methods: {
    initializeData(statusCheck) {
      const { protectedBranches, name, externalUrl: url } = statusCheck;

      return {
        branches: protectedBranches.map(({ id }) => id),
        branchesToAdd: [],
        name,
        url,
      };
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
      :state="nameState"
      :invalid-feedback="invalidNameMessage"
      data-testid="name-group"
    >
      <gl-form-input
        v-model="name"
        :state="nameState"
        data-qa-selector="rule_name_field"
        data-testid="name"
      />
    </gl-form-group>
    <gl-form-group
      :label="$options.i18n.form.addStatusChecks"
      :description="$options.i18n.form.statusChecksDescription"
      :state="urlState"
      :invalid-feedback="invalidUrlMessage"
      data-testid="url-group"
    >
      <gl-form-input
        v-model="url"
        :state="urlState"
        type="url"
        :placeholder="`https://api.gitlab.com/`"
        data-qa-selector="external_url_field"
        data-testid="url"
      />
    </gl-form-group>
    <gl-form-group
      :label="$options.i18n.form.protectedBranchLabel"
      :description="$options.i18n.form.protectedBranchDescription"
      :state="branchesState"
      :invalid-feedback="$options.i18n.validations.branchesRequired"
      data-testid="branches-group"
    >
      <branches-select
        v-model="branchesToAdd"
        :project-id="projectId"
        :is-invalid="!branchesState"
        :selected-branches="branches"
      />
    </gl-form-group>
  </form>
</template>
