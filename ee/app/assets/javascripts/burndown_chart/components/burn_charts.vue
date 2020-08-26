<script>
import { GlButton, GlButtonGroup } from '@gitlab/ui';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import { __ } from '~/locale';
import BurndownChart from './burndown_chart.vue';
import BurnupChart from './burnup_chart.vue';

export default {
  components: {
    GlButton,
    GlButtonGroup,
    BurndownChart,
    BurnupChart,
  },
  mixins: [glFeatureFlagsMixin()],
  props: {
    startDate: {
      type: String,
      required: true,
    },
    dueDate: {
      type: String,
      required: true,
    },
    openIssuesCount: {
      type: Array,
      required: false,
      default: () => [],
    },
    openIssuesWeight: {
      type: Array,
      required: false,
      default: () => [],
    },
    burnupScope: {
      type: Array,
      required: false,
      default: () => [],
    },
  },
  data() {
    return {
      issuesSelected: true,
    };
  },
  computed: {
    title() {
      return this.glFeatures.burnupCharts ? __('Charts') : __('Burndown chart');
    },
    issueButtonCategory() {
      return this.issuesSelected ? 'primary' : 'secondary';
    },
    weightButtonCategory() {
      return this.issuesSelected ? 'secondary' : 'primary';
    },
  },
  methods: {
    setIssueSelected(selected) {
      this.issuesSelected = selected;
    },
  },

  emits: [],
};
</script>

<template>
  <div>
    <div class="burndown-header d-flex align-items-center">
      <h3 ref="chartsTitle">{{ title }}</h3>
      <gl-button-group class="ml-3 js-burndown-data-selector">
        <gl-button
          ref="totalIssuesButton"
          :category="issueButtonCategory"
          variant="info"
          size="small"
          @click="setIssueSelected(true)"
        >
          {{ __('Issues') }}
        </gl-button>
        <gl-button
          ref="totalWeightButton"
          :category="weightButtonCategory"
          variant="info"
          size="small"
          data-qa-selector="weight_button"
          @click="setIssueSelected(false)"
        >
          {{ __('Issue weight') }}
        </gl-button>
      </gl-button-group>
    </div>
    <div v-if="glFeatures.burnupCharts" class="row">
      <burndown-chart
        :start-date="startDate"
        :due-date="dueDate"
        :open-issues-count="openIssuesCount"
        :open-issues-weight="openIssuesWeight"
        :issues-selected="issuesSelected"
        class="col-md-6"
      />
      <burnup-chart
        :start-date="startDate"
        :due-date="dueDate"
        :scope="burnupScope"
        class="col-md-6"
      />
    </div>
    <burndown-chart
      v-else
      :show-title="false"
      :start-date="startDate"
      :due-date="dueDate"
      :open-issues-count="openIssuesCount"
      :open-issues-weight="openIssuesWeight"
      :issues-selected="issuesSelected"
    />
  </div>
</template>
