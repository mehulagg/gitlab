<script>
import { GlDeprecatedSkeletonLoading as GlSkeletonLoading } from '@gitlab/ui';

const FIRST_CHAR_REGEX = /^(\+|-| )/;

export default {
  components: { GlSkeletonLoading },
  props: {
    error: {
      type: Boolean,
      required: true,
    },
    hasTruncatedDiffLines: {
      type: Boolean,
      required: true,
    },
    lines: {
      type: Array,
      required: true,
    },
    reloadDiffFn: {
      type: Function,
      required: true,
    },
  },
  methods: {
    trimChar(line) {
      return line.replace(FIRST_CHAR_REGEX, '');
    },
  },
  userColorSchemeClass: window.gon.user_color_scheme,
};
</script>

<template>
  <table class="code js-syntax-highlight" :class="$options.userColorSchemeClass">
    <template v-if="hasTruncatedDiffLines">
      <tr v-for="line in lines" v-once :key="line.line_code" class="line_holder">
        <td :class="line.type" class="no-border diff-line-num old_line">{{ line.old_line }}</td>
        <td :class="line.type" class="no-border diff-line-num new_line">{{ line.new_line }}</td>
        <td :class="line.type" class="line_content" v-html="trimChar(line.rich_text)"></td>
      </tr>
    </template>
    <tr v-else class="line_holder line-holder-placeholder">
      <td class="old_line no-border diff-line-num"></td>
      <td class="new_line no-border diff-line-num"></td>
      <td v-if="error" class="js-error-lazy-load-diff diff-loading-error-block">
        {{ __('Unable to load the diff') }}
        <button
          class="btn-link btn-link-retry btn-no-padding js-toggle-lazy-diff-retry-button"
          @click="reloadDiffFn"
        >
          {{ __('Try again') }}
        </button>
      </td>
      <td v-else class="line_content js-success-lazy-load">
        <span></span>
        <gl-skeleton-loading />
        <span></span>
      </td>
    </tr>
    <tr v-if="$slots.default" class="notes_holder">
      <td class="notes-content" colspan="3"><slot></slot></td>
    </tr>
  </table>
</template>
