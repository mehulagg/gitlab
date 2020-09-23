<script>
// Nested `v-model`s in custom components are weird.
// It's dangerous to go alone! take this
// https://zaengle.com/blog/using-v-model-on-nested-vue-components

import { GlFormTextarea } from '@gitlab/ui';
import DismissalCommentBox from 'ee/vue_shared/security_reports/components/dismissal_comment_box.vue';
import { s__ } from '~/locale';

const PLACEHOLDER = s__('vulnerability|Add a comment or reason for dismissal');

export default {
  name: 'DismissalCommentBoxToggle',
  components: {
    DismissalCommentBox,
    GlFormTextarea,
  },
  props: {
    value: {
      type: String,
      required: false,
      default: '',
    },
    dismissalComment: {
      type: String,
      required: false,
      default: '',
    },
    errorMessage: {
      type: String,
      required: false,
      default: '',
    },
    isActive: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  PLACEHOLDER,
  computed: {
    localComment: {
      get() {
        return this.value;
      },
      set(localComment) {
        this.$emit('input', localComment);
      },
    },
  },
};
</script>

<template>
  <div>
    <hr class="my-3" />
    <dismissal-comment-box
      v-if="isActive"
      v-model="localComment"
      data-qa-selector="dismiss_comment_field"
      :dismissal-comment="dismissalComment"
      :error-message="errorMessage"
      :placeholder="$options.PLACEHOLDER"
      @submit="$emit('submit')"
      @clearError="$emit('clearError')"
    />
    <gl-form-textarea
      v-else
      :placeholder="$options.PLACEHOLDER"
      class="bg-gray-light js-comment-placeholder"
      @focus.native="$emit('openDismissalCommentBox')"
    />
  </div>
</template>
