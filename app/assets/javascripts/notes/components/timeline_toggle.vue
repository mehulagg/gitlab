<script>
  import { GlButton, GlTooltipDirective } from '@gitlab/ui';
  import { mapActions, mapGetters } from 'vuex';
  import { __ } from '~/locale';

  const timelineEnabledTooltip = __('Back to normal view');
  const timelineDisabledTooltip = __('Unthread comments into a timeline view');

  export default {
    data(){
      return {
        enabled: false,
      }
    },
    components: {
      GlButton,
    },
    directives: {
      GlTooltip: GlTooltipDirective
    },
    computed: {
      ...mapGetters(['sortDirection', 'noteableType']),
      tooltip() {
        return this.enabled ? timelineEnabledTooltip : timelineDisabledTooltip;
      },
/*      selectedOption() {
        return SORT_OPTIONS.find(({ key }) => this.sortDirection === key);
      },
      dropdownText() {
        return this.selectedOption.text;
      },
      storageKey() {
        return `sort_direction_${this.noteableType.toLowerCase()}`;
      },*/
    },
    methods: {
/*      ...mapActions(['setDiscussionSortDirection']),
      fetchSortedDiscussions(direction) {
        if (this.isDropdownItemActive(direction)) {
          return;
        }

        this.setDiscussionSortDirection(direction);
        this.track('change_discussion_sort_direction', { property: direction });
      },
      isDropdownItemActive(sortDir) {
        return sortDir === this.sortDirection;
      },*/
      toggleTimeline(){
        this.enabled = !this.enabled;
      }
    },
  };
</script>

<template>
  <gl-button icon="comments" size="small"
             v-gl-tooltip :title="tooltip" @click="toggleTimeline" class="gl-mr-3" :class="{'gl-bg-gray-10!': enabled}"/>
</template>
