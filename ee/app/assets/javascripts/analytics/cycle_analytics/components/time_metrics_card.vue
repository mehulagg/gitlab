<script>
import Api from 'ee/api';
import MetricCard from '~/analytics/shared/components/metric_card.vue';
import createFlash from '~/flash';
import { sprintf, __, s__ } from '~/locale';
import { OVERVIEW_METRICS } from '../constants';
import { removeFlash, prepareTimeMetricsData } from '../utils';

const I18N_TEXT = {
  'lead-time': s__('ValueStreamAnalytics|Median time from issue created to issue closed.'),
  'cycle-time': s__('ValueStreamAnalytics|Median time from first commit to issue closed.'),
};

const requestData = ({ requestType, groupPath, additionalParams }) => {
  return requestType === OVERVIEW_METRICS.TIME_SUMMARY
    ? Api.cycleAnalyticsTimeSummaryData(groupPath, additionalParams)
    : Api.cycleAnalyticsSummaryData(groupPath, additionalParams);
};

export default {
  name: 'TimeMetricsCard',
  components: {
    MetricCard,
  },
  props: {
    groupPath: {
      type: String,
      required: true,
    },
    additionalParams: {
      type: Object,
      required: false,
      default: () => ({}),
    },
    requestType: {
      type: String,
      required: true,
      validator: (t) => OVERVIEW_METRICS[t],
    },
  },
  data() {
    return {
      data: [],
      loading: false,
    };
  },
  watch: {
    additionalParams() {
      this.fetchData();
    },
  },
  mounted() {
    this.fetchData();
  },
  methods: {
    fetchData() {
      removeFlash();
      this.loading = true;
      return requestData(this)
        .then(({ data }) => {
          this.data = prepareTimeMetricsData(data, I18N_TEXT);
        })
        .catch(() => {
          const requestTypeName =
            this.requestType === OVERVIEW_METRICS.TIME_SUMMARY
              ? __('time summary')
              : __('recent activity');
          createFlash({
            message: sprintf(
              s__(
                'There was an error while fetching value stream analytics %{requestTypeName} data.',
              ),
              { requestTypeName },
            ),
          });
        })
        .finally(() => {
          this.loading = false;
        });
    },
  },
  render() {
    return this.$scopedSlots.default({
      metrics: this.data,
      loading: this.loading,
    });
  },
};
</script>
