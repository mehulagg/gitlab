import { GlAlert, GlButton, GlLoadingIcon, GlTabs } from '@gitlab/ui';
import { shallowMount, createLocalVue } from '@vue/test-utils';
import VueApollo from 'vue-apollo';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import httpStatusCodes from '~/lib/utils/http_status';
import CommitForm from '~/pipeline_editor/components/commit/commit_form.vue';
import TextEditor from '~/pipeline_editor/components/editor/text_editor.vue';

import PipelineEditorTabs from '~/pipeline_editor/components/pipeline_editor_tabs.vue';
import PipelineEditorEmptyState from '~/pipeline_editor/components/ui/pipeline_editor_empty_state.vue';
import { COMMIT_SUCCESS, COMMIT_FAILURE, LOAD_FAILURE_UNKNOWN } from '~/pipeline_editor/constants';
import getCiConfigData from '~/pipeline_editor/graphql/queries/ci_config.graphql';
import PipelineEditorApp from '~/pipeline_editor/pipeline_editor_app.vue';
import PipelineEditorHome from '~/pipeline_editor/pipeline_editor_home.vue';
import {
  mockCiConfigPath,
  mockCiConfigQueryResponse,
  mockCiYml,
  mockDefaultBranch,
  mockProjectFullPath,
} from './mock_data';

const localVue = createLocalVue();
localVue.use(VueApollo);

const MockEditorLite = {
  template: '<div/>',
};

const mockProvide = {
  ciConfigPath: mockCiConfigPath,
  defaultBranch: mockDefaultBranch,
  glFeatures: {
    pipelineEditorEmptyStateAction: false,
  },
  projectFullPath: mockProjectFullPath,
};

