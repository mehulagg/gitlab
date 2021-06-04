<script>
import { GlAlert, GlSprintf } from '@gitlab/ui';

export default {
  name: 'DismissibleAlertWithButton',
  components: {
    GlAlert,
    GlSprintf,
  },
  props: {
    title: {
      type: String,
      required: false,
      default: '',
    },
    message: {
      type: String,
      required: false,
      default: '',
    },
    buttonText: {
      type: String,
      required: false,
      default: '',
    },
    variant: {
      type: String,
      required: false,
      default: '',
    },
  },
  data() {
    return {
      isDismissed: false,
    };
  },
  methods: {
    dismiss() {
      this.isDismissed = true;
    },
  },
};
</script>

<template>
  <gl-alert
    v-if="!isDismissed"
    v-bind="$attrs"
    :title="title"
    :variant="variant"
    :primary-button-text="buttonText"
    @dismiss="dismiss"
    v-on="$listeners"
  >
    <gl-sprintf :message="message">
      <template #strong="{ content }">
        <strong> {{ content }} </strong>
      </template>
    </gl-sprintf>
  </gl-alert>
</template>
