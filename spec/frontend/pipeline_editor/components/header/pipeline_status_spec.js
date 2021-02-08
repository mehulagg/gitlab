import VueApollo from 'vue-apollo';
import { shallowMount, createLocalVue } from '@vue/test-utils';
import { GlAlert, GlLoadingIcon } from '@gitlab/ui';
import CiIcon from '~/vue_shared/components/ci_icon.vue';
import PipelineStatus from '~/pipeline_editor/components/header/pipeline_status.vue';
import createMockApollo from 'helpers/mock_apollo_helper';
import getPipelineQuery from '~/pipeline_editor/graphql/queries/client/pipeline.graphql';
import waitForPromises from 'helpers/wait_for_promises';
import { mockCommitSha, mockPipeline, mockProjectFullPath } from '../../mock_data';

const FETCH_ERROR_MESSAGE = 'We are currently unable to fetch data for the pipeline header.';

const localVue = createLocalVue();
localVue.use(VueApollo);

const mockProvide = {
  projectFullPath: mockProjectFullPath,
};

describe('Pipeline Status', () => {
  let wrapper;
  let mockApollo;
  let mockPipelineData;

  const createComponent = ({ hasPipeline = true, isQueryLoading = false }) => {
    wrapper = shallowMount(PipelineStatus, {
      provide: mockProvide,
      mocks: {
        $apollo: {
          queries: {
            pipeline: {
              loading: isQueryLoading,
              id: hasPipeline ? 1 : undefined,
            },
          },
        },
      },
    });
  };

  const createComponentWithApollo = () => {
    const requestHandlers = [[getPipelineQuery, mockPipelineData]];
    mockApollo = createMockApollo(requestHandlers);

    wrapper = shallowMount(PipelineStatus, {
      localVue,
      mocks: {},
      apolloProvider: mockApollo,
      provide: mockProvide,
      data() {
        return {
          commitSha: mockCommitSha,
        };
      },
    });
  };

  const findAlert = () => wrapper.findComponent(GlAlert);
  const findCiIcon = () => wrapper.findComponent(CiIcon);
  const findLoadingIcon = () => wrapper.findComponent(GlLoadingIcon);
  const findPipelineId = () => wrapper.find('[data-testid="pipeline-id"]');
  const findPipelineCommit = () => wrapper.find('[data-testid="pipeline-commit"]');

  beforeEach(() => {
    mockPipelineData = jest.fn();
  });

  afterEach(() => {
    mockPipelineData.mockReset();

    wrapper.destroy();
    wrapper = null;
  });

  describe('while querying', () => {
    it('renders loading icon', () => {
      createComponent({ isQueryLoading: true, hasPipeline: false });

      expect(findLoadingIcon().exists()).toBe(true);
    });

    it('does not render loading icon if pipeline data is already set', () => {
      createComponent({ isQueryLoading: true });

      expect(findLoadingIcon().exists()).toBe(false);
    });
  });

  describe('when querying data', () => {
    describe('when data is set', () => {
      beforeEach(async () => {
        mockPipelineData.mockResolvedValue(mockPipeline);

        createComponentWithApollo();
        await waitForPromises();
      });

      it('query is called with correct variables', async () => {
        expect(mockPipelineData).toHaveBeenCalledWith({
          fullPath: mockProjectFullPath,
          sha: mockCommitSha,
        });
      });

      it('does not render error', () => {
        expect(findAlert().exists()).toBe(false);
      });

      it('renders pipeline data', () => {
        expect(findCiIcon().exists()).toBe(true);
        expect(findPipelineId().text()).toBe('#118');
        expect(findPipelineCommit().text()).toBe('aabbccdd');
      });
    });

    describe('when data cannot be fetched', () => {
      beforeEach(async () => {
        mockPipelineData.mockRejectedValue(new Error());

        createComponentWithApollo();
        await waitForPromises();
      });

      it('renders error', () => {
        expect(findAlert().exists()).toBe(true);
        expect(findAlert().text()).toBe(FETCH_ERROR_MESSAGE);
      });

      it('does not render pipeline data', () => {
        expect(findCiIcon().exists()).toBe(false);
        expect(findPipelineId().exists()).toBe(false);
        expect(findPipelineCommit().exists()).toBe(false);
      });
    });
  });
});
