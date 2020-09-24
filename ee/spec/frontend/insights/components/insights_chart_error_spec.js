import InsightsChartError from 'ee/insights/components/insights_chart_error.vue';
import { shallowMount } from '@vue/test-utils';

describe('Insights chart error component', () => {
  const chartName = 'Test chart';
  const title = 'This chart could not be displayed';
  const summary = 'Please check the configuration file for this chart';
  const error = 'Test error';

  let wrapper;

  beforeEach(() => {
    wrapper = shallowMount(InsightsChartError, {
      propsData: { chartName, title, summary, error },
    });
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders the component', () => {
    expect(wrapper.find('.content-title').text()).toBe(`${title}: "${chartName}"`);

    const summaries = wrapper.findAll('.content-summary');

    expect(summaries.at(0).text()).toBe(summary);
    expect(summaries.at(1).text()).toBe(error);
  });
});