describe('Pipeline editor app component', () => {
  let wrapper;

  let mockApollo;
  let mockBlobContentData;
  let mockCiConfigData;

  const createComponent = ({ blobLoading = false, options = {}, provide = {} } = {}) => {
    wrapper = shallowMount(PipelineEditorApp, {
      provide: { ...mockProvide, ...provide },
      stubs: {
        GlTabs,
        GlButton,
        CommitForm,
        PipelineEditorHome,
        PipelineEditorTabs,
        EditorLite: MockEditorLite,
        PipelineEditorEmptyState,
      },
      mocks: {
        $apollo: {
          queries: {
            initialCiFileContent: {
              loading: blobLoading,
            },
            ciConfigData: {
              loading: false,
            },
          },
        },
      },
      ...options,
    });
  };

  const createComponentWithApollo = ({ props = {}, provide = {} } = {}) => {
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

    createComponent({ props, provide, options });
  };

  const findLoadingIcon = () => wrapper.findComponent(GlLoadingIcon);
  const findAlert = () => wrapper.findComponent(GlAlert);
  const findEditorHome = () => wrapper.findComponent(PipelineEditorHome);
  const findTextEditor = () => wrapper.findComponent(TextEditor);
  const findEmptyState = () => wrapper.findComponent(PipelineEditorEmptyState);
  const findEmptyStateButton = () =>
    wrapper.findComponent(PipelineEditorEmptyState).findComponent(GlButton);

  beforeEach(() => {
    mockBlobContentData = jest.fn();
    mockCiConfigData = jest.fn();
  });

  afterEach(() => {
    mockBlobContentData.mockReset();
    mockCiConfigData.mockReset();

    wrapper.destroy();
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

      it('shows pipeline editor home component', () => {
        expect(findEditorHome().exists()).toBe(true);
      });

      it('no error is shown when data is set', () => {
        expect(findAlert().exists()).toBe(false);
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

    describe('when no CI config file exists', () => {
      describe('in a project without a repository', () => {
        it('shows an empty state and does not show editor home component', async () => {
          mockBlobContentData.mockRejectedValueOnce({
            response: {
              status: httpStatusCodes.BAD_REQUEST,
            },
          });
          createComponentWithApollo();

          await waitForPromises();

          expect(findEmptyState().exists()).toBe(true);
          expect(findAlert().exists()).toBe(false);
          expect(findEditorHome().exists()).toBe(false);
        });
      });

      describe('in a project with a repository', () => {
        it('shows an empty state and does not show editor home component', async () => {
          mockBlobContentData.mockRejectedValueOnce({
            response: {
              status: httpStatusCodes.NOT_FOUND,
            },
          });
          createComponentWithApollo();

          await waitForPromises();

          expect(findEmptyState().exists()).toBe(true);
          expect(findAlert().exists()).toBe(false);
          expect(findEditorHome().exists()).toBe(false);
        });
      });

      describe('because of a fetching error', () => {
        it('shows a unkown error message', async () => {
          mockBlobContentData.mockRejectedValueOnce(new Error('My error!'));
          createComponentWithApollo();
          await waitForPromises();

          expect(findEmptyState().exists()).toBe(false);
          expect(findAlert().text()).toBe(wrapper.vm.$options.errorTexts[LOAD_FAILURE_UNKNOWN]);
          expect(findEditorHome().exists()).toBe(true);
        });
      });
    });

    describe('when landing on the empty state with feature flag on', () => {
      it('user can click on CTA button and see an empty editor', async () => {
        mockBlobContentData.mockRejectedValueOnce({
          response: {
            status: httpStatusCodes.NOT_FOUND,
          },
        });

        createComponentWithApollo({
          provide: {
            glFeatures: {
              pipelineEditorEmptyStateAction: true,
            },
          },
        });

        await waitForPromises();

        expect(findEmptyState().exists()).toBe(true);
        expect(findTextEditor().exists()).toBe(false);

        await findEmptyStateButton().vm.$emit('click');

        expect(findEmptyState().exists()).toBe(false);
        expect(findTextEditor().exists()).toBe(true);
      });
    });

    describe('when the user commits', () => {
      const updateFailureMessage = 'The GitLab CI configuration could not be updated.';

      describe('and the commit mutation succeeds', () => {
        beforeEach(() => {
          window.scrollTo = jest.fn();
          createComponent();

          findEditorHome().vm.$emit('commit', { type: COMMIT_SUCCESS });
        });

        it('shows a confirmation message', () => {
          expect(findAlert().text()).toBe(wrapper.vm.$options.successTexts[COMMIT_SUCCESS]);
        });

        it('scrolls to the top of the page to bring attention to the confirmation message', () => {
          expect(window.scrollTo).toHaveBeenCalledWith({ top: 0, behavior: 'smooth' });
        });
      });
      describe('and the commit mutation fails', () => {
        const commitFailedReasons = ['Commit failed'];

        beforeEach(() => {
          window.scrollTo = jest.fn();
          createComponent();

          findEditorHome().vm.$emit('showError', {
            type: COMMIT_FAILURE,
            reasons: commitFailedReasons,
          });
        });

        it('shows an error message', () => {
          expect(findAlert().text()).toMatchInterpolatedText(
            `${updateFailureMessage} ${commitFailedReasons[0]}`,
          );
        });

        it('scrolls to the top of the page to bring attention to the error message', () => {
          expect(window.scrollTo).toHaveBeenCalledWith({ top: 0, behavior: 'smooth' });
        });
      });

      describe('when an unknown error occurs', () => {
        const unknownReasons = ['Commit failed'];

        beforeEach(() => {
          window.scrollTo = jest.fn();
          createComponent();

          findEditorHome().vm.$emit('showError', {
            type: COMMIT_FAILURE,
            reasons: unknownReasons,
          });
        });

        it('shows an error message', () => {
          expect(findAlert().text()).toMatchInterpolatedText(
            `${updateFailureMessage} ${unknownReasons[0]}`,
          );
        });

        it('scrolls to the top of the page to bring attention to the error message', () => {
          expect(window.scrollTo).toHaveBeenCalledWith({ top: 0, behavior: 'smooth' });
        });
      });
    });
  });
});
