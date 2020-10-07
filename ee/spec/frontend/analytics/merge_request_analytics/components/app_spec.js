import { shallowMount } from '@vue/test-utils';
import MergeRequestAnalyticsApp from 'ee/analytics/merge_request_analytics/components/app.vue';
import DateRange from 'ee/analytics/shared/components/daterange.vue';
import FilterBar from 'ee/analytics/merge_request_analytics/components/filter_bar.vue';
import ThroughputChart from 'ee/analytics/merge_request_analytics/components/throughput_chart.vue';
import ThroughputTable from 'ee/analytics/merge_request_analytics/components/throughput_table.vue';

describe('MergeRequestAnalyticsApp', () => {
  let wrapper;

  function createComponent() {
    wrapper = shallowMount(MergeRequestAnalyticsApp);
  }

  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('displays the page title', () => {
    const pageTitle = wrapper.find('[data-testid="pageTitle"').text();

    expect(pageTitle).toBe('Merge Request Analytics');
  });

  it('displays the filter bar component', () => {
    expect(wrapper.find(FilterBar).exists()).toBe(true);
  });

  it('displays the date range component', () => {
    expect(wrapper.find(DateRange).exists()).toBe(true);
  });

  it('displays the throughput chart component', () => {
    expect(wrapper.find(ThroughputChart).exists()).toBe(true);
  });

  it('displays the throughput table component', () => {
    expect(wrapper.find(ThroughputTable).exists()).toBe(true);
  });
});
