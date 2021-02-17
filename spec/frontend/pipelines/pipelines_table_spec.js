import { mount } from '@vue/test-utils';
import { GlTable } from '@gitlab/ui';
import PipelinesTable from '~/pipelines/components/pipelines_list/pipelines_table.vue';
import PipelinesCommit from '~/pipelines/components/pipelines_list/pipelines_commit.vue';
import PipelineManualActions from '~/pipelines/components/pipelines_list/pipeline_manual_actions.vue';
import PipelinesStatusBadge from '~/pipelines/components/pipelines_list/pipelines_status_badge.vue';
import PipelinesTimeago from '~/pipelines/components/pipelines_list/time_ago.vue';
import PipelineTriggerer from '~/pipelines/components/pipelines_list/pipeline_triggerer.vue';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';

describe('Pipelines Table', () => {
  let pipeline;
  let wrapper;

  const jsonFixtureName = 'pipelines/pipelines.json';

  const defaultProps = {
    pipelines: [],
    autoDevopsHelpPath: 'foo',
    viewType: 'root',
  };

  const createComponent = (props = defaultProps) => {
    wrapper = extendedWrapper(
      mount(PipelinesTable, {
        propsData: props,
      }),
    );
  };
  const findRows = () => wrapper.findAll('[data-testid="pipeline-table-row"]');
  const findTable = () => wrapper.find(GlTable);
  const findStatusBadge = () => wrapper.find(PipelinesStatusBadge);
  const findTriggerer = () => wrapper.find(PipelineTriggerer);
  const findCommit = () => wrapper.find(PipelinesCommit);
  const findStages = () => wrapper.find(PipelineStage);
  const findTimeAgo = () => wrapper.find(PipelinesTimeago);
  const findActions = () => wrapper.find(PipelineManualActions);

  const findStatusTh = () => wrapper.findByTestId('status-th');
  const findPipelineTh = () => wrapper.findByTestId('pipeline-th');
  const findTriggererTh = () => wrapper.findByTestId('triggerer-th');
  const findCommitTh = () => wrapper.findByTestId('commit-th');
  const findStagesTh = () => wrapper.findByTestId('stages-th');
  const findTimeAgoTh = () => wrapper.findByTestId('timeago-th');
  const findActionsTh = () => wrapper.findByTestId('actions-th');
  const findPipelineUrl = () => wrapper.findByTestId('pipeline-url-link');

  preloadFixtures(jsonFixtureName);

  beforeEach(() => {
    const { pipelines } = getJSONFixture(jsonFixtureName);
    pipeline = pipelines.find((p) => p.user !== null && p.commit !== null);
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('table', () => {
    beforeEach(() => {
      createComponent();
    });

    it('should render a table', () => {
      expect(findTable().exists()).toBe(true);
    });

    it('should render table head with correct columns', () => {
      expect(findStatusTh().text()).toBe('Status');
      expect(findPipelineTh().text()).toBe('Pipeline');
      expect(findTriggererTh().text()).toBe('Triggerer');
      expect(findCommitTh().text()).toBe('Commit');
      expect(findStagesTh().text()).toBe('Stages');

      // last two columns should have no text in th
      expect(findTimeAgoTh().text()).toBe('');
      expect(findActionsTh().text()).toBe('');
    });
  });

  describe('without data', () => {
    beforeEach(() => {
      createComponent();
    });

    it('should render an empty table', () => {
      expect(findRows()).toHaveLength(0);
    });
  });

  describe('with data', () => {
    beforeEach(() => {
      createComponent({ pipelines: [pipeline], autoDevopsHelpPath: 'foo', viewType: 'root' });
    });

    it('should render rows', () => {
      expect(findRows()).toHaveLength(1);
    });

    it('should render a status badge', () => {
      expect(findStatusBadge().exists()).toBe(true);
    });

    it('should render a pipeline url', () => {
      expect(findPipelineUrl().exists()).toBe(true);
    });

    it('should render a triggerer', () => {
      expect(findTriggerer().exists()).toBe(true);
    });

    it('should render a commit', () => {
      expect(findCommit().exists()).toBe(true);
    });

    it('should render time ago', () => {
      expect(findTimeAgo().exists()).toBe(true);
    });

    it('should render pipeline manual actions', () => {
      expect(findActions().exists()).toBe(true);
    });
  });
});
