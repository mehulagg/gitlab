<script>
import StageEventItem from './stage_event_item.vue';
import StageBuildItem from './stage_build_item.vue';
import LimitWarning from './limit_warning_component.vue';

export default {
  name: 'StageEventList',
  components: {
    LimitWarning,
    StageEventItem,
    StageBuildItem,
  },
  props: {
    stage: {
      type: Object,
      required: true,
    },
    events: {
      type: Array,
      required: true,
    },
  },
  data() {
    return {
      STAGE_NAME_TEST: 'test',
      STAGE_NAME_STAGING: 'staging',
    };
  },
  methods: {
    isCurrentStage(current, target) {
      return current.toLowerCase() === target;
    },
  },
};
</script>
<template>
  <div>
    <div class="events-description">
      {{ stage.description }}
      <limit-warning :count="events.length" />
    </div>
    <stage-build-item
      v-if="isCurrentStage(stage.title, STAGE_NAME_TEST)"
      :stage="stage"
      :events="events"
      :with-build-status="true"
    />
    <stage-build-item
      v-else-if="isCurrentStage(stage.title, STAGE_NAME_STAGING)"
      :stage="stage"
      :events="events"
    />
    <stage-event-item v-else :stage="stage" :events="events" />
  </div>
</template>
