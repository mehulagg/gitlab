import { GlButton } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';
import BurnCharts from 'ee/burndown_chart/components/burn_charts.vue';
import BurndownChart from 'ee/burndown_chart/components/burndown_chart.vue';
import BurnupChart from 'ee/burndown_chart/components/burnup_chart.vue';
import { useFakeDate } from 'helpers/fake_date';
import waitForPromises from 'helpers/wait_for_promises';
import { day1, day2, day3, day4, legacyBurndownEvents } from '../mock_data';

function fakeDate({ date }) {
  const [year, month, day] = date.split('-');

  useFakeDate(year, month - 1, day);
}

describe('burndown_chart', () => {
  let wrapper;
  let mock;

  const findChartsTitle = () => wrapper.find({ ref: 'chartsTitle' });
  const findIssuesButton = () => wrapper.find({ ref: 'totalIssuesButton' });
  const findWeightButton = () => wrapper.find({ ref: 'totalWeightButton' });
  const findActiveButtons = () =>
    wrapper.findAll(GlButton).filter(button => button.attributes().category === 'primary');
  const findBurndownChart = () => wrapper.find(BurndownChart);
  const findBurnupChart = () => wrapper.find(BurnupChart);
  const findOldBurndownChartButton = () => wrapper.find({ ref: 'oldBurndown' });
  const findNewBurndownChartButton = () => wrapper.find({ ref: 'newBurndown' });

  const defaultProps = {
    startDate: '2020-08-07',
    dueDate: '2020-09-09',
    openIssuesCount: [],
    openIssuesWeight: [],
    burndownEventsPath: '/api/v4/projects/1234/milestones/1/burndown_events',
  };

  const createComponent = ({ props = {}, featureEnabled = false, data = {} } = {}) => {
    wrapper = shallowMount(BurnCharts, {
      propsData: {
        ...defaultProps,
        ...props,
      },
      data() {
        return data;
      },
      provide: {
        glFeatures: { burnupCharts: featureEnabled },
      },
    });
  };

  beforeEach(() => {
    mock = new MockAdapter(axios);
  });

  afterEach(() => {
    mock.restore();
  });

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
      fakeDate(day4);
      mock.onGet(defaultProps.burndownEventsPath).reply(200, legacyBurndownEvents);
      createComponent({ featureEnabled: false });
    });

    it('calls fetchLegacyBurndownEvents when mounted', async () => {
      await waitForPromises();

      await wrapper.vm.$nextTick();
      await wrapper.vm.$nextTick();

      expect(findBurndownChart().props().openIssuesCount).toEqual([
        [defaultProps.startDate, 0],
        [day1.date, 1],
        [day2.date, 2],
        [day3.date, 3],
        [day4.date, 2],
      ]);

      expect(findBurndownChart().props().openIssuesWeight).toEqual([
        [defaultProps.startDate, 0],
        [day1.date, 2],
        [day2.date, 3],
        [day3.date, 4],
        [day4.date, 2],
      ]);
    });

    it('does not reduce width of burndown chart', () => {
      expect(findBurndownChart().classes()).toEqual([]);
    });

    it('sets section title and chart title correctly', () => {
      expect(findChartsTitle().text()).toBe('Burndown chart');
      expect(findBurndownChart().props().showTitle).toBe(false);
    });

    it('does not show old/new burndown buttons', () => {
      expect(findOldBurndownChartButton().exists()).toBe(false);
      expect(findNewBurndownChartButton().exists()).toBe(false);
    });

    it('uses count and weight from data', () => {
      const expectedCount = [day2.date, day2.scopeCount];
      const expectedWeight = [day2.date, day2.scopeWeight];

      createComponent({
        data: {
          burnupData: [day1],
          openIssuesCount: [expectedCount],
          openIssuesWeight: [expectedWeight],
        },
        props: {
          milestoneId: '1234',
        },
        featureEnabled: false,
      });

      const { openIssuesCount, openIssuesWeight } = findBurndownChart().props();

      expect(openIssuesCount).toEqual([expectedCount]);
      expect(openIssuesWeight).toEqual([expectedWeight]);
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

    it('uses burndown data computed from burnup data', () => {
      createComponent({
        data: {
          burnupData: [day1],
        },
        featureEnabled: true,
      });
      const { openIssuesCount, openIssuesWeight } = findBurndownChart().props();

      const expectedCount = [day1.date, day1.scopeCount - day1.completedCount];
      const expectedWeight = [day1.date, day1.scopeWeight - day1.completedWeight];

      expect(openIssuesCount).toEqual([expectedCount]);
      expect(openIssuesWeight).toEqual([expectedWeight]);
    });
  });

  describe('showNewOldBurndownToggle', () => {
    it('hides old/new burndown buttons if feature disabled', () => {
      createComponent({ featureEnabled: false, props: { showNewOldBurndownToggle: true } });

      expect(findOldBurndownChartButton().exists()).toBe(false);
      expect(findNewBurndownChartButton().exists()).toBe(false);
    });

    it('hides old/new burndown buttons if props is false', () => {
      createComponent({ featureEnabled: true, props: { showNewOldBurndownToggle: false } });

      expect(findOldBurndownChartButton().exists()).toBe(false);
      expect(findNewBurndownChartButton().exists()).toBe(false);
    });

    it('shows old/new burndown buttons if prop true', () => {
      createComponent({ featureEnabled: true, props: { showNewOldBurndownToggle: true } });

      expect(findOldBurndownChartButton().exists()).toBe(true);
      expect(findNewBurndownChartButton().exists()).toBe(true);
    });

    it('calls fetchLegacyBurndownEvents, but only once', () => {
      createComponent({ featureEnabled: true, props: { showNewOldBurndownToggle: true } });
      jest.spyOn(wrapper.vm, 'fetchLegacyBurndownEvents');
      mock.onGet(defaultProps.burndownEventsPath).reply(200, []);

      findOldBurndownChartButton().vm.$emit('click');

      expect(wrapper.vm.fetchLegacyBurndownEvents).toHaveBeenCalledTimes(1);
    });
  });

  // some separate tests for the update function since it has a bunch of logic
  describe('padSparseBurnupData function', () => {
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
