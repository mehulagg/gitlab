<script>
// Nested `v-model`s in custom components are weird.
// It's dangerous to go alone! take this
// https://zaengle.com/blog/using-v-model-on-nested-vue-components

import { GlFormTextarea } from '@gitlab/ui';

export default {
  name: 'DismissalCommentBox',
  components: {
    GlFormTextarea,
  },
  props: {
    placeholder: {
      type: String,
      required: false,
      default: '',
    },
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
  },
  computed: {
    localComment: {
      get() {
        return this.value;
      },
      set(localComment) {
        this.$emit('input', localComment);
      },
    },
    textAreaState() {
      if (this.errorMessage) {
        return false;
      }
      return null;
    },
  },
  mounted() {
    this.$emit('input', this.dismissalComment);

    this.$emit('clearError');
    this.$refs.dismissalComment.$el.focus();
  },
  methods: {
    handleKeyPress(e) {
      if (e.keyCode === 13 && e.metaKey) {
        this.$emit('submit');
      }
    },
  },

  emits: ['clearError', 'input', 'submit'],
};
</script>

<template>
  <div>
    <gl-form-textarea
      ref="dismissalComment"
      v-model="localComment"
      rows="3"
      :state="textAreaState"
      :placeholder="placeholder"
      @keydown.native="handleKeyPress"
    />
    <span v-if="errorMessage" class="js-error invalid-feedback">{{ errorMessage }}</span>
  </div>
</template>
