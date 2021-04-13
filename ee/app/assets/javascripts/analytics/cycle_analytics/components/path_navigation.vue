<script>
import {
  GlPath,
  GlPopover,
  GlDeprecatedSkeletonLoading as GlSkeletonLoading,
  GlSafeHtmlDirective as SafeHtml,
} from '@gitlab/ui';

export default {
  name: 'PathNavigation',
  components: {
    GlPath,
    GlSkeletonLoading,
    GlPopover,
  },
  directives: {
    SafeHtml,
  },
  props: {
    loading: {
      type: Boolean,
      required: false,
      default: false,
    },
    stages: {
      type: Array,
      required: true,
    },
    selectedStage: {
      type: Object,
      required: false,
      default: () => {},
    },
  },
  methods: {
    showPopover({ startEventHtmlDescription, endEventHtmlDescription }) {
      return startEventHtmlDescription || endEventHtmlDescription;
    },
  },
  popoverOptions: {
    triggers: 'hover',
    placement: 'bottom',
  },
};
</script>
<template>
  <gl-skeleton-loading v-if="loading" :lines="2" class="h-auto pt-2 pb-1" />
  <gl-path v-else :key="selectedStage.id" :items="stages" @selected="$emit('selected', $event)">
    <template #default="{ pathItem, pathId }">
      <gl-popover
        v-if="showPopover(pathItem)"
        v-bind="$options.popoverOptions"
        :target="pathId"
        data-testid="stage-item-popover"
      >
        <template #title>{{ pathItem.title }}</template>
        <div class="gl-display-table">
          <div v-if="pathItem.startEventHtmlDescription" class="gl-display-table-row">
            <div class="gl-display-table-cell gl-pr-4 gl-pb-4">
              {{ s__('ValueStreamEvent|Start') }}
            </div>
            <div
              v-safe-html="pathItem.startEventHtmlDescription"
              class="gl-display-table-cell gl-pb-4 stage-event-description"
            ></div>
          </div>
          <div v-if="pathItem.endEventHtmlDescription" class="gl-display-table-row">
            <div class="gl-display-table-cell gl-pr-4">{{ s__('ValueStreamEvent|Stop') }}</div>
            <div
              v-safe-html="pathItem.endEventHtmlDescription"
              class="gl-display-table-cell stage-event-description"
            ></div>
          </div>
        </div>
      </gl-popover>
    </template>
  </gl-path>
</template>
