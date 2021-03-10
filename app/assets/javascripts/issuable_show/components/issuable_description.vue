<script>
import { GlSafeHtmlDirective as SafeHtml } from '@gitlab/ui';
import $ from 'jquery';
import '~/behaviors/markdown/render_gfm';

export default {
  directives: {
    SafeHtml,
  },
  props: {
    issuable: {
      type: Object,
      required: true,
    },
    canEdit: {
      type: Boolean,
      required: true,
    },
    taskListUpdatePath: {
      type: String,
      required: true,
    },
  },
  mounted() {
    this.renderGFM();
  },
  methods: {
    renderGFM() {
      $(this.$refs.gfmContainer).renderGFM();
    },
  },
};
</script>

<template>
  <div class="description" :class="{ 'js-task-list-container': canEdit && taskListUpdatePath }">
    <div ref="gfmContainer" v-safe-html="issuable.descriptionHtml" class="md"></div>
    <!-- eslint-disable vue/no-mutating-props -->
    <textarea
      v-if="issuable.description && taskListUpdatePath"
      ref="textarea"
      v-model="issuable.description"
      :data-update-url="taskListUpdatePath"
      class="hidden js-task-list-field"
      dir="auto"
    >
    </textarea>
    <!-- eslint-enable vue/no-mutating-props -->
  </div>
</template>
