import { GlLoadingIcon } from '@gitlab/ui';
import { GlLineChart } from '@gitlab/ui/dist/charts';
import { shallowMount, createLocalVue } from '@vue/test-utils';
import VueApollo from 'vue-apollo';
import DashboardNotConfigured from 'ee/security_dashboard/components/empty_states/reports_not_configured.vue';
import ProjectSecurityCharts from 'ee/security_dashboard/components/project_security_charts.vue';
import SecurityChartsLayout from 'ee/security_dashboard/components/security_charts_layout.vue';
import projectsHistoryQuery from 'ee/security_dashboard/graphql/queries/project_vulnerabilities_by_day_and_count.query.graphql';
import createMockApollo from 'jest/helpers/mock_apollo_helper';
import {
  mockProjectSecurityChartsWithData,
  mockProjectSecurityChartsWithoutData,
} from '../mock_data';

const localVue = createLocalVue();
localVue.use(VueApollo);

describe('Project Security Charts component', () => {
  let wrapper;

  const projectFullPath = 'project/path';
  const helpPath = 'docs/security/dashboard';

  const findLineChart = () => wrapper.find(GlLineChart);
  const findLoadingIcon = () => wrapper.find(GlLoadingIcon);
  const findEmptyState = () => wrapper.find(DashboardNotConfigured);

  const createApolloProvider = (...queries) => {
    return createMockApollo([...queries]);
  };

  const createComponent = ({ query, propsData, chartWidth = 1024 }) => {
    const component = shallowMount(ProjectSecurityCharts, {
      localVue,
      apolloProvider: createApolloProvider([
        projectsHistoryQuery,
        jest.fn().mockResolvedValue(query),
      ]),
      propsData: {
        projectFullPath,
        helpPath,
        ...propsData,
      },
      stubs: {
        SecurityChartsLayout,
      },
    });

    // Need to setData after the component is mounted
    component.setData({ chartWidth });

    return component;
  };

  afterEach(() => {
    if (wrapper) {
      wrapper.destroy();
      wrapper = null;
    }
  });

  describe('when chartWidth is 0', () => {
    beforeEach(() => {
      wrapper = createComponent({
        query: mockProjectSecurityChartsWithData(),
        propsData: { hasVulnerabilities: true },
        chartWidth: 0,
      });
      return wrapper.vm.$nextTick();
    });

    it('should not display the line chart', () => {
      expect(findLineChart().exists()).toBe(false);
    });

    it('should display a loading icon instead', () => {
      expect(findLoadingIcon().exists()).toBe(true);
    });
  });

  describe('when there is history data', () => {
    beforeEach(() => {
      wrapper = createComponent({
        query: mockProjectSecurityChartsWithData(),
        propsData: { hasVulnerabilities: true },
      });
      return wrapper.vm.$nextTick();
    });

    it('should display the chart with data', async () => {
      expect(findLineChart().props('data')).toMatchSnapshot();
    });

    it('should not display the loading icon', () => {
      expect(findLoadingIcon().exists()).toBe(false);
    });
  });

  describe('when there is no history data', () => {
    beforeEach(() => {
      wrapper = createComponent({
        query: mockProjectSecurityChartsWithoutData(),
        propsData: { hasVulnerabilities: false },
      });
      return wrapper.vm.$nextTick();
    });

    it('should display the empty state', () => {
      expect(findEmptyState().props()).toEqual({ helpPath });
    });

    it('should not display the chart', () => {
      expect(findLineChart().exists()).toBe(false);
    });

    it('should not display the loading icon', () => {
      expect(findLoadingIcon().exists()).toBe(false);
    });
  });

  describe('when the query is loading', () => {
    beforeEach(() => {
      wrapper = createComponent({
        query: () => ({}),
        propsData: { hasVulnerabilities: true },
      });
    });

    it('should not display the empty state', () => {
      expect(findEmptyState().exists()).toBe(false);
    });

    it('should not display the chart', () => {
      expect(findLineChart().exists()).toBe(false);
    });

    it('should display the loading icon', () => {
      expect(findLoadingIcon().exists()).toBe(true);
    });
  });
});
