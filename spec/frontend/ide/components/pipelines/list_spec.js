import { shallowMount, createLocalVue } from '@vue/test-utils';
import List from '~/ide/components/pipelines/list.vue';
import JobsList from '~/ide/components/jobs/list.vue';
import Tab from '~/vue_shared/components/tabs/tab.vue';
import { GlLoadingIcon } from '@gitlab/ui';
import Vuex from 'vuex';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('IDE pipelines list', () => {
  let wrapper;
  let mockData;
  let defaultState;

  const fetchLatestPipelineMock = jest.fn();
  const failedStagesGetterMock = jest.fn().mockReturnValue([]);

  const createComponent = (state = {}) => {
    const { pipelines, ...restOfState } = state;
    const { defaultPipelines, ...defaultRestOfState } = defaultState;

    const fakeStore = new Vuex.Store({
      getters: { currentProject: () => ({ web_url: 'some/url ' }) },
      state: {
        ...defaultRestOfState,
        ...restOfState,
      },
      modules: {
        pipelines: {
          namespaced: true,
          state: {
            ...defaultPipelines,
            ...pipelines,
          },
          actions: {
            fetchLatestPipeline: fetchLatestPipelineMock,
          },
          getters: {
            jobsCount: () => 1,
            failedJobsCount: () => 1,
            failedStages: failedStagesGetterMock,
            pipelineFailed: () => false,
          },
          methods: {
            fetchLatestPipeline: jest.fn(),
          },
        },
      },
    });

    wrapper = shallowMount(List, {
      localVue,
      store: fakeStore,
      sync: false,
    });
  };

  beforeAll(() => {
    // We can't import mock_data directly as it relies on gl global
    // We can get rid of this when our Karma -> Jest migration will be complete
    global.gl = {
      TEST_HOST: 'https://some.host',
    };
    return import('../../../../javascripts/ide/mock_data').then(mock => {
      mockData = mock;
      defaultState = {
        links: { ciHelpPagePath: gl.TEST_HOST },
        pipelinesEmptyStateSvgPath: gl.TEST_HOST,
        pipelines: {
          stages: [],
          failedStages: [],
          isLoadingJobs: false,
        },
      };
    });
  });

  afterAll(() => {
    delete global.gl;
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('fetches latest pipeline', () => {
    createComponent();

    expect(fetchLatestPipelineMock).toHaveBeenCalled();
  });

  describe('when loading', () => {
    let defaultPipelinesLoadingState;
    beforeAll(() => {
      defaultPipelinesLoadingState = {
        ...defaultState.pipelines,
        isLoadingPipeline: true,
      };
    });

    it('does not render when pipeline has loaded before', () => {
      createComponent({
        pipelines: {
          ...defaultPipelinesLoadingState,
          hasLoadedPipeline: true,
        },
      });

      expect(wrapper.find(GlLoadingIcon).exists()).toBe(false);
    });

    it('renders loading state', () => {
      createComponent({
        pipelines: {
          ...defaultPipelinesLoadingState,
          hasLoadedPipeline: false,
        },
      });

      expect(wrapper.find(GlLoadingIcon).exists()).toBe(true);
    });
  });

  describe('when loaded', () => {
    let defaultPipelinesLoadedState;
    beforeAll(() => {
      defaultPipelinesLoadedState = {
        ...defaultState.pipelines,
        isLoadingPipeline: false,
        hasLoadedPipeline: true,
      };
    });

    it('renders empty state when no latestPipeline', () => {
      createComponent({ pipelines: { ...defaultPipelinesLoadedState, latestPipeline: null } });
      expect(wrapper.element).toMatchSnapshot();
    });

    describe('with latest pipeline loaded', () => {
      let withLatestPipelineState;
      beforeAll(() => {
        withLatestPipelineState = {
          ...defaultPipelinesLoadedState,
          latestPipeline: mockData.pipelines[0],
        };
      });

      it('renders pipeline data', () => {
        createComponent({ pipelines: withLatestPipelineState });

        expect(wrapper.text()).toContain('#1');
      });

      it('renders list of jobs', () => {
        const stages = [];
        const isLoadingJobs = true;
        createComponent({ pipelines: { ...withLatestPipelineState, stages, isLoadingJobs } });

        const jobProps = wrapper
          .findAll(Tab)
          .at(0)
          .find(JobsList)
          .props();
        expect(jobProps.stages).toBe(stages);
        expect(jobProps.loading).toBe(isLoadingJobs);
      });

      it('renders list of failed jobs', () => {
        const failedStages = [];
        failedStagesGetterMock.mockReset().mockReturnValue(failedStages);
        const isLoadingJobs = true;
        createComponent({ pipelines: { ...withLatestPipelineState, isLoadingJobs } });

        const jobProps = wrapper
          .findAll(Tab)
          .at(1)
          .find(JobsList)
          .props();
        expect(jobProps.stages).toBe(failedStages);
        expect(jobProps.loading).toBe(isLoadingJobs);
      });

      describe('with YAML error', () => {
        it('renders YAML error', () => {
          const yamlError = 'test yaml error';
          createComponent({
            pipelines: {
              ...defaultPipelinesLoadedState,
              latestPipeline: { ...mockData.pipelines[0], yamlError },
            },
          });

          expect(wrapper.text()).toContain('Found errors in your .gitlab-ci.yml:');
          expect(wrapper.text()).toContain(yamlError);
        });
      });
    });
  });
});
