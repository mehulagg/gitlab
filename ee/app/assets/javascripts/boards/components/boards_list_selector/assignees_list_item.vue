<script>
import { sprintf, __ } from '~/locale';

export default {
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

  emits: ['onItemSelect'],
};
</script>

<template>
  <li class="filter-dropdown-item" @click="handleItemClick">
    <button class="btn btn-link dropdown-user d-flex py-2 px-4" type="button">
      <div class="avatar-container s32 flex-shrink-0">
        <img :alt="avatarAltText" :src="item.avatar_url" class="avatar s32 lazy" />
      </div>
      <div class="text-truncate dropdown-user-details">
        <div class="text-truncate">{{ item.name }}</div>
        <div class="text-truncate dropdown-light-content">@{{ item.username }}</div>
      </div>
    </button>
  </li>
</template>
