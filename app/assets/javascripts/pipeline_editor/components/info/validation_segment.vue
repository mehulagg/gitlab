<script>
import { GlIcon, GlLoadingIcon } from '@gitlab/ui';
import { CI_CONFIG_STATUS_VALID } from '../../constants';

export default {
  components: {
    GlIcon,
    GlLoadingIcon,
  },
  props: {
    ciConfig: {
      type: Object,
      required: false,
      default: null,
    },
    loading: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  computed: {
    isValid() {
      return this.ciConfig?.status === CI_CONFIG_STATUS_VALID;
    },
    validationMessage() {
      return this.ciConfig?.errors[0];
    },
  },
};
</script>

<template>
  <div>
    <div class="gl-display-flex gl-white-space-nowrap">
      <template v-if="loading">
        <gl-loading-icon inline />
        {{ s__('Pipelines|Validating GitLab CI configuration…') }}
      </template>
      <template v-else-if="!isValid">
        <gl-icon name="warning-solid" />
        <div>{{ s__('Pipelines|This GitLab CI configuration is invalid:') }}</div>
        <div class="gl-text-truncate gl-min-w-0">{{ validationMessage }}</div>
      </template>
      <template v-else>
        <gl-icon name="check" />
        {{ s__('Pipelines|This GitLab CI configuration is valid.') }}
      </template>
      <a href="/help/ci/yaml/README">{{ __('Learn more') }}</a>
    </div>
  </div>
</template>
