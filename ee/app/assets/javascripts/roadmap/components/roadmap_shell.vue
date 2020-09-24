<script>
import { mapState } from 'vuex';
import { GlDeprecatedSkeletonLoading as GlSkeletonLoading } from '@gitlab/ui';

import { isInViewport } from '~/lib/utils/common_utils';
import { EXTEND_AS } from '../constants';
import eventHub from '../event_hub';

import epicsListSection from './epics_list_section.vue';
import milestonesListSection from './milestones_list_section.vue';
import roadmapTimelineSection from './roadmap_timeline_section.vue';

export default {
  components: {
    GlSkeletonLoading,
    epicsListSection,
    milestonesListSection,
    roadmapTimelineSection,
  },
  props: {
    presetType: {
      type: String,
      required: true,
    },
    epics: {
      type: Array,
      required: true,
    },
    milestones: {
      type: Array,
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
    hasFiltersApplied: {
      type: Boolean,
      required: true,
    },
  },
  data() {
    return {
      timeframeStartOffset: 0,
    };
  },
  computed: {
    ...mapState(['defaultInnerHeight']),
    displayMilestones() {
      return Boolean(this.milestones.length);
    },
  },
  mounted() {
    this.$nextTick(() => {
      // We're guarding this as in tests, `roadmapTimeline`
      // is not ready when this line is executed.
      if (this.$refs.roadmapTimeline) {
        this.timeframeStartOffset = this.$refs.roadmapTimeline.$el
          .querySelector('.timeline-header-item')
          .querySelector('.item-sublabel .sublabel-value:first-child')
          .getBoundingClientRect().left;
      }
    });
  },
  methods: {
    handleScroll() {
      const { scrollTop, scrollLeft, clientHeight, scrollHeight } = this.$el;
      const timelineEdgeStartEl = this.$refs.roadmapTimeline.$el
        .querySelector('.timeline-header-item')
        .querySelector('.item-sublabel .sublabel-value:first-child');
      const timelineEdgeEndEl = this.$refs.roadmapTimeline.$el
        .querySelector('.timeline-header-item:last-child')
        .querySelector('.item-sublabel .sublabel-value:last-child');

      // If timeline was scrolled to start
      if (isInViewport(timelineEdgeStartEl, { left: this.timeframeStartOffset })) {
        this.$emit('onScrollToStart', this.$refs.roadmapTimeline.$el, EXTEND_AS.PREPEND);
      } else if (isInViewport(timelineEdgeEndEl)) {
        // If timeline was scrolled to end
        this.$emit('onScrollToEnd', this.$refs.roadmapTimeline.$el, EXTEND_AS.APPEND);
      }

      eventHub.$emit('epicsListScrolled', { scrollTop, scrollLeft, clientHeight, scrollHeight });
    },
  },
};
</script>

<template>
  <div
    class="roadmap-shell js-roadmap-shell"
    data-qa-selector="roadmap_shell"
    @scroll="handleScroll"
  >
    <roadmap-timeline-section
      ref="roadmapTimeline"
      :preset-type="presetType"
      :epics="epics"
      :timeframe="timeframe"
    />
    <milestones-list-section
      v-if="displayMilestones"
      :preset-type="presetType"
      :milestones="milestones"
      :timeframe="timeframe"
      :current-group-id="currentGroupId"
    />
    <div v-if="!epics.length" class="skeleton-loader js-skeleton-loader">
      <div v-for="n in 10" :key="n" class="mt-2">
        <gl-skeleton-loading :lines="2" />
      </div>
    </div>
    <epics-list-section
      v-else
      :preset-type="presetType"
      :epics="epics"
      :timeframe="timeframe"
      :current-group-id="currentGroupId"
      :has-filters-applied="hasFiltersApplied"
    />
  </div>
</template>
