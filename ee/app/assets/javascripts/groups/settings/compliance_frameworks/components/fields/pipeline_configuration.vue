<script>
import { GlFormGroup, GlFormInput } from '@gitlab/ui';

import { s__ } from '~/locale';

import {
  checkPipelineConfigurationFileExists,
  getPipelineConfigurationPathParts,
  isValidPipelineConfigurationFormat,
} from '../../utils';

export default {
  components: {
    GlFormGroup,
    GlFormInput,
  },
  props: {
    pipelineConfigurationFullPath: {
      type: String,
      required: false,
      default: null,
    },
  },
  data() {
    return {
      state: null,
      fileExists: null,
    };
  },
  computed: {
    isValid() {
      if (this.state === null) {
        return null;
      }

      return this.state && this.fileExists;
    },
    feedbackMessage() {
      if (this.fileExists === false) {
        return this.$options.i18n.invalid;
      }

      return this.$options.i18n.warning;
    },
  },
  methods: {
    async validate(path) {
      this.$emit('state', false);

      if (!path) {
        this.state = null;
        this.$emit('update:pipelineConfigurationFullPath', null);
        this.$emit('state', true);
        return;
      }

      if (!isValidPipelineConfigurationFormat(path)) {
        this.state = false;
        return;
      }

      const { file, group, project } = getPipelineConfigurationPathParts(path);

      if (!file || !group || !project) {
        this.state = false;
        return;
      }

      this.state = true;
      this.fileExists = await checkPipelineConfigurationFileExists(file, group, project);

      if (this.fileExists) {
        this.$emit('update:pipelineConfigurationFullPath', path);
        this.$emit('state', true);
      }
    },
  },
  i18n: {
    label: s__('ComplianceFrameworks|Compliance pipeline configuration location (optional)'),
    subLabel: s__('ComplianceFrameworks|Combines with the CI configuration at runtime.'),
    description: s__('ComplianceFrameworks|e.g. include-gitlab.ci.yml@group-name/project-name'),
    warning: s__(
      'ComplianceFrameworks|Invalid format: it should follow the format [PATH].yml@[GROUP]/[PROJECT]',
    ),
    invalid: s__(
      'ComplianceFrameworks|Could not find this configuration location, please try a different location',
    ),
  },
};
</script>

<template>
  <gl-form-group
    :label="$options.i18n.label"
    :description="$options.i18n.description"
    :invalid-feedback="feedbackMessage"
    :state="isValid"
  >
    <p class="col-form-label gl-font-weight-normal!">
      {{ $options.i18n.subLabel }}
    </p>
    <gl-form-input :value="pipelineConfigurationFullPath" :state="isValid" @input="validate" />
  </gl-form-group>
</template>
