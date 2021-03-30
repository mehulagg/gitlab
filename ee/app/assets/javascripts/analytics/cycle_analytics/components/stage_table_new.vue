<script>
import { GlLink, GlLoadingIcon, GlTable } from '@gitlab/ui';
import { __ } from '~/locale';
import TotalTime from './total_time_component.vue';
// import { GlTooltipDirective, GlLoadingIcon, GlEmptyState } from '@gitlab/ui';

export default {
  name: 'StageTable',
  components: {
    GlLink,
    GlLoadingIcon,
    GlTable,
    TotalTime,
    // GlEmptyState,
  },
  props: {
    isLoading: {
      type: Boolean,
      required: true,
    },
    stageEvents: {
      type: Array,
      required: true,
    },
    noDataSvgPath: {
      type: String,
      required: true,
    },
    emptyStateMessage: {
      type: String,
      required: false,
      default: '',
    },
  },
  data() {
    return {};
  },
  computed: {
    isEmptyStage() {
      return !this.stageEvents.length;
    },
  },
  methods: {
    isMrLink(url = '') {
      return url.includes('/merge_request');
    },
  },
  fields: [
    { key: 'issues', label: __('Issues'), thClass: 'gl-w-half' },
    { key: 'time', label: __('Time'), thClass: 'gl-w-half' },
  ],
};
</script>
<template>
  <div data-testid="vsa-stage-table">
    <gl-loading-icon v-if="isLoading" class="gl-mt-4" size="md" />
    <gl-table v-else :fields="$options.fields" :items="stageEvents">
      <template #cell(issues)="{ item }">
        <h5>
          <gl-link :href="item.url">{{ item.title }}</gl-link>
        </h5>
        <ul class="gl-list-style-none">
          <li>
            <template v-if="isMrLink(item.url)">
              <gl-link :href="item.url">!{{ item.iid }}</gl-link>
            </template>
            <template v-else>
              <gl-link :href="item.url">#{{ item.iid }}</gl-link>
            </template>
            &middot;
            <span>
              {{ s__('OpenedNDaysAgo|Opened') }}
              <gl-link :href="item.url">{{ item.createdAt }}</gl-link>
            </span>
            <span>
              {{ s__('ByAuthor|by') }}
              <gl-link :href="item.author.webUrl">{{ item.author.name }}</gl-link>
            </span>
          </li>
        </ul>
      </template>
      <template #cell(time)="{ item }">
        <!-- TODO: update the total time function to use the rounding units for the path nav -->
        <total-time :time="item.totalTime" />
      </template>
    </gl-table>
  </div>
</template>
