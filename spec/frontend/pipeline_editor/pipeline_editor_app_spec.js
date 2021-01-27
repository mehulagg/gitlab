import { nextTick } from 'vue';
import { mount, shallowMount, createLocalVue } from '@vue/test-utils';
import { GlAlert, GlButton, GlFormInput, GlFormTextarea, GlLoadingIcon, GlTabs } from '@gitlab/ui';
import waitForPromises from 'helpers/wait_for_promises';
import VueApollo from 'vue-apollo';
import createMockApollo from 'helpers/mock_apollo_helper';

import httpStatusCodes from '~/lib/utils/http_status';
import { objectToQuery, redirectTo, refreshCurrentPage } from '~/lib/utils/url_utility';
import {
  mockCiConfigPath,
  mockCiConfigQueryResponse,
  mockCiYml,
  mockCommitSha,
  mockCommitNextSha,
  mockCommitMessage,
  mockDefaultBranch,
  mockProjectPath,
  mockProjectFullPath,
  mockProjectNamespace,
  mockNewMergeRequestPath,
} from './mock_data';

import CommitForm from '~/pipeline_editor/components/commit/commit_form.vue';
import getCiConfigData from '~/pipeline_editor/graphql/queries/ci_config.graphql';
import EditorTab from '~/pipeline_editor/components/ui/editor_tab.vue';
import PipelineGraph from '~/pipelines/components/pipeline_graph/pipeline_graph.vue';
import PipelineEditorApp from '~/pipeline_editor/pipeline_editor_app.vue';
import TextEditor from '~/pipeline_editor/components/text_editor.vue';

const localVue = createLocalVue();
localVue.use(VueApollo);

jest.mock('~/lib/utils/url_utility', () => ({
  redirectTo: jest.fn(),
  refreshCurrentPage: jest.fn(),
  objectToQuery: jest.requireActual('~/lib/utils/url_utility').objectToQuery,
  mergeUrlParams: jest.requireActual('~/lib/utils/url_utility').mergeUrlParams,
}));

const MockEditorLite = {
  template: '<div/>',
};

const mockProvide = {
  projectFullPath: mockProjectFullPath,
  projectPath: mockProjectPath,
  projectNamespace: mockProjectNamespace,
  glFeatures: {
    ciConfigVisualizationTab: true,
  },
};

