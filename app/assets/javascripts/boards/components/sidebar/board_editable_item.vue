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
  },
  inject: ['canUpdate'],
  data() {
    return {
      edit: false,
    };
  },
  destroyed() {
    window.removeEventListener('click', this.collapseWhenOffClick);
  },
  methods: {
    collapseWhenOffClick({ target }) {
      // to do maybe use a ref?
      // if (!this.$el.querySelector('.dropdown-menu').contains(target)) {
      //   this.collapse();
      // }
      if (!this.$refs.test.contains(target)) {
        this.collapse();
      }
    },
    expand(e) {
      if (this.edit) {
        return;
      }
      e.stopPropagation();

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
    toggle(e) {
      if (this.edit) {
        this.collapse();
      } else {
        this.expand(e);
      }
    },
  },
};
</script>

<template>
  <div>
    <div class="gl-display-flex gl-justify-content-space-between gl-mb-3">
      <span class="gl-vertical-align-middle">
        <span data-testid="title">{{ title }}</span>
        <gl-loading-icon v-if="loading" inline class="gl-ml-2" />
      </span>
      <gl-button
        v-if="canUpdate"
        variant="link"
        class="gl-text-gray-900! js-sidebar-dropdown-toggle"
        data-testid="edit-button"
        @click="toggle"
      >
        {{ __('Edit') }}
      </gl-button>
    </div>
    <div v-if="!edit" class="gl-text-gray-500" data-testid="collapsed-content">
      <slot name="collapsed">{{ __('None') }}</slot>
    </div>
    <div v-if="edit" data-testid="expanded-content">
      <slot ref="test" :edit="edit"></slot>
    </div>
  </div>
</template>
