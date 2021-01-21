<script>
import { GlButton } from '@gitlab/ui';
import { mapActions } from 'vuex';

export default {
  components: {
    GlButton,
  },
  methods: {
    ...mapActions(['setAddColumnFormVisibility']),
  },
};
</script>

<template>
  <gl-button variant="success" class="gl-ml-4" @click="setAddColumnFormVisibility(true)"
    >{{ __('Create list') }}
  </gl-button>
</template>
