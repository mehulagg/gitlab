<script>
import { GlIcon } from '@gitlab/ui';
import limitWarning from './limit_warning_component.vue';
import totalTime from './total_time_component.vue';

export default {
  components: {
    totalTime,
    limitWarning,
    GlIcon,
  },
  props: {
    items: {
      type: Array,
      default: () => [],
      required: false,
    },
    stage: {
      type: Object,
      default: () => ({}),
      required: false,
    },
  },
};
</script>
<template>
  <div>
    <div class="events-description">
      {{ stage.description }}
      <limit-warning :count="items.length" />
    </div>
    <ul class="stage-event-list">
      <li v-for="(build, i) in items" :key="i" class="stage-event-item item-build-component">
        <div class="item-details">
          <h5 class="item-title">
            <span class="icon-build-status">
              <gl-icon name="status_success" />
            </span>
            <a :href="build.url" class="item-build-name"> {{ build.name }} </a> &middot;
            <a :href="build.url" class="pipeline-id"> #{{ build.id }} </a>
            <gl-icon :size="16" name="fork" />
            <a :href="build.branch.url" class="ref-name"> {{ build.branch.name }} </a>
            <span class="icon-branch">
              <gl-icon name="commit" />
            </span>
            <a :href="build.commitUrl" class="commit-sha"> {{ build.shortSha }} </a>
          </h5>
          <span>
            <a :href="build.url" class="issue-date"> {{ build.date }} </a>
          </span>
        </div>
        <div class="item-time"><total-time :time="build.totalTime" /></div>
      </li>
    </ul>
  </div>
</template>
