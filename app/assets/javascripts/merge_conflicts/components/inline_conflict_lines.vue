<script>
import { GlSafeHtmlDirective as SafeHtml } from '@gitlab/ui';
import { mapActions } from 'vuex';
import syntaxHighlight from '~/syntax_highlight';
import utilsMixin from '../mixins/line_conflict_utils';

export default {
  directives: {
    SafeHtml,
  },
  mixins: [utilsMixin],
  props: {
    file: {
      type: Object,
      required: true,
    },
  },
  mounted() {
    syntaxHighlight(document.querySelectorAll('.js-syntax-highlight'));
  },
  methods: {
    ...mapActions(['handleSelected']),
  },
};
</script>
<template>
  <table class="diff-wrap-lines code code-commit js-syntax-highlight">
    <!-- Unfortunately there isn't a good key for these sections -->
    <!-- eslint-disable vue/require-v-for-key -->
    <tr v-for="line in file.inlineLines" class="line_holder diff-inline">
      <template v-if="line.isHeader">
        <td :class="lineCssClass(line)" class="diff-line-num header"></td>
        <td :class="lineCssClass(line)" class="diff-line-num header"></td>
        <td :class="lineCssClass(line)" class="line_content header">
          <strong>{{ line.richText }}</strong>
          <button class="btn" @click="handleSelected({ file, line })">
            {{ line.buttonTitle }}
          </button>
        </td>
      </template>
      <template v-else>
        <td :class="lineCssClass(line)" class="diff-line-num new_line">
          <a>{{ line.new_line }}</a>
        </td>
        <td :class="lineCssClass(line)" class="diff-line-num old_line">
          <a>{{ line.old_line }}</a>
        </td>
        <td v-safe-html="line.richText" :class="lineCssClass(line)" class="line_content"></td>
      </template>
    </tr>
  </table>
</template>
