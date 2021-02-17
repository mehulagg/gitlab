<script>
import { GlIcon, GlDropdown, GlSearchBoxByType } from '@gitlab/ui';
import { chunk } from 'lodash';
import VirtualList from 'vue-virtual-scroll-list';
import { initEmojiMap, getEmojiCategoryMap } from '~/emoji';
import Category from './category.vue';

export default {
  components: {
    GlIcon,
    GlDropdown,
    GlSearchBoxByType,
    VirtualList,
    Category,
  },
  props: {
    toggleClass: {
      type: [Array, String, Object],
      required: false,
      default: () => [],
    },
  },
  data() {
    return {
      categories: {},
      currentCategory: null,
      searchValue: '',
    };
  },
  computed: {
    categoryNames() {
      return Object.keys(this.categories);
    },
  },
  async mounted() {
    await initEmojiMap();

    const categories = await getEmojiCategoryMap();

    this.categories = Object.freeze(
      Object.keys(categories).reduce((acc, category) => {
        const emojis = categories[category];

        return {
          ...acc,
          [category]: { emojis: chunk(emojis, 9), height: Math.ceil(emojis.length / 9) * 25 + 29 },
        };
      }, {}),
    );
  },
  methods: {
    categoryAppeared(category) {
      this.currentCategory = category;
    },
    scrollToCategory(category) {
      const categoryIndex = Object.keys(this.categories).indexOf(category);
      const scrollTop = Object.keys(this.categories).reduce((acc, key, index) => {
        if (index < categoryIndex) {
          return acc + this.categories[key].height;
        }

        return acc;
      }, 0);

      this.$refs.virtualScoller.setScrollTop(scrollTop);
    },
  },
};
</script>

<template>
  <div class="emoji-picker">
    <gl-dropdown :toggle-class="toggleClass" no-flip right lazy>
      <template #button-content><slot name="button-content"></slot></template>
      <div class="gl-display-flex gl-px-2 gl-border-b-solid gl-border-gray-100 gl-border-b-1">
        <button
          v-for="(name, index) in categoryNames"
          :key="index"
          :class="{
            'gl-text-black-normal! gl-border-blue-600': name === currentCategory,
          }"
          type="button"
          class="gl-border-0 gl-border-b-2 gl-border-b-solid gl-flex-fill-1 gl-text-gray-300 gl-pt-2 gl-pb-3 gl-bg-transparent emoji-picker-category-tab"
          @click="scrollToCategory(name)"
        >
          <gl-icon name="clock" :size="12" />
        </button>
      </div>
      <div>
        <gl-search-box-by-type v-model="searchValue" class="gl-mb-0!" />
        <virtual-list ref="virtualScoller" :size="228" :remain="1" :bench="2" variable>
          <div
            v-for="(category, categoryKey) in categories"
            :key="categoryKey"
            :style="{ height: category.height + 'px' }"
          >
            <category
              :category="categoryKey"
              :emojis="category.emojis"
              @appear="categoryAppeared"
            />
          </div>
        </virtual-list>
      </div>
    </gl-dropdown>
  </div>
</template>
