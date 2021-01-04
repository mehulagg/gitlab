<script>
import { GlAlert, GlLink, GlSprintf } from '@gitlab/ui';
import { ERRORS } from '../constants';

export default {
  ERRORS,
  components: {
    GlAlert,
    GlLink,
    GlSprintf,
  },
  props: {
    error: {
      type: String,
      required: false,
      default: '',
    },
    wikiPagePath: {
      type: String,
      required: false,
      default: '',
    },
  },
  computed: {
    hasError() {
      return Boolean(this.error);
    },
    errorMessage() {
      if (!this.hasError) {
        return '';
      } else if (this.error === this.$options.ERRORS.PAGE_CHANGE.ERROR) {
        return this.$options.ERRORS.PAGE_CHANGE.MESSAGE;
      } else if (this.error === this.$options.ERRORS.PAGE_RENAME.ERROR) {
        return this.$options.ERRORS.PAGE_RENAME.MESSAGE;
      }
      return this.error;
    },
  },
};
</script>

<template>
  <gl-alert v-if="hasError" variant="danger" :dismissible="false">
    <gl-sprintf :message="errorMessage">
      <template #wikiLink="{ content }">
        <gl-link :href="wikiPagePath" target="_blank">{{ content }}</gl-link>
      </template>
    </gl-sprintf>
  </gl-alert>
</template>
