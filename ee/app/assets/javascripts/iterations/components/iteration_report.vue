<script>
import {
  GlAlert,
  GlBadge,
  GlLoadingIcon,
  GlEmptyState,
  GlIcon,
  GlNewDropdown,
  GlNewDropdownItem,
} from '@gitlab/ui';
import { formatDate } from '~/lib/utils/datetime_utility';
import { __ } from '~/locale';
import IterationReportSummary from './iteration_report_summary.vue';
import IterationForm from './iteration_form.vue';
import IterationReportTabs from './iteration_report_tabs.vue';
import query from '../queries/group_iteration.query.graphql';

const iterationStates = {
  closed: 'closed',
  upcoming: 'upcoming',
  expired: 'expired',
};

export default {
  components: {
    GlAlert,
    GlBadge,
    GlLoadingIcon,
    GlEmptyState,
    GlIcon,
    GlNewDropdown,
    GlNewDropdownItem,
    IterationForm,
    IterationReportSummary,
    IterationReportTabs,
  },
  apollo: {
    namespace: {
      query,
      variables() {
        return {
          groupPath: this.fullPath,
          iid: this.iterationIid,
        };
      },
      update(data) {
        const iteration = data?.group?.iterations?.nodes[0] || {};

        return {
          iteration,
        };
      },
      error(err) {
        this.error = err.message;
      },
    },
  },
  props: {
    fullPath: {
      type: String,
      required: true,
    },
    iterationIid: {
      type: String,
      required: true,
    },
    canEdit: {
      type: Boolean,
      required: false,
      default: false,
    },
    previewMarkdownPath: {
      type: String,
      required: false,
      default: '',
    },
  },
  data() {
    return {
      isEditing: false,
      error: '',
      namespace: {
        iteration: {},
      },
    };
  },
  computed: {
    iteration() {
      return this.namespace.iteration;
    },
    hasIteration() {
      return !this.$apollo.queries.namespace.loading && this.iteration?.title;
    },
    status() {
      switch (this.iteration.state) {
        case iterationStates.closed:
          return {
            text: __('Closed'),
            variant: 'danger',
          };
        case iterationStates.expired:
          return { text: __('Past due'), variant: 'warning' };
        case iterationStates.upcoming:
          return { text: __('Upcoming'), variant: 'neutral' };
        default:
          return { text: __('Open'), variant: 'success' };
      }
    },
  },
  methods: {
    formatDate(date) {
      return formatDate(date, 'mmm d, yyyy', true);
    },
  },

  emits: [],
};
</script>

<template>
  <div>
    <gl-alert v-if="error" variant="danger" @dismiss="error = ''">
      {{ error }}
    </gl-alert>
    <gl-loading-icon v-if="$apollo.queries.namespace.loading" class="gl-py-5" size="lg" />
    <gl-empty-state
      v-else-if="!hasIteration"
      :title="__('Could not find iteration')"
      :compact="false"
    />
    <iteration-form
      v-else-if="isEditing"
      :group-path="fullPath"
      :is-editing="true"
      :iteration="iteration"
      :preview-markdown-path="previewMarkdownPath"
      @updated="isEditing = false"
      @cancel="isEditing = false"
    />
    <template v-else>
      <div
        ref="topbar"
        class="gl-display-flex gl-justify-items-center gl-align-items-center gl-py-3 gl-border-1 gl-border-b-solid gl-border-gray-100"
      >
        <gl-badge :variant="status.variant">
          {{ status.text }}
        </gl-badge>
        <span class="gl-ml-4"
          >{{ formatDate(iteration.startDate) }} – {{ formatDate(iteration.dueDate) }}</span
        >
        <gl-new-dropdown
          v-if="canEdit"
          variant="default"
          toggle-class="gl-text-decoration-none gl-border-0! gl-shadow-none!"
          class="gl-ml-auto gl-text-secondary"
          right
          no-caret
        >
          <template #button-content>
            <gl-icon name="ellipsis_v" /><span class="gl-sr-only">{{ __('Actions') }}</span>
          </template>
          <gl-new-dropdown-item @click="isEditing = true">{{
            __('Edit iteration')
          }}</gl-new-dropdown-item>
        </gl-new-dropdown>
      </div>
      <h3 ref="title" class="page-title">{{ iteration.title }}</h3>
      <div ref="description" v-html="iteration.descriptionHtml"></div>
      <iteration-report-summary :group-path="fullPath" :iteration-id="iteration.id" />
      <iteration-report-tabs :group-path="fullPath" :iteration-id="iteration.id" />
    </template>
  </div>
</template>
