<script>
import { GlIntersectionObserver } from '@gitlab/ui';
import { capitalizeFirstCharacter } from '~/lib/utils/text_utility';
import EmojiGroup from './emoji_group.vue';

export default {
  components: {
    GlIntersectionObserver,
    EmojiGroup,
  },
  props: {
    category: {
      type: String,
      required: true,
    },
    emojis: {
      type: Array,
      required: true,
    },
  },
  data() {
    return {
      renderGroup: false,
    };
  },
  computed: {
    categoryTitle() {
      return capitalizeFirstCharacter(this.category);
    },
  },
  methods: {
    categoryAppeared() {
      this.renderGroup = true;
      this.$emit('appear', this.category);
    },
    categoryDissappeared() {
      this.renderGroup = false;
    },
  },
};
</script>

<template>
  <gl-intersection-observer class="gl-px-3 gl-h-full" @appear="categoryAppeared">
    <div class="gl-top-0 gl-py-2 gl-bg-white gl-w-full emoji-picker-category-header">
      <b>{{ categoryTitle }}</b>
    </div>
    <emoji-group
      v-for="(emojiGroup, index) in emojis"
      :key="index"
      :emojis="emojiGroup"
      :render-group="renderGroup"
      @click="(emoji) => $emit('click', emoji)"
    />
  </gl-intersection-observer>
</template>
