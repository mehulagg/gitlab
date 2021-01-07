<script>
import { GlAlert, GlButton, GlSprintf } from '@gitlab/ui';
import { s__ } from '~/locale';

export default {
  i18n: {
    ACTION: s__(
      'NetworkPolicies|%{labelStart}And%{labelEnd} %{spanStart}send an Alert to GitLab.%{spanEnd}',
    ),
    BUTTON_LABEL: s__('NetworkPolicies|+ Add alert'),
    HIGH_VOLUME_WARNING: s__(
      `NetworkPolicies|Alerts are intended to be selectively used for a limited number of events that are potentially concerning and warrant a manual review. Alerts should not be used as a substitute for a SIEM or a logging tool. High volume alerts are likely to be dropped so as to preserve the stability of GitLab's integration with Kubernetes.`,
    ),
  },
  components: {
    GlAlert,
    GlButton,
    GlSprintf,
  },
  props: {
    policyAlert: {
      type: Boolean,
      required: true,
    },
  },
};
</script>

<template>
  <div>
    <gl-alert v-if="policyAlert" variant="warning" :dismissible="false" class="gl-mt-5">
      {{ $options.i18n.HIGH_VOLUME_WARNING }}
    </gl-alert>
    <div
      class="gl-bg-gray-10 gl-border-solid gl-border-1 gl-border-gray-100 gl-rounded-base gl-p-5"
      :class="{ 'gl-mt-5': !policyAlert }"
    >
      <gl-button
        v-if="!policyAlert"
        variant="link"
        category="primary"
        data-testid="add-alert"
        @click="$emit('update-alert', !policyAlert)"
      >
        {{ $options.i18n.BUTTON_LABEL }}
      </gl-button>
      <div
        v-else
        class="gl-w-full gl-display-flex gl-justify-content-space-between gl-align-items-center"
      >
        <span>
          <gl-sprintf :message="$options.i18n.ACTION">
            <template #label="{ content }">
              <label for="actionType" class="text-uppercase gl-font-lg gl-mr-4 gl-mb-0">{{
                content
              }}</label>
            </template>
            <template #span="{ content }">
              <span>{{ content }}</span>
            </template>
          </gl-sprintf>
        </span>
        <gl-button
          data-testid="remove-alert"
          icon="remove"
          category="tertiary"
          @click="$emit('update-alert', !policyAlert)"
        />
      </div>
    </div>
  </div>
</template>
