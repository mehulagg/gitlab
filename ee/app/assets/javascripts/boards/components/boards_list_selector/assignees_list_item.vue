<script>
import { GlButton } from '@gitlab/ui';
import { sprintf, __ } from '~/locale';

export default {
  components: {
    GlButton,
  },
  props: {
    item: {
      type: Object,
      required: true,
    },
  },
  computed: {
    avatarAltText() {
      return sprintf(__("%{name}'s avatar"), {
        name: this.item.name,
      });
    },
  },
  methods: {
    handleItemClick() {
      this.$emit('onItemSelect', this.item);
    },
  },
};
</script>

<template>
  <li class="filter-dropdown-item" @click="handleItemClick">
    <gl-button variant="link" category="primary" class="dropdown-user">
      <div class="avatar-container s32 flex-shrink-0">
        <img :alt="avatarAltText" :src="item.avatar_url" class="avatar s32 lazy" />
      </div>
      <div class="text-truncate dropdown-user-details">
        <div class="text-truncate">{{ item.name }}</div>
        <div class="text-truncate dropdown-light-content">@{{ item.username }}</div>
      </div>
    </gl-button>
  </li>
</template>
