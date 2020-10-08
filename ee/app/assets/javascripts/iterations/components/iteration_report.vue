<script>
/* eslint-disable vue/no-v-html */
import {
  GlAlert,
  GlBadge,
  GlLoadingIcon,
  GlEmptyState,
  GlIcon,
  GlDropdown,
  GlDropdownItem,
} from '@gitlab/ui';
import BurnCharts from 'ee/burndown_chart/components/burn_charts.vue';
import { formatDate } from '~/lib/utils/datetime_utility';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import { __ } from '~/locale';
import IterationReportSummary from './iteration_report_summary.vue';
import IterationForm from './iteration_form.vue';
import IterationReportTabs from './iteration_report_tabs.vue';
import query from '../queries/iteration.query.graphql';
import { Namespace } from '../constants';

const iterationStates = {
  closed: 'closed',
  upcoming: 'upcoming',
  expired: 'expired',
};

const page = {
  view: 'viewIteration',
  edit: 'editIteration',
};

export default {
  components: {
    BurnCharts,
    GlAlert,
    GlBadge,
    GlLoadingIcon,
    GlEmptyState,
    GlIcon,
    GlDropdown,
    GlDropdownItem,
    IterationForm,
    IterationReportSummary,
    IterationReportTabs,
  },
  apollo: {
    iteration: {
      query,
      variables() {
        return {
          fullPath: this.fullPath,
          id: `gid://gitlab/Iteration/${this.iterationId}`,
          iid: this.iterationIid,
          hasId: Boolean(this.iterationId),
          hasIid: Boolean(this.iterationIid),
        };
      },
      update(data) {
        return data.group?.iterations?.nodes[0] || data.iteration || {};
      },
      error(err) {
        this.error = err.message;
      },
    },
  },
  mixins: [glFeatureFlagsMixin()],
  props: {
    fullPath: {
      type: String,
      required: true,
    },
    iterationId: {
      type: String,
      required: false,
      default: undefined,
    },
    iterationIid: {
      type: String,
      required: false,
      default: undefined,
    },
    canEdit: {
      type: Boolean,
      required: false,
      default: false,
    },
    initiallyEditing: {
      type: Boolean,
      required: false,
      default: false,
    },
    namespaceType: {
      type: String,
      required: false,
      default: Namespace.Group,
      validator: value => Object.values(Namespace).includes(value),
    },
    previewMarkdownPath: {
      type: String,
      required: false,
      default: '',
    },
  },
  data() {
    return {
      isEditing: this.initiallyEditing,
      error: '',
      iteration: {},
    };
  },
  computed: {
    canEditIteration() {
      return this.canEdit && this.namespaceType === Namespace.Group;
    },
    hasIteration() {
      return !this.$apollo.queries.iteration.loading && this.iteration?.title;
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
  mounted() {
    this.boundOnPopState = this.onPopState.bind(this);
    window.addEventListener('popstate', this.boundOnPopState);
  },
  beforeDestroy() {
    window.removeEventListener('popstate', this.boundOnPopState);
  },
  methods: {
    onPopState(e) {
      if (e.state?.prev === page.view) {
        this.isEditing = true;
      } else if (e.state?.prev === page.edit) {
        this.isEditing = false;
      } else {
        this.isEditing = this.initiallyEditing;
      }
    },
    formatDate(date) {
      return formatDate(date, 'mmm d, yyyy', true);
    },
    loadEditPage() {
      this.isEditing = true;
      const newUrl = window.location.pathname.replace(/(\/edit)?\/?$/, '/edit');
      window.history.pushState({ prev: page.view }, null, newUrl);
    },
    loadReportPage() {
      this.isEditing = false;
      const newUrl = window.location.pathname.replace(/\/edit$/, '');
      window.history.pushState({ prev: page.edit }, null, newUrl);
    },
  },
};
</script>

<template>
  <div>
    <gl-alert v-if="error" variant="danger" @dismiss="error = ''">
      {{ error }}
    </gl-alert>
    <gl-loading-icon v-if="$apollo.queries.iteration.loading" class="gl-py-5" size="lg" />
    <gl-empty-state
      v-else-if="!hasIteration"
      :title="__('Could not find iteration')"
      :compact="false"
    />
    <iteration-form
      v-else-if="isEditing"
      :group-path="fullPath"
      :preview-markdown-path="previewMarkdownPath"
      :is-editing="true"
      :iteration="iteration"
      @updated="loadReportPage"
      @cancel="loadReportPage"
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
        <gl-dropdown
          v-if="canEditIteration"
          data-testid="actions-dropdown"
          variant="default"
          toggle-class="gl-text-decoration-none gl-border-0! gl-shadow-none!"
          class="gl-ml-auto gl-text-secondary"
          right
          no-caret
        >
          <template #button-content>
            <gl-icon name="ellipsis_v" /><span class="gl-sr-only">{{ __('Actions') }}</span>
          </template>
          <gl-dropdown-item @click="loadEditPage">{{ __('Edit iteration') }}</gl-dropdown-item>
        </gl-dropdown>
      </div>
      <h3 ref="title" class="page-title">{{ iteration.title }}</h3>
      <div ref="description" v-html="iteration.descriptionHtml"></div>
      <iteration-report-summary
        :full-path="fullPath"
        :iteration-id="iteration.id"
        :namespace-type="namespaceType"
      />
      <burn-charts
        v-if="glFeatures.burnupCharts"
        :start-date="iteration.startDate"
        :due-date="iteration.dueDate"
        :iteration-id="iteration.id"
      />
      <iteration-report-tabs
        :full-path="fullPath"
        :iteration-id="iteration.id"
        :namespace-type="namespaceType"
      />
    </template>
  </div>
</template>
