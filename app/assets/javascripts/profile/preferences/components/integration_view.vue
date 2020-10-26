<script>
import { GlIcon, GlLink, GlSprintf } from '@gitlab/ui';

export default {
  name: 'IntegrationView',
  components: {
    GlIcon,
    GlLink,
    GlSprintf,
  },
  props: {
    userFields: {
      type: Object,
      required: true,
    },
    helpLink: {
      type: String,
      required: true,
    },
    message: {
      type: String,
      required: true,
    },
    messageUrl: {
      type: String,
      required: true,
    },
    config: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      isEnabled: this.userFields[this.config.formName],
    };
  },
};
</script>

<template>
  <div>
    <label class="label-bold">
      {{ config.title }}
    </label>
    <a class="has-tooltip" title="More information" :href="helpLink">
      <gl-icon name="question-o" class="vertical-align-middle" />
    </a>
    <div class="form-group form-check">
      <!-- Necessary for Rails to receive the value when not checked -->
      <input :name="`user[${config.formName}]`" type="hidden" value="0" />
      <input
        :id="`user_${config.formName}`"
        v-model="isEnabled"
        type="checkbox"
        class="form-check-input"
        :name="`user[${config.formName}]`"
        :value="isEnabled"
      />
      <label class="form-check-label" :for="`user_${config.formName}`">
        {{ config.label }}
      </label>
      <div class="form-text text-muted">
        <gl-sprintf :message="message">
          <template #link="{ content }">
            <gl-link :href="messageUrl" target="_blank">{{ content }}</gl-link>
            <gl-icon name="external-link" class="vertical-align-middle" :size="12" />
          </template>
        </gl-sprintf>
      </div>
    </div>
  </div>
</template>
