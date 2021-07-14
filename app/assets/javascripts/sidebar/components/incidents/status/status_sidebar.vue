<script>
import { GlLoadingIcon } from '@gitlab/ui';

export default {
  components: {
    GlLoadingIcon,
  },
  inject: ['issuableType'],
  props: {
    issuableId: {
      type: String,
      required: true,
    },
  },
  data() {
    return { statusList: [], isLoading: true };
  },
  // apollo: {
  //   statusList: {
  //     query() {
  //     },
  //     variables() {
  //       return {
  //         id: issuableId,
  //       };
  //     },
  //     update(data) {
  //       this.isLoading = false;
  //     },
  //     error() {
  //       createFlash({ message: __('Something went wrong. Please try again.') });
  //     },
  //   },
  // },
};
</script>

<template>
  <div class="block">
    <div v-if="isLoading"><gl-loading-icon size="md" /></div>
  </div>
</template>
