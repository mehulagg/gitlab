<script>
import { GlButton, GlForm, GlFormGroup, GlFormInput, GlLink, GlSprintf } from '@gitlab/ui';
import { debounce } from 'lodash';

import { helpPagePath } from '~/helpers/help_page_helper';
import { validateHexColor } from '~/lib/utils/color_utils';
import { __, s__ } from '~/locale';
import ColorPicker from '~/vue_shared/components/color_picker/color_picker.vue';
import { DEBOUNCE_DELAY } from '../constants';
import { fetchPipelineConfigurationFileExists, validatePipelineConfirmationFormat } from '../utils';

export default {
  components: {
    ColorPicker,
    GlButton,
    GlForm,
    GlFormGroup,
    GlFormInput,
    GlLink,
    GlSprintf,
  },
  props: {
    color: {
      type: String,
      required: false,
      default: null,
    },
    description: {
      type: String,
      required: false,
      default: null,
    },
    groupEditPath: {
      type: String,
      required: true,
    },
    name: {
      type: String,
      required: false,
      default: null,
    },
    pipelineConfigurationFullPathEnabled: {
      type: Boolean,
      required: false,
      default: false,
    },
    pipelineConfigurationFullPath: {
      type: String,
      required: false,
      default: null,
    },
    submitButtonText: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      pipelineConfigurationFileExists: true,
    };
  },
  computed: {
    isValidColor() {
      return validateHexColor(this.color);
    },
    isValidName() {
      if (this.name === null) {
        return null;
      }

      return Boolean(this.name);
    },
    isValidDescription() {
      if (this.description === null) {
        return null;
      }

      return Boolean(this.description);
    },
    isValidPipelineConfiguration() {
      if (!this.pipelineConfigurationFullPath) {
        return null;
      }

      return this.isValidPipelineConfigurationFormat && this.pipelineConfigurationFileExists;
    },
    isValidPipelineConfigurationFormat() {
      return validatePipelineConfirmationFormat(this.pipelineConfigurationFullPath);
    },
    disableSubmitBtn() {
      return (
        !this.isValidName ||
        !this.isValidDescription ||
        !this.isValidColor ||
        this.isValidPipelineConfiguration === false
      );
    },
    pipelineConfigurationFeedbackMessage() {
      if (!this.isValidPipelineConfigurationFormat) {
        return this.$options.i18n.pipelineConfigurationInputInvalidFormat;
      }

      return this.$options.i18n.pipelineConfigurationInputUnknownFile;
    },
    scopedLabelsHelpPath() {
      return helpPagePath('user/project/labels.md', { anchor: 'scoped-labels' });
    },
  },
  async created() {
    if (this.pipelineConfigurationFullPath) {
      this.validatePipelineConfigurationPath(this.pipelineConfigurationFullPath);
    }
  },
  methods: {
    onSubmit() {
      this.$emit('submit');
    },
    onPipelineInput(path) {
      this.$emit('update:pipelineConfigurationFullPath', path);
      this.validatePipelineInput(path);
    },
    async validatePipelineConfigurationPath(path) {
      this.pipelineConfigurationFileExists = await fetchPipelineConfigurationFileExists(path);
    },
    validatePipelineInput: debounce(function debounceValidation(path) {
      this.validatePipelineConfigurationPath(path);
    }, DEBOUNCE_DELAY),
  },
  i18n: {
    titleInputLabel: __('Title'),
    titleInputDescription: s__(
      'ComplianceFrameworks|Use %{codeStart}::%{codeEnd} to create a %{linkStart}scoped set%{linkEnd} (eg. %{codeStart}SOX::AWS%{codeEnd})',
    ),
    titleInputInvalid: __('A title is required'),
    descriptionInputLabel: __('Description'),
    descriptionInputInvalid: __('A description is required'),
    pipelineConfigurationInputLabel: s__(
      'ComplianceFrameworks|Compliance pipeline configuration location (optional)',
    ),
    pipelineConfigurationInputSubLabel: s__(
      'ComplianceFrameworks|Combines with the CI configuration at runtime.',
    ),
    pipelineConfigurationInputDescription: s__(
      'ComplianceFrameworks|e.g. include-gitlab.ci.yml@group-name/project-name',
    ),
    pipelineConfigurationInputInvalidFormat: s__(
      'ComplianceFrameworks|Invalid format: it should follow the format [PATH].y(a)ml@[GROUP]/[PROJECT]',
    ),
    pipelineConfigurationInputUnknownFile: s__(
      'ComplianceFrameworks|Could not find this configuration location, please try a different location',
    ),
    colorInputLabel: __('Background color'),
    cancelBtnText: __('Cancel'),
  },
};
</script>
<template>
  <gl-form @submit.prevent="onSubmit">
    <gl-form-group
      :label="$options.i18n.titleInputLabel"
      :invalid-feedback="$options.i18n.titleInputInvalid"
      :state="isValidName"
      data-testid="name-input-group"
    >
      <template #description>
        <gl-sprintf :message="$options.i18n.titleInputDescription">
          <template #code="{ content }">
            <code>{{ content }}</code>
          </template>

          <template #link="{ content }">
            <gl-link :href="scopedLabelsHelpPath" target="_blank">{{ content }}</gl-link>
          </template>
        </gl-sprintf>
      </template>

      <gl-form-input
        :value="name"
        :state="isValidName"
        data-testid="name-input"
        @input="$emit('update:name', $event)"
      />
    </gl-form-group>

    <gl-form-group
      :label="$options.i18n.descriptionInputLabel"
      :invalid-feedback="$options.i18n.descriptionInputInvalid"
      :state="isValidDescription"
      data-testid="description-input-group"
    >
      <gl-form-input
        :value="description"
        :state="isValidDescription"
        data-testid="description-input"
        @input="$emit('update:description', $event)"
      />
    </gl-form-group>

    <gl-form-group
      v-if="pipelineConfigurationFullPathEnabled"
      :label="$options.i18n.pipelineConfigurationInputLabel"
      :description="$options.i18n.pipelineConfigurationInputDescription"
      :invalid-feedback="pipelineConfigurationFeedbackMessage"
      :state="isValidPipelineConfiguration"
      data-testid="pipeline-configuration-input-group"
    >
      <p class="col-form-label gl-font-weight-normal!">
        {{ $options.i18n.pipelineConfigurationInputSubLabel }}
      </p>
      <gl-form-input
        :value="pipelineConfigurationFullPath"
        :state="isValidPipelineConfiguration"
        data-testid="pipeline-configuration-input"
        @input="onPipelineInput"
      />
    </gl-form-group>

    <color-picker
      :value="color"
      :label="$options.i18n.colorInputLabel"
      :state="isValidColor"
      @input="$emit('update:color', $event)"
    />

    <div
      class="gl-display-flex gl-justify-content-space-between gl-pt-5 gl-border-t-1 gl-border-t-solid gl-border-t-gray-100"
    >
      <gl-button
        type="submit"
        variant="success"
        class="js-no-auto-disable"
        data-testid="submit-btn"
        :disabled="disableSubmitBtn"
        >{{ submitButtonText }}</gl-button
      >
      <gl-button :href="groupEditPath" data-testid="cancel-btn">{{
        $options.i18n.cancelBtnText
      }}</gl-button>
    </div>
  </gl-form>
</template>
