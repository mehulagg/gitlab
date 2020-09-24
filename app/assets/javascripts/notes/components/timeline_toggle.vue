<script>
  import {GlButton, GlTooltipDirective} from '@gitlab/ui';
  import {mapActions, mapGetters} from 'vuex';
  import {__} from '~/locale';
  import {COMMENTS_ONLY_FILTER_VALUE, DESC} from '../constants';
  import notesEventHub from '../event_hub';

  const timelineEnabledTooltip = __('Turn timeline view off');
  const timelineDisabledTooltip = __('Unthread comments into a timeline view');

  export default {
    data() {
      return {
        enabled: false,
        initialSort: null,
      }
    },
    components: {
      GlButton,
    },
    directives: {
      GlTooltip: GlTooltipDirective
    },
    computed: {
      ...mapGetters(['timelineEnabled', 'sortDirection']),
      tooltip() {
        return this.timelineEnabled ? timelineEnabledTooltip : timelineDisabledTooltip;
      },
    },
    methods: {
      ...mapActions(['setTimelineView', 'setDiscussionSortDirection']),
      setSort() {
        if (this.timelineEnabled && this.sortDirection !== DESC) {
          this.setDiscussionSortDirection({direction: DESC, persist: false});
        }
      },
      setFilter() {
        notesEventHub.$emit('dropdownSelect', COMMENTS_ONLY_FILTER_VALUE, false);
      },
      toggleTimeline() {
        this.setTimelineView(true);
        this.setSort();
        this.setFilter();
      }
    },
  };
</script>

<template>
  <gl-button icon="comments" size="small"
             v-gl-tooltip :title="tooltip" @click="toggleTimeline" class="gl-mr-3"
             :class="{'gl-bg-gray-10!': enabled}"/>
</template>
