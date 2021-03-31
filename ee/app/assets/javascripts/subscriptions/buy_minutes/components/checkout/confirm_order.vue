<script>
import { STEPS, SUBSCRIPTON_FLOW_STEPS } from 'ee/registrations/constants';
import { GlButton, GlLoadingIcon } from '@gitlab/ui';
import { s__ } from '~/locale';

export default {
  components: {
    GlButton,
    GlLoadingIcon,
  },
  props: {
    currentStep: {
      type: Number,
      required: true,
      default: 0,
      validator: (value) => Object.values(STEPS).includes(value),
    },
    disabled: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  computed: {
    isActive() {
      return this.currentStep === 'confirmOrder';
    },
  },
  i18n: {
    confirm: s__('Checkout|Confirm purchase'),
    confirming: s__('Checkout|Confirming...'),
  },
};
</script>
<template>
  <div v-if="isActive" class="full-width gl-mb-7">
    <gl-button
      :disabled="disabled"
      variant="success"
      category="primary"
      @click="this.$emit('confirm')"
    >
      <gl-loading-icon v-if="!disabled" inline size="sm" />
      {{ disabled ? $options.i18n.confirming : $options.i18n.confirm }}
    </gl-button>
  </div>
</template>
