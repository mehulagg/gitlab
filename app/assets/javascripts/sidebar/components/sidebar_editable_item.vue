<script>
import { GlButton, GlLoadingIcon } from '@gitlab/ui';
import { __ } from '~/locale';

export default {
  components: { GlButton, GlLoadingIcon },
  inject: ['canUpdate'],
  i18n: {
    edit: __('Edit'),
    none: __('None')
  },
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
    trackAttrs: {
      type: Object,
      required: false,
      default: {
        label: "",
        property: "",
        event: "",
      }
    }
  },
  data() {
    return {
      edit: false,
    };
  },
  destroyed() {
    window.removeEventListener('click', this.collapseWhenOffClick);
    window.removeEventListener('keyup', this.collapseOnEscape);
  },
  methods: {
    collapseWhenOffClick({ target }) {
      if (!this.$el.contains(target)) {
        this.collapse();
      }
    },
    collapseOnEscape({ key }) {
      if (key === 'Escape') {
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
      window.addEventListener('keyup', this.collapseOnEscape);
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
      window.removeEventListener('keyup', this.collapseOnEscape);
    },
    toggle({ emitEvent = true } = {}) {
      if (this.edit) {
        this.collapse({ emitEvent });
      } else {
        this.expand();
      }
    },
  },
};
</script>

<template>
  <div>
    <!-- .hide-collapsed is only relevant in a collapsible sidebar like the one in issue show page -->
    <div class="gl-display-flex gl-align-items-center gl-mb-3 hide-collapsed" @click.self="collapse">
      <span data-testid="title">{{ title }}</span>
      <gl-loading-icon v-if="loading" inline class="gl-ml-2" />
      <gl-button
        v-if="canUpdate"
        variant="link"
        class="gl-text-gray-900! gl-hover-text-blue-800! gl-ml-auto js-sidebar-dropdown-toggle"
        data-testid="edit-button"
        @keyup.esc="toggle"
        @click="toggle"
        :data-track-label="trackAttrs.label"
        :data-track-property="trackAttrs.property"
        :data-track-event="trackAttrs.event"
      >
        {{ $options.i18n.edit }}
      </gl-button>
    </div>
    <div v-show="!edit" class="gl-text-gray-500" data-testid="collapsed-content">
      <slot name="collapsed">{{ $options.i18n.none }}</slot>
    </div>
    <div v-show="edit" data-testid="expanded-content">
      <slot :edit="edit"></slot>
    </div>
  </div>
</template>
