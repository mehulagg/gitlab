<script>
import { delay } from 'lodash';

import EpicItemDetails from './epic_item_details.vue';
import EpicItemTimeline from './epic_item_timeline.vue';

import CommonMixin from '../mixins/common_mixin';

//import { EPIC_HIGHLIGHT_REMOVE_AFTER } from '../constants';

export default {
  components: {
    EpicItemDetails,
    EpicItemTimeline,
  },
  mixins: [CommonMixin],
  props: {
    presetType: {
      type: String,
      required: true,
    },
    epic: {
      type: Object,
      required: true,
    },
    timeframe: {
      type: Array,
      required: true,
    },
    clientWidth: {
      type: Number,
      required: false,
      default: 0,
    },

  },
};
</script>

<template>
  <div class="epic-item-container">
    <div class="list-item clearfix">
<!--      <epic-item-details
        :epic="epic"
        :current-group-id="currentGroupId"
        :timeframe-string="timeframeString(epic)"
        :child-level="childLevel"
        :children-flags="childrenFlags"
        :has-filters-applied="hasFiltersApplied"
        :is-children-empty="isChildrenEmpty"
      />-->
      <epic-item-timeline
        v-for="(timeframeItem, index) in timeframe"
        :key="index"
        :preset-type="presetType"
        :timeframe="timeframe"
        :timeframe-item="timeframeItem"
        :epic="epic"
        :client-width="clientWidth"
      />
    </div>
  </div>
</template>
