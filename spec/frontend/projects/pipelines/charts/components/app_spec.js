import { merge } from 'lodash';
import { createLocalVue, shallowMount } from '@vue/test-utils';
import VueApollo from 'vue-apollo';
import { GlTabs, GlTab } from '@gitlab/ui';
import createMockApollo from 'jest/helpers/mock_apollo_helper';
import Component from '~/projects/pipelines/charts/components/app.vue';
import PipelineCharts from '~/projects/pipelines/charts/components/pipeline_charts.vue';
import getPipelineCountByStatus from '~/projects/pipelines/charts/graphql/queries/get_pipeline_count_by_status.query.graphql';
import getProjectPipelineStatistics from '~/projects/pipelines/charts/graphql/queries/get_project_pipeline_statistics.query.graphql';
import { mockPipelineCount, mockPipelineStatistics } from '../mock_data';

const projectPath = 'gitlab-org/gitlab';
const localVue = createLocalVue();
localVue.use(VueApollo);

const DeploymentFrequencyChartsStub = { name: 'DeploymentFrequencyCharts', render: () => { } };

describe('ProjectsPipelinesChartsApp', () => {
  let wrapper;

  function createMockApolloProvider() {
    const requestHandlers = [
      [getPipelineCountByStatus, jest.fn().mockResolvedValue(mockPipelineCount)],
      [getProjectPipelineStatistics, jest.fn().mockResolvedValue(mockPipelineStatistics)],
    ];

    return createMockApollo(requestHandlers);
  }

  function createComponent(mountOptions = {}) {
    wrapper = shallowMount(
      Component,
      merge(
        {},
        {
          provide: {
            projectPath,
            shouldRenderDeploymentFrequencyCharts: false,
          },
          localVue,
          apolloProvider: createMockApolloProvider(),
          stubs: {
            DeploymentFrequencyCharts: DeploymentFrequencyChartsStub,
          },
        },
        mountOptions,
      ),
    );
  }

  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('pipelines charts', () => {
    it('displays the pipeline charts', () => {
      const chart = wrapper.find(PipelineCharts);
      const analytics = mockPipelineStatistics.data.project.pipelineAnalytics;

      expect(chart.exists()).toBe(true);
      expect(chart.props()).toMatchObject({
        counts: {
          failed: 1,
          success: 23,
          total: 34,
          successRatio: 95.83333333333334,
        },
        lastWeek: {
          labels: analytics.weekPipelinesLabels,
          totals: analytics.weekPipelinesTotals,
          success: analytics.weekPipelinesSuccessful,
        },
        lastMonth: {
          labels: analytics.monthPipelinesLabels,
          totals: analytics.monthPipelinesTotals,
          success: analytics.monthPipelinesSuccessful,
        },
        lastYear: {
          labels: analytics.yearPipelinesLabels,
          totals: analytics.yearPipelinesTotals,
          success: analytics.yearPipelinesSuccessful,
        },
        timesChart: {
          labels: analytics.pipelineTimesLabels,
          values: analytics.pipelineTimesValues,
        }
      });
    });
  });

  const findDeploymentFrequencyCharts = () => wrapper.find(DeploymentFrequencyChartsStub);
  const findGlTabs = () => wrapper.find(GlTabs);
  const findAllGlTab = () => wrapper.findAll(GlTab);
  const findGlTabAt = (i) => findAllGlTab().at(i);

  describe('when shouldRenderDeploymentFrequencyCharts is true', () => {
    beforeEach(() => {
      createComponent({ provide: { shouldRenderDeploymentFrequencyCharts: true } });
    });

    it('renders the deployment frequency charts in a tab', () => {
      expect(findGlTabs().exists()).toBe(true);
      expect(findGlTabAt(0).attributes('title')).toBe('Pipelines');
      expect(findGlTabAt(1).attributes('title')).toBe('Deployments');
      expect(findDeploymentFrequencyCharts().exists()).toBe(true);
    });
  });

  describe('when shouldRenderDeploymentFrequencyCharts is false', () => {
    beforeEach(() => {
      createComponent({ provide: { shouldRenderDeploymentFrequencyCharts: false } });
    });

    it('does not render the deployment frequency charts in a tab', () => {
      expect(findGlTabs().exists()).toBe(false);
      expect(findDeploymentFrequencyCharts().exists()).toBe(false);
    });
  });
});
