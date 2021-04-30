<script>
import { GlBadge, GlTable, GlLink } from '@gitlab/ui';
import { GlSingleStat } from '@gitlab/ui/dist/charts';
import { sprintf, s__ } from '~/locale';

const defaultHeaderAttrs = {
  thClass: 'gl-bg-white!',
  thAttr: { 'data-testid': 'header' },
};

export default {
  components: {
    GlBadge,
    GlTable,
    GlSingleStat,
    GlLink,
  },
  inject: {
    devopsScoreMetrics: {
      default: null,
    },
    isEmpty: {
      default: false,
    },
    devOpsReportDocsPath: {
      default: '',
    },
  },
  computed: {
    titleHelperText() {
      return sprintf(
        s__(
          'DevopsReport|DevOps score metrics are based on usage over the last 30 days. Last updated: %{timestamp}.',
        ),
        { timestamp: this.devopsScoreMetrics.createdAt },
      );
    },
  },
  tableHeaderFields: [
    {
      key: 'title',
      label: '',
      ...defaultHeaderAttrs,
    },
    {
      key: 'usage',
      label: s__('DevopsReport|Your usage'),
      ...defaultHeaderAttrs,
    },
    {
      key: 'leadInstance',
      label: s__('DevopsReport|Leader usage'),
      ...defaultHeaderAttrs,
    },
    {
      key: 'score',
      label: s__('DevopsReport|Score'),
      ...defaultHeaderAttrs,
    },
  ],
};
</script>
<template>
  <div v-if="isEmpty" class="container devops-empty">
    <div class="col-sm-12 justify-content-center text-center">
      <!-- = custom_icon('dev_ops_report_no_data') -->
      <!-- %h4= _('Data is still calculating...') -->
      <p>
        {{ __('It may be several days before you see feature usage data.') }}
        <gl-link :href="devOpsReportDocsPath">{{
          __('Our documentation includes an example DevOps Score report.')
        }}</gl-link>
      </p>
    </div>
  </div>
  <div v-else data-testid="devops-score-app">
    <div class="gl-text-gray-400 gl-my-4" data-testid="devops-score-note-text">
      {{ titleHelperText }}
    </div>
    <gl-single-stat
      unit="%"
      size="sm"
      :title="s__('DevopsReport|Your score')"
      :should-animate="true"
      :value="devopsScoreMetrics.averageScore.value"
      :meta-icon="devopsScoreMetrics.averageScore.scoreLevel.icon"
      :meta-text="devopsScoreMetrics.averageScore.scoreLevel.label"
      :variant="devopsScoreMetrics.averageScore.scoreLevel.variant"
    />
    <gl-table
      :fields="$options.tableHeaderFields"
      :items="devopsScoreMetrics.cards"
      thead-class="gl-border-t-0 gl-border-b-solid gl-border-b-1 gl-border-b-gray-100"
      stacked="sm"
    >
      <template #cell(usage)="{ item }">
        <div data-testid="usageCol">
          <span>{{ item.usage }}</span>
          <gl-badge :variant="item.scoreLevel.variant" size="sm" class="gl-ml-1">{{
            item.scoreLevel.label
          }}</gl-badge>
        </div>
      </template>
    </gl-table>
  </div>
</template>
