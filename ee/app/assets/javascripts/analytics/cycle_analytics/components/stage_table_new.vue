<script>
import { GlEmptyState, GlIcon, GlLink, GlLoadingIcon, GlTable } from '@gitlab/ui';
import { __ } from '~/locale';
import { NOT_ENOUGH_DATA_ERROR } from '../constants';
import TotalTime from './total_time_component.vue';

export default {
  name: 'StageTableNew',
  components: {
    GlEmptyState,
    GlIcon,
    GlLink,
    GlLoadingIcon,
    GlTable,
    TotalTime,
  },
  props: {
    currentStage: {
      type: Object,
      required: true,
    },
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
  computed: {
    isEmptyStage() {
      return !this.stageEvents.length;
    },
    emptyStateTitle() {
      const { emptyStateMessage } = this;
      return emptyStateMessage || NOT_ENOUGH_DATA_ERROR;
    },
    withBuildStatus() {
      const { currentStage } = this;
      return !currentStage.custom && currentStage.name.toLowerCase().trim() === 'test';
    },
  },
  methods: {
    isMrLink(url = '') {
      return url.includes('/merge_request');
    },
    itemTitle(item) {
      return item.title || item.name;
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
    <gl-empty-state v-else-if="isEmptyStage" :title="emptyStateTitle" :svg-path="noDataSvgPath" />
    <gl-table
      v-else
      head-variant="white"
      stacked="lg"
      thead-class="border-bottom"
      show-empty
      :fields="$options.fields"
      :items="stageEvents"
      :empty-text="emptyStateMessage"
    >
      <template #cell(issues)="{ item }">
        <div data-testid="vsa-stage-event">
          <div v-if="item.id" data-testid="vsa-stage-content">
            <p class="gl-m-0">
              <template v-if="withBuildStatus">
                <span
                  class="icon-build-status gl-vertical-align-middle gl-text-green-500"
                  data-testid="vsa-stage-event-build-status"
                >
                  <gl-icon name="status_success" :size="14" />
                </span>
                <gl-link
                  class="gl-text-black-normal item-build-name"
                  data-testid="vsa-stage-event-build-name"
                  :href="item.url"
                >
                  {{ item.name }}
                </gl-link>
                &middot;
              </template>
              <gl-link class="gl-text-black-normal pipeline-id" :href="item.url"
                >#{{ item.id }}</gl-link
              >
              <gl-icon :size="16" name="fork" />
              <gl-link
                v-if="item.branch"
                :href="item.branch.url"
                class="gl-text-black-normal ref-name"
                >{{ item.branch.name }}</gl-link
              >
              <span class="icon-branch gl-text-gray-400">
                <gl-icon name="commit" :size="14" />
              </span>
              <gl-link
                class="commit-sha"
                :href="item.commitUrl"
                data-testid="vsa-stage-event-build-sha"
                >{{ item.shortSha }}</gl-link
              >
            </p>
            <p class="gl-m-0">
              <span v-if="withBuildStatus" data-testid="vsa-stage-event-build-status-date">
                <gl-link class="gl-text-black-normal issue-date" :href="item.url">{{
                  item.date
                }}</gl-link>
              </span>
              <span v-else data-testid="vsa-stage-event-build-author-and-date">
                <gl-link class="gl-text-black-normal build-date" :href="item.url">{{
                  item.date
                }}</gl-link>
                {{ s__('ByAuthor|by') }}
                <gl-link
                  class="gl-text-black-normal issue-author-link"
                  :href="item.author.webUrl"
                  >{{ item.author.name }}</gl-link
                >
              </span>
            </p>
          </div>
          <div v-else data-testid="vsa-stage-content">
            <h5 class="gl-font-weight-bold gl-my-1" data-testid="vsa-stage-event-title">
              <gl-link class="gl-text-black-normal" :href="item.url">{{ itemTitle(item) }}</gl-link>
            </h5>
            <p class="gl-m-0">
              <template v-if="isMrLink(item.url)">
                <gl-link class="gl-text-black-normal" :href="item.url">!{{ item.iid }}</gl-link>
              </template>
              <template v-else>
                <gl-link class="gl-text-black-normal" :href="item.url">#{{ item.iid }}</gl-link>
              </template>
              <span class="gl-font-lg">&middot;</span>
              <span data-testid="vsa-stage-event-date">
                {{ s__('OpenedNDaysAgo|Opened') }}
                <gl-link class="gl-text-black-normal" :href="item.url">{{
                  item.createdAt
                }}</gl-link>
              </span>
              <span data-testid="vsa-stage-event-author">
                {{ s__('ByAuthor|by') }}
                <gl-link class="gl-text-black-normal" :href="item.author.webUrl">{{
                  item.author.name
                }}</gl-link>
              </span>
            </p>
          </div>
        </div>
      </template>
      <template #cell(time)="{ item }">
        <total-time :time="item.totalTime" data-testid="vsa-stage-event-time" />
      </template>
    </gl-table>
  </div>
</template>
