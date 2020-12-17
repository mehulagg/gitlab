<script>
import { GlButton, GlIcon, GlSprintf } from '@gitlab/ui';

export default {
  components: {
    GlButton,
    GlIcon,
    GlSprintf,
  },
  props: {
    policyAlert: {
      type: Boolean,
      required: true,
    },
  },
  methods: {
    updateAlert() {
      this.$emit('update-alert', !this.policyAlert);
    },
  },
};
</script>

<template>
  <div
    class="gl-bg-gray-10 gl-border-solid gl-border-1 gl-border-gray-100 gl-rounded-base gl-px-5 gl-py-5 gl-mt-5"
  >
    <gl-button
      v-if="!policyAlert"
      variant="link"
      category="primary"
      data-testid="add-alert"
      @click="updateAlert"
      >{{ s__('Network Policy|+ Add alert') }}</gl-button
    >
    <div
      v-else
      class="gl-w-full gl-display-flex gl-justify-content-space-between gl-align-items-center"
    >
      <span>
        <gl-sprintf
          :message="
            s__(
              'NetworkPolicies|%{labelStart}And%{labelEnd} %{spanStart}send an Alert to GitLab.%{spanEnd}',
            )
          "
        >
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
      <gl-button category="tertiary" @click="updateAlert">
        <gl-icon class="gl-vertical-align-middle" name="remove" />
      </gl-button>
    </div>
  </div>
</template>
