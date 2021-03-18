<script>
import { GlEmptyState } from '@gitlab/ui';
import * as Sentry from '@sentry/browser';

export default {
  components: {
    GlEmptyState,
  },
  extends: {
    props: GlEmptyState.props,
  },
  props: {
    parse: {
      type: Function,
      required: true,
    },
    data: {
      type: Object,
      required: true,
    },
    shouldLog: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  computed: {
    parsedData() {
      try {
        return this.parse(this.data);
      } catch (error) {
        if (this.shouldLog) {
          Sentry.captureException(error);
        }

        return null;
      }
    },
    emptyStateProps() {
      const { parse, data, ...props } = this.$props;

      return props;
    },
  },
};
</script>
<template>
  <div>
    <gl-empty-state v-if="!parsedData" v-bind="emptyStateProps" />
    <slot v-else name="app" v-bind="parsedData"></slot>
  </div>
</template>