describe('~/pipeline_editor/pipeline_editor_app.vue', () => {
  let wrapper;

  let mockApollo;
  let mockBlobContentData;
  let mockCiConfigData;
  // let mockMutate;

  const createComponent = ({
    props = {},
    blobLoading = false,
    lintLoading = false,
    options = {},
    mountFn = shallowMount,
    provide = mockProvide,
  } = {}) => {
    // mockMutate = jest.fn().mockResolvedValue({
    //   data: {
    //     commitCreate: {
    //       errors: [],
    //       commit: {
    //         sha: mockCommitNextSha,
    //       },
    //     },
    //   },
    // });

    wrapper = mountFn(PipelineEditorApp, {
      propsData: {
        ciConfigPath: mockCiConfigPath,
        commitSha: mockCommitSha,
        defaultBranch: mockDefaultBranch,
        newMergeRequestPath: mockNewMergeRequestPath,
        ...props,
      },
      provide,
      stubs: {
        GlTabs,
        GlButton,
        CommitForm,
        EditorLite: MockEditorLite,
        TextEditor,
      },
      mocks: {
        $apollo: {
          queries: {
            content: {
              loading: blobLoading,
            },
            ciConfigData: {
              loading: lintLoading,
            },
          },
          // mutate: mockMutate,
        },
      },
      // attachTo is required for input/submit events
      attachTo: mountFn === mount ? document.body : null,
      ...options,
    });
  };

  const createComponentWithApollo = ({ props = {}, mountFn = shallowMount } = {}) => {
    const handlers = [[getCiConfigData, mockCiConfigData]];
    const resolvers = {
      Query: {
        blobContent() {
          return {
            __typename: 'BlobContent',
            rawData: mockBlobContentData(),
          };
        },
      },
    };

    mockApollo = createMockApollo(handlers, resolvers);

    const options = {
      localVue,
      mocks: {},
      apolloProvider: mockApollo,
    };

    createComponent({ props, options }, mountFn);
  };

  const findLoadingIcon = () => wrapper.find(GlLoadingIcon);
  const findAlert = () => wrapper.find(GlAlert);
  const findTabAt = (i) => wrapper.findAll(EditorTab).at(i);
  const findVisualizationTab = () => wrapper.find('[data-testid="visualization-tab"]');
  const findTextEditor = () => wrapper.find(TextEditor);
  const findEditorLite = () => wrapper.find(MockEditorLite);
  const findCommitForm = () => wrapper.find(CommitForm);
  const findPipelineGraph = () => wrapper.find(PipelineGraph);
  const findCommitBtnLoadingIcon = () => wrapper.find('[type="submit"]').find(GlLoadingIcon);

  beforeEach(() => {
    mockBlobContentData = jest.fn();
    mockCiConfigData = jest.fn();
  });

  afterEach(() => {
    mockBlobContentData.mockReset();
    mockCiConfigData.mockReset();
    refreshCurrentPage.mockReset();
    redirectTo.mockReset();
    // mockMutate.mockReset();

    wrapper.destroy();
    wrapper = null;
  });

  it('displays a loading icon if the blob query is loading', () => {
    createComponent({ blobLoading: true });

    expect(findLoadingIcon().exists()).toBe(true);
    expect(findTextEditor().exists()).toBe(false);
  });

  describe('when queries are called', () => {
    beforeEach(() => {
      mockBlobContentData.mockResolvedValue(mockCiYml);
      mockCiConfigData.mockResolvedValue(mockCiConfigQueryResponse);
    });

    describe('when file exists', () => {
      beforeEach(async () => {
        createComponentWithApollo();

        await waitForPromises();
      });

      it('shows editor and commit form', () => {
        expect(findEditorLite().exists()).toBe(true);
        expect(findTextEditor().exists()).toBe(true);
      });

      it('no error is shown when data is set', async () => {
        expect(findAlert().exists()).toBe(false);
        expect(findEditorLite().attributes('value')).toBe(mockCiYml);
      });

      it('ci config query is called with correct variables', async () => {
        createComponentWithApollo();

        await waitForPromises();

        expect(mockCiConfigData).toHaveBeenCalledWith({
          content: mockCiYml,
          projectPath: mockProjectFullPath,
        });
      });
    });

    describe('when no file exists', () => {
      const expectedAlertMsg =
        'There is no .gitlab-ci.yml file in this repository, please add one and visit the Pipeline Editor again.';

      it('shows a 404 error message and does not show editor or commit form', async () => {
        mockBlobContentData.mockRejectedValueOnce({
          response: {
            status: httpStatusCodes.NOT_FOUND,
          },
        });
        createComponentWithApollo();

        await waitForPromises();

        expect(findAlert().text()).toBe(expectedAlertMsg);
        expect(findEditorLite().exists()).toBe(false);
        expect(findTextEditor().exists()).toBe(false);
      });

      it('shows a 400 error message and does not show editor or commit form', async () => {
        mockBlobContentData.mockRejectedValueOnce({
          response: {
            status: httpStatusCodes.BAD_REQUEST,
          },
        });
        createComponentWithApollo();

        await waitForPromises();

        expect(findAlert().text()).toBe(expectedAlertMsg);
        expect(findEditorLite().exists()).toBe(false);
        expect(findTextEditor().exists()).toBe(false);
      });

      it('shows a unkown error message', async () => {
        mockBlobContentData.mockRejectedValueOnce(new Error('My error!'));
        createComponentWithApollo();
        await waitForPromises();

        expect(findAlert().text()).toBe('The CI configuration was not loaded, please try again.');
        expect(findEditorLite().exists()).toBe(true);
        expect(findTextEditor().exists()).toBe(true);
      });
    });
  });

  describe('renders the pipeline editor home', () => {});
});
