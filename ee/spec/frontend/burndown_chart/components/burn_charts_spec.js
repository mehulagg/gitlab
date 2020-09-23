import { shallowMount } from '@vue/test-utils';
import { GlButton } from '@gitlab/ui';
import BurnCharts from 'ee/burndown_chart/components/burn_charts.vue';
import BurndownChart from 'ee/burndown_chart/components/burndown_chart.vue';
import BurnupChart from 'ee/burndown_chart/components/burnup_chart.vue';
import { useFakeDate } from 'helpers/fake_date';
import { day1, day2, day3, day4 } from '../mock_data';

describe('burndown_chart', () => {
  let wrapper;

  const findChartsTitle = () => wrapper.find({ ref: 'chartsTitle' });
  const findIssuesButton = () => wrapper.find({ ref: 'totalIssuesButton' });
  const findWeightButton = () => wrapper.find({ ref: 'totalWeightButton' });
  const findActiveButtons = () =>
    wrapper.findAll(GlButton).filter(button => button.attributes().category === 'primary');
  const findBurndownChart = () => wrapper.find(BurndownChart);
  const findBurnupChart = () => wrapper.find(BurnupChart);

  const defaultProps = {
    startDate: '2019-08-07',
    dueDate: '2019-09-09',
    openIssuesCount: [],
    openIssuesWeight: [],
  };

  const createComponent = ({ props = {}, featureEnabled = false } = {}) => {
    wrapper = shallowMount(BurnCharts, {
      propsData: {
        ...defaultProps,
        ...props,
      },
      provide: {
        glFeatures: { burnupCharts: featureEnabled },
      },
    });
  };

  it('includes Issues and Issue weight buttons', () => {
    createComponent();

    expect(findIssuesButton().text()).toBe('Issues');
    expect(findWeightButton().text()).toBe('Issue weight');
  });

  it('defaults to total issues', () => {
    createComponent();

    expect(findActiveButtons()).toHaveLength(1);
    expect(
      findActiveButtons()
        .at(0)
        .text(),
    ).toBe('Issues');
    expect(findBurndownChart().props('issuesSelected')).toBe(true);
  });

  it('toggles Issue weight', async () => {
    createComponent();

    findWeightButton().vm.$emit('click');

    await wrapper.vm.$nextTick();

    expect(findActiveButtons()).toHaveLength(1);
    expect(
      findActiveButtons()
        .at(0)
        .text(),
    ).toBe('Issue weight');
    expect(findBurndownChart().props('issuesSelected')).toBe(false);
  });

  describe('feature disabled', () => {
    beforeEach(() => {
      createComponent({ featureEnabled: false });
    });

    it('does not reduce width of burndown chart', () => {
      expect(findBurndownChart().classes()).toEqual([]);
    });

    it('sets section title and chart title correctly', () => {
      expect(findChartsTitle().text()).toBe('Burndown chart');
      expect(findBurndownChart().props().showTitle).toBe(false);
    });
  });

  describe('feature enabled', () => {
    beforeEach(() => {
      createComponent({ featureEnabled: true });
    });

    it('reduces width of burndown chart', () => {
      expect(findBurndownChart().classes()).toContain('col-md-6');
    });

    it('sets section title and chart title correctly', () => {
      expect(findChartsTitle().text()).toBe('Charts');
      expect(findBurndownChart().props().showTitle).toBe(true);
    });

    it('sets weight prop of burnup chart', async () => {
      findWeightButton().vm.$emit('click');

      await wrapper.vm.$nextTick();

      expect(findBurnupChart().props('issuesSelected')).toBe(false);
    });
  });

  // some separate tests for the update function since it has a bunch of logic
  describe('padSparseBurnupData function', () => {
    function fakeDate({ date }) {
      const [year, month, day] = date.split('-');

      useFakeDate(year, month - 1, day);
    }

    beforeEach(() => {
      createComponent({
        props: { startDate: day1.date, dueDate: day4.date },
        featureEnabled: true,
      });

      fakeDate(day4);
    });

    it('pads data from startDate if no startDate values', () => {
      const result = wrapper.vm.padSparseBurnupData([day2, day3, day4]);

      expect(result.length).toBe(4);
      expect(result[0]).toEqual({
        date: day1.date,
        completedCount: 0,
        completedWeight: 0,
        scopeCount: 0,
        scopeWeight: 0,
      });
    });

    it('if dueDate is in the past, pad data using last existing value', () => {
      const result = wrapper.vm.padSparseBurnupData([day1, day2]);

      expect(result.length).toBe(4);
      expect(result[2]).toEqual({
        ...day2,
        date: day3.date,
      });
      expect(result[3]).toEqual({
        ...day2,
        date: day4.date,
      });
    });

    it('if dueDate is in the future, pad data up to current date using last existing value', () => {
      fakeDate(day3);

      const result = wrapper.vm.padSparseBurnupData([day1, day2]);

      expect(result.length).toBe(3);
      expect(result[2]).toEqual({
        ...day2,
        date: day3.date,
      });
    });

    it('pads missing days with data from previous days', () => {
      const result = wrapper.vm.padSparseBurnupData([day1, day4]);

      expect(result.length).toBe(4);
      expect(result[1]).toEqual({
        ...day1,
        date: day2.date,
      });
      expect(result[2]).toEqual({
        ...day1,
        date: day3.date,
      });
    });
  });
});
