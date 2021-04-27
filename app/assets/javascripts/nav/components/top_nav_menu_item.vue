<script>
import { GlButton, GlIcon } from '@gitlab/ui';
import { kebabCase, mapKeys } from 'lodash';
import eventHub from '../event_hub';

const getDataKey = (key) => `data-${kebabCase(key)}`;

export default {
  components: {
    GlButton,
    GlIcon,
  },
  inject: {
    menuItemEvent: {
      default: 'menu-item-click',
    },
  },
  props: {
    menuItem: {
      type: Object,
      required: true,
    },
  },
  computed: {
    dataAttrs() {
      return mapKeys(this.menuItem.data || {}, (value, key) => getDataKey(key));
    },
    href() {
      // null makes sure we don't render href(unknown) on the element
      return this.menuItem.href || null;
    },
  },
  methods: {
    onClick() {
      // If we're a link, let's just do the default behavior so the view won't change
      if (this.menuItem.href) {
        return;
      }

      eventHub.$emit(this.menuItemEvent, this.menuItem);
    },
  },
};
</script>

<template>
  <gl-button
    category="tertiary"
    :href="href"
    class="top-nav-menu-item gl-display-block"
    :class="menuItem.css_class"
    v-bind="dataAttrs"
    @click="onClick"
    v-on="$listeners"
  >
    <slot>
      <span class="gl-display-flex">
        <gl-icon v-if="menuItem.icon" :name="menuItem.icon" class="gl-mr-2!" />
        {{ menuItem.title }}
        <gl-emoji v-if="menuItem.emoji" :data-name="menuItem.emoji" class="gl-ml-2" />
        <gl-icon v-if="menuItem.view" name="chevron-right" class="gl-ml-auto" />
      </span>
    </slot>
  </gl-button>
</template>
