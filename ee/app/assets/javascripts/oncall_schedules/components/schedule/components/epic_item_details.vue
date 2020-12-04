<script>
import { mapState } from 'vuex';
import { GlButton, GlIcon, GlLoadingIcon, GlTooltip } from '@gitlab/ui';
import { __, n__ } from '~/locale';
//import eventHub from '../event_hub';
//import { EPIC_LEVEL_MARGIN } from '../constants';

export default {
  components: {
    GlButton,
    GlIcon,
    GlLoadingIcon,
    GlTooltip,
  },
  props: {
    epic: {
      type: Object,
      required: true,
    },
    currentGroupId: {
      type: Number,
      required: true,
    },
    timeframeString: {
      type: String,
      required: true,
    },
    childLevel: {
      type: Number,
      required: true,
    },
    childrenFlags: {
      type: Object,
      required: true,
    },
  },
  computed: {
  //  ...mapState(['allowSubEpics']),
    itemId() {
      return this.epic.id;
    },

  },
};
</script>

<template>
  <div
    class="epic-details-cell gl-display-flex gl-flex-direction-column gl-justify-content-center"
    data-qa-selector="epic_details_cell"
  >
    <div
      class="gl-display-flex align-items-start gl-px-3 gl-mb-1"
    >
      <div class="overflow-hidden flex-grow-1 mx-2">
        <a
          :href="epic.webUrl"
          :title="epic.title"
          class="epic-title gl-mt-1 d-block text-body bold"
        >
          {{ epic.title }}
        </a>
        <div class="epic-group-timeframe d-flex text-secondary">
          <span
            v-if="true"
            :title="epic.groupFullName"
            class="epic-group"
          >
            {{ epic.groupName }}
          </span>
          <span v-if="true" class="mx-1" aria-hidden="true"
            >&middot;</span
          >
          <span class="epic-timeframe" :title="timeframeString">{{ timeframeString }}</span>
        </div>
      </div>
    </div>
  </div>
</template>
