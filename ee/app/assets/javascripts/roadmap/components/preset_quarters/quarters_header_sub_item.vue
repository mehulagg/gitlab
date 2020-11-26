<script>
import { monthInWords } from '~/lib/utils/datetime_utility';

import CommonMixin from '../../mixins/common_mixin';

import { PRESET_TYPES } from '../../constants';

export default {
  mixins: [CommonMixin],
  props: {
    currentDate: {
      type: Date,
      required: true,
    },
    timeframeItem: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      presetType: PRESET_TYPES.QUARTERS,
      indicatorStyle: {},
    };
  },
  computed: {
    quarterBeginDate() {
      return this.timeframeItem.range[0];
    },
    quarterEndDate() {
      return this.timeframeItem.range[2];
    },
    headerSubItems() {
      return this.timeframeItem.range;
    },
  },
  mounted() {
    this.$nextTick(() => {
      this.indicatorStyle = this.getIndicatorStyles();
    });
  },
  methods: {
    getSubItemValueClass(subItem) {
      let itemValueClass = '';

      if (
        this.currentDate.getFullYear() === subItem.getFullYear() &&
        this.currentDate.getMonth() === subItem.getMonth()
      ) {
        itemValueClass = 'label-dark label-bold';
      } else if (this.currentDate < subItem) {
        itemValueClass = 'label-dark';
      }
      return itemValueClass;
    },
    getSubItemValue(subItem) {
      return monthInWords(subItem, true);
    },
  },
};
</script>

<template>
  <div class="item-sublabel">
    <span
      v-for="(subItem, index) in headerSubItems"
      :key="index"
      :class="getSubItemValueClass(subItem)"
      class="sublabel-value"
      >{{ getSubItemValue(subItem) }}</span
    >
    <span
      v-if="hasToday"
      :style="indicatorStyle"
      class="current-day-indicator-header preset-quarters position-absolute"
    ></span>
  </div>
</template>
