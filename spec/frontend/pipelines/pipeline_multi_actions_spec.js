import { GlDropdown, GlSprintf } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import MockAdapter from 'axios-mock-adapter';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import waitForPromises from 'helpers/wait_for_promises';
import createFlash from '~/flash';
import axios from '~/lib/utils/axios_utils';
import PipelineMultiActions, {
  i18n,
} from '~/pipelines/components/pipelines_list/pipeline_multi_actions.vue';

jest.mock('~/flash');

describe('Pipeline Multi Actions Dropdown', () => {
  let wrapper;
  let mockAxios;

  const artifacts = [
    {
      name: 'job my-artifact',
      path: '/download/path',
    },
    {
      name: 'job-2 my-artifact-2',
      path: '/download/path-two',
    },
  ];
  const artifactItemTestId = 'artifact-item';
  const artifactsEndpoint = 'endpoint/:REPLACE_ME:/artifacts.json';
  const pipelineId = 108;

  const createComponent = ({ mockData = {} } = {}) => {
    wrapper = extendedWrapper(
      shallowMount(PipelineMultiActions, {
        provide: {
          artifactsEndpoint,
        },
        propsData: {
          pipelineId,
        },
        data() {
          return {
            ...mockData,
          };
        },
        stubs: {
          GlSprintf,
        },
      }),
    );
  };

  const findDropdown = () => wrapper.findComponent(GlDropdown);
  const findAllArtifactItems = () => wrapper.findAllByTestId(artifactItemTestId);
  const findFirstArtifactItem = () => wrapper.findByTestId(artifactItemTestId);

  beforeEach(() => {
    mockAxios = new MockAdapter(axios);
  });

  afterEach(() => {
    mockAxios.restore();

    wrapper.destroy();
  });

  it('should render the dropdown', () => {
    createComponent();

    expect(findDropdown().exists()).toBe(true);
  });

  describe('Artifacts', () => {
    it('should fetch artifacts on dropdown click', async () => {
      const endpoint = artifactsEndpoint.replace(':REPLACE_ME:', pipelineId);
      mockAxios.onGet(endpoint).replyOnce(200, { artifacts });
      createComponent();
      findDropdown().vm.$emit('show');
      await waitForPromises();

      expect(mockAxios.history.get).toHaveLength(1);
      expect(wrapper.vm.artifacts).toEqual(artifacts);
    });

    it('should render all the provided artifacts', () => {
      createComponent({ mockData: { artifacts } });

      expect(findAllArtifactItems()).toHaveLength(artifacts.length);
    });

    it('should render the correct artifact name and path', () => {
      createComponent({ mockData: { artifacts } });

      expect(findFirstArtifactItem().attributes('href')).toBe(artifacts[0].path);
      expect(findFirstArtifactItem().text()).toBe(`Download ${artifacts[0].name} artifact`);
    });

    describe('with a failing request', () => {
      it('should render an error message', async () => {
        const endpoint = artifactsEndpoint.replace(':REPLACE_ME:', pipelineId);
        mockAxios.onGet(endpoint).replyOnce(500);
        createComponent();
        findDropdown().vm.$emit('show');
        await waitForPromises();

        expect(createFlash).toHaveBeenCalledWith({
          message: i18n.artifactsFetchErrorMessage,
        });
      });
    });
  });
});
