<script>
import { GlButton, GlLoadingIcon } from '@gitlab/ui';

export default {
  components: { GlButton, GlLoadingIcon },
  props: {
    title: {
      type: String,
      required: false,
      default: '',
    },
    loading: {
      type: Boolean,
      required: false,
      default: false,
    },
    toggleHeader: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  inject: ['canUpdate'],
  data() {
    return {
      edit: false,
    };
  },
  computed: {
    showHeader() {
      if (!this.toggleHeader) {
        return true;
      }

      return !this.edit;
    },
  },
  destroyed() {
    window.removeEventListener('click', this.collapseWhenOffClick);
  },
  methods: {
    collapseWhenOffClick({ target }) {
      if (!this.$el.contains(target)) {
        this.collapse();
      }
    },
    expand() {
      if (this.edit) {
        return;
      }

      this.edit = true;
      this.$emit('open');
      window.addEventListener('click', this.collapseWhenOffClick);
    },
    collapse({ emitEvent = true } = {}) {
      if (!this.edit) {
        return;
      }

      this.edit = false;
      if (emitEvent) {
        this.$emit('close');
      }
      window.removeEventListener('click', this.collapseWhenOffClick);
    },
  },
};
</script>

<template>
  <div>
    <header
      v-show="showHeader"
      class="gl-display-flex gl-justify-content-space-between gl-align-items-flex-start gl-mb-3"
    >
      <span class="gl-vertical-align-middle">
        <slot name="title">
          <span data-testid="title">{{ title }}</span>
        </slot>
        <gl-loading-icon v-if="loading" inline class="gl-ml-2" />
      </span>
      <gl-button
        v-if="canUpdate"
        variant="link"
        class="gl-text-gray-900!"
        data-testid="edit-button"
        @click="expand()"
      >
        {{ __('Edit') }}
      </gl-button>
    </header>
    <div v-show="!edit" class="gl-text-gray-400" data-testid="collapsed-content">
      <slot name="collapsed">{{ __('None') }}</slot>
    </div>
    <div v-show="edit" data-testid="expanded-content">
      <slot></slot>
    </div>
  </div>
</template>
