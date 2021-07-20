<script>
import { GlEmptyState } from '@gitlab/ui';
import { LOADING_VULNERABILITIES_ERROR_CODES as ERROR_CODES } from 'ee/security_dashboard/store/modules/vulnerabilities/constants';
import { s__, __ } from '~/locale';

const description = s__(
  'SecurityReports|Security reports can only be accessed by authorized users.',
);

export default {
  emptyStatePropsMap: {
    [ERROR_CODES.UNAUTHORIZED]: {
      title: s__('SecurityReports|You must sign in as an authorized user to see this report'),
      description,
      primaryButtonText: __('Sign in'),
      primaryButtonLink: '/users/sign_in',
    },
    [ERROR_CODES.FORBIDDEN]: {
      title: s__('SecurityReports|You do not have sufficient permissions to access this report'),
      description,
    },
  },
  components: {
    GlEmptyState,
  },
  props: {
    errorCode: {
      type: Number,
      required: true,
      validator: (value) => Object.values(ERROR_CODES).includes(value),
    },
    illustrations: {
      type: Object,
      required: false,
      default: () => ({}),
    },
  },
};
</script>

<template>
  <gl-empty-state
    v-bind="{ ...$options.emptyStatePropsMap[errorCode], svgPath: illustrations[errorCode] }"
  />
</template>
