<script>
import { GlButton } from '@gitlab/ui';

export default {
  components: {
    GlButton,
  },
};
</script>

<template>
  <gl-button variant="success" @click="addListFormVisible">{{ __('Create list') }} </gl-button>
</template>
