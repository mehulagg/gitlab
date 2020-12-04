<script>
import EpicItem from './epic_item.vue';
import CurrentDayIndicator from './current_day_indicator.vue';

export default {
  EpicItem,
  //epicItemHeight: EPIC_ITEM_HEIGHT,
  components: {
   // VirtualList,
    EpicItem,
    CurrentDayIndicator,
  },
  props: {
    presetType: {
      type: String,
      required: true,
    },
    rotations: {
      type: Array,
      required: true,
    },
    timeframe: {
      type: Array,
      required: true,
    },
  },
  data() {
    return {
      clientWidth: 0,
      offsetLeft: 0,
      emptyRowContainerStyles: {},
      showBottomShadow: false,
      roadmapShellEl: null,
    };
  },
  computed: {
  //  ...mapState(['bufferSize', 'epicIid', 'childrenEpics', 'childrenFlags', 'epicIds']),
    emptyRowContainerVisible() {
     // return this.displayedEpics.length < this.bufferSize;
      return true;
    },
/*    sectionContainerStyles() {
      return {
        width: `${EPIC_DETAILS_CELL_WIDTH + TIMELINE_CELL_MIN_WIDTH * this.timeframe.length}px`,
      };
    },*/
    shadowCellStyles() {
      return {
        left: `${this.offsetLeft}px`,
      };
    },
    epicsWithAssociatedParents() {
      return this.epics.filter(
        epic => !epic.hasParent || (epic.hasParent && this.epicIds.indexOf(epic.parent.id) < 0),
      );
    },
    displayedEpics() {
      // If roadmap is accessed from epic, return all epics
      if (this.epicIid) {
        return this.epics;
      }

      // Return epics with correct parent associations.
      return this.epicsWithAssociatedParents;
    },
  },
/*  mounted() {
    eventHub.$on('epicsListScrolled', this.handleEpicsListScroll);
    eventHub.$on('toggleIsEpicExpanded', this.toggleIsEpicExpanded);
    window.addEventListener('resize', this.syncClientWidth);
    this.initMounted();
  },
  beforeDestroy() {
    eventHub.$off('epicsListScrolled', this.handleEpicsListScroll);
    eventHub.$off('toggleIsEpicExpanded', this.toggleIsEpicExpanded);
    window.removeEventListener('resize', this.syncClientWidth);
  },*/
  methods: {
  //  ...mapActions(['setBufferSize', 'toggleEpic']),
    initMounted() {
  /*    this.roadmapShellEl = this.$root.$el && this.$root.$el.querySelector('.js-roadmap-shell');
      this.setBufferSize(Math.ceil((window.innerHeight - this.$el.offsetTop) / EPIC_ITEM_HEIGHT));
*/
      // Wait for component render to complete
      this.$nextTick(() => {
        this.offsetLeft = (this.$el.parentElement && this.$el.parentElement.offsetLeft) || 0;

        // We cannot scroll to the indicator immediately
        // on render as it will trigger scroll event leading
        // to timeline expand, so we wait for another render
        // cycle to complete.
        this.$nextTick(() => {
          this.scrollToTodayIndicator();
        });

        if (!Object.keys(this.emptyRowContainerStyles).length) {
          this.emptyRowContainerStyles = this.getEmptyRowContainerStyles();
        }
      });

      this.syncClientWidth();
    },
    syncClientWidth() {
      this.clientWidth = this.$root.$el?.clientWidth || 0;
    },
    getEmptyRowContainerStyles() {
      if (this.$refs.epicItems && this.$refs.epicItems.length) {
        return {
          height: `${this.$el.clientHeight -
            this.displayedEpics.length * this.$refs.epicItems[0].$el.clientHeight}px`,
        };
      }
      return {};
    },
    /**
     * Scroll timeframe to the right of the timeline
     * by half the column size
     */
/*    scrollToTodayIndicator() {
      if (this.$el.parentElement) this.$el.parentElement.scrollBy(TIMELINE_CELL_MIN_WIDTH / 2, 0);
    },
    handleEpicsListScroll({ scrollTop, clientHeight, scrollHeight }) {
      this.showBottomShadow = Math.ceil(scrollTop) + clientHeight < scrollHeight;
    },*/
/*    getEpicItemProps(index) {
      return {
        key: generateKey(this.displayedEpics[index]),
        props: {
          epic: this.displayedEpics[index],
          presetType: this.presetType,
          timeframe: this.timeframe,
          currentGroupId: this.currentGroupId,
          clientWidth: this.clientWidth,
          childLevel: 0,
          childrenEpics: this.childrenEpics,
          childrenFlags: this.childrenFlags,
          hasFiltersApplied: this.hasFiltersApplied,
        },
      };
    },*/
/*    toggleIsEpicExpanded(epic) {
      this.toggleEpic({ parentItem: epic });
    },*/
  },
};
</script>

<template>
  <div class="list-section">
 <!--   <epic-item
      v-for="rotation in rotations"
      ref="epicItems"
      :key="rotation.id"
      :preset-type="presetType"
      :epic="rotation"
      :timeframe="timeframe"
    />-->
    <div
      v-if="emptyRowContainerVisible"
      :style="emptyRowContainerStyles"
      class="list-item list-item-empty clearfix"
    >
      <span class="details-cell"></span>
      <span v-for="(timeframeItem, index) in timeframe" :key="index" class="timeline-cell">
        <current-day-indicator :preset-type="presetType" :timeframe-item="timeframeItem" />
      </span>
    </div>
    <div
      v-show="showBottomShadow"
      :style="shadowCellStyles"
      class="scroll-bottom-shadow"
    ></div>
  </div>
</template>
