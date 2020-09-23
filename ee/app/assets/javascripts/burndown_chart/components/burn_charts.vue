<script>
import { GlAlert, GlButton, GlButtonGroup } from '@gitlab/ui';
import dateFormat from 'dateformat';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import { __ } from '~/locale';
import { getDayDifference, nDaysAfter, newDateAsLocaleTime } from '~/lib/utils/datetime_utility';
import BurndownChart from './burndown_chart.vue';
import BurnupChart from './burnup_chart.vue';
import BurnupQuery from '../queries/burnup.query.graphql';

export default {
  components: {
    GlAlert,
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
    milestoneId: {
      type: String,
      required: false,
      default: '',
    },
  },
  apollo: {
    burnupData: {
      skip() {
        return !this.glFeatures.burnupCharts || !this.milestoneId;
      },
      query: BurnupQuery,
      variables() {
        return {
          milestoneId: this.milestoneId,
        };
      },
      update(data) {
        const sparseBurnupData = data?.milestone?.burnupTimeSeries || [];

        return this.padSparseBurnupData(sparseBurnupData);
      },
      error() {
        this.error = __('Error fetching burnup chart data');
      },
    },
  },
  data() {
    return {
      issuesSelected: true,
      burnupData: [],
      error: '',
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
    padSparseBurnupData(sparseBurnupData) {
      // if we don't have data for the startDate, we still want to draw a point at 0
      // on the chart, so add an item to the start of the array
      const hasDataForStartDate = sparseBurnupData.find(d => d.date === this.startDate);
      if (!hasDataForStartDate) {
        sparseBurnupData.unshift({
          date: this.startDate,
          completedCount: 0,
          completedWeight: 0,
          scopeCount: 0,
          scopeWeight: 0,
        });
      }

      // chart runs to dueDate or the current date, whichever is earlier
      const lastDate = dateFormat(
        Math.min(Date.parse(this.dueDate), Date.parse(new Date())),
        'yyyy-mm-dd',
      );
      // similar to the startDate padding, if we don't have a value for the
      // last item in the array, we should add one. If no events occur on
      // a day then we don't get any data for that day in the response
      const hasDataForLastDate = sparseBurnupData.find(d => d.date === lastDate);
      if (!hasDataForLastDate) {
        const lastItem = sparseBurnupData[sparseBurnupData.length - 1];
        sparseBurnupData.push({
          ...lastItem,
          date: lastDate,
        });
      }

      return sparseBurnupData.reduce(this.addMissingDates, []);
    },
    addMissingDates(acc, current) {
      const { date } = current;

      // we might not have data for every day in the timebox, as graphql
      // endpoint only returns days when events have happened
      // if the previous array item is >1 day, then fill in the gap
      // using the data from the previous entry.
      // example: [
      //   { date: '2020-08-01', count: 10 }
      //   { date: '2020-08-04', count: 12 }
      // ]
      // should be transformed to
      // example: [
      //   { date: '2020-08-01', count: 10 }
      //   { date: '2020-08-02', count: 10 }
      //   { date: '2020-08-03', count: 10 }
      //   { date: '2020-08-04', count: 12 }
      // ]

      // skip the start date since we have no previous values
      if (date !== this.startDate) {
        const { date: prevDate, ...previousValues } = acc[acc.length - 1] || {};

        const currentDateUTC = newDateAsLocaleTime(date);
        const prevDateUTC = newDateAsLocaleTime(prevDate);

        const gap = getDayDifference(prevDateUTC, currentDateUTC);

        for (let i = 1; i < gap; i += 1) {
          acc.push({
            date: dateFormat(nDaysAfter(prevDateUTC, i), 'yyyy-mm-dd'),
            ...previousValues,
          });
        }
      }

      acc.push(current);

      return acc;
    },
  },
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
      <gl-alert v-if="error" variant="danger" class="col-12" @dismiss="error = ''">
        {{ error }}
      </gl-alert>
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
        :burnup-data="burnupData"
        :issues-selected="issuesSelected"
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
