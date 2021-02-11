<script>
import { GlSprintf, GlButton } from '@gitlab/ui';
import { __ } from '~/locale';

export default {
  i18n: {
    confidentialityOnWarning: __(
      'You are going to turn on the confidentiality. This means that only team members with %{strongStart}at least Reporter access%{strongEnd} are able to see and leave comments on the %{issuableType}.',
    ),
    confidentialityOffWarning: __(
      'You are going to turn off the confidentiality. This means %{strongStart}everyone%{strongEnd} will be able to see and leave a comment on this %{issuableType}.',
    ),
  },
  components: {
    GlSprintf,
    GlButton,
  },
  inject: ['fullPath'],
  props: {
    confidential: {
      required: true,
      type: Boolean,
    },
    issuableType: {
      required: true,
      type: String,
    },
  },
  data() {
    return {
      isLoading: false,
    };
  },
  computed: {
    toggleButtonText() {
      if (this.isLoading) {
        return __('Applying');
      }

      return this.confidential ? __('Turn Off') : __('Turn On');
    },
  },
  methods: {
    submitForm() {},
  },
};
</script>

<template>
  <div class="dropdown show">
    <div class="dropdown-menu sidebar-item-warning-message">
      <div>
        <p v-if="!confidential">
          <gl-sprintf :message="$options.i18n.confidentialityOnWarning">
            <template #strong="{ content }">
              <strong>{{ content }}</strong>
            </template>
            <template #issuableType>{{ issuableType }}</template>
          </gl-sprintf>
        </p>
        <p v-else>
          <gl-sprintf :message="$options.i18n.confidentialityOffWarning">
            <template #strong="{ content }">
              <strong>{{ content }}</strong>
            </template>
            <template #issuableType>{{ issuableType }}</template>
          </gl-sprintf>
        </p>
        <div class="sidebar-item-warning-message-actions">
          <gl-button class="gl-mr-3" @click="$emit('closeForm')">
            {{ __('Cancel') }}
          </gl-button>
          <gl-button
            category="secondary"
            variant="warning"
            :disabled="isLoading"
            :loading="isLoading"
            data-testid="confidential-toggle"
            @click.prevent="submitForm"
          >
            {{ toggleButtonText }}
          </gl-button>
        </div>
      </div>
    </div>
  </div>
</template>
