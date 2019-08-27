<script>
import _ from 'lodash-es';

import epicItemDetails from './epic_item_details.vue';
import epicItemTimeline from './epic_item_timeline.vue';

import { EPIC_HIGHLIGHT_REMOVE_AFTER } from '../constants';

export default {
  components: {
    epicItemDetails,
    epicItemTimeline,
  },
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
    currentGroupId: {
      type: Number,
      required: true,
    },
    shellWidth: {
      type: Number,
      required: true,
    },
    itemWidth: {
      type: Number,
      required: true,
    },
  },
  updated() {
    this.removeHighlight();
  },
  methods: {
    /**
     * When new epics are added to the list on
     * timeline scroll, we set `newEpic` flag
     * as true and then use it in template
     * to set `newly-added-epic` class for
     * highlighting epic using CSS animations
     *
     * Once animation is complete, we need to
     * remove the flag so that animation is not
     * replayed when list is re-rendered.
     */
    removeHighlight() {
      if (this.epic.newEpic) {
        this.$nextTick(() => {
          _.delay(() => {
            this.epic.newEpic = false;
          }, EPIC_HIGHLIGHT_REMOVE_AFTER);
        });
      }
    },
  },
};
</script>

<template>
  <div :class="{ 'newly-added-epic': epic.newEpic }" class="epics-list-item clearfix">
    <epic-item-details :epic="epic" :current-group-id="currentGroupId" />
    <epic-item-timeline
      v-for="(timeframeItem, index) in timeframe"
      :key="index"
      :preset-type="presetType"
      :timeframe="timeframe"
      :timeframe-item="timeframeItem"
      :epic="epic"
      :shell-width="shellWidth"
      :item-width="itemWidth"
    />
  </div>
</template>
