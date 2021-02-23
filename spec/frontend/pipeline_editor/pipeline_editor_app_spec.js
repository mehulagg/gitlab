import { GlAlert, GlButton, GlLoadingIcon, GlTabs } from '@gitlab/ui';
import { shallowMount, createLocalVue } from '@vue/test-utils';
import VueApollo from 'vue-apollo';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import httpStatusCodes from '~/lib/utils/http_status';
import CommitForm from '~/pipeline_editor/components/commit/commit_form.vue';
import TextEditor from '~/pipeline_editor/components/editor/text_editor.vue';

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
  projectFullPath: mockProjectFullPath,
};

describe('Pipeline editor app component', () => {
  let wrapper;

  let mockApollo;
  let mockBlobContentData;
  let mockCiConfigData;

  const createComponent = ({ blobLoading = false, options = {} } = {}) => {
    wrapper = shallowMount(PipelineEditorApp, {
      provide: mockProvide,
      stubs: {
        GlTabs,
        GlButton,
        CommitForm,
        EditorLite: MockEditorLite,
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

  const createComponentWithApollo = ({ props = {} } = {}) => {
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

    createComponent({ props, options });
  };

  const findLoadingIcon = () => wrapper.findComponent(GlLoadingIcon);
  const findAlert = () => wrapper.findComponent(GlAlert);
  const findEditorHome = () => wrapper.findComponent(PipelineEditorHome);
  const findTextEditor = () => wrapper.findComponent(TextEditor);

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

    describe('when no file exists', () => {
      const noFileAlertMsg =
        'There is no .gitlab-ci.yml file in this repository, please add one and visit the Pipeline Editor again.';

      it('shows a 404 error message and does not show editor home component', async () => {
        mockBlobContentData.mockRejectedValueOnce({
          response: {
            status: httpStatusCodes.NOT_FOUND,
          },
        });
        createComponentWithApollo();

        await waitForPromises();

        expect(findAlert().text()).toBe(noFileAlertMsg);
        expect(findEditorHome().exists()).toBe(false);
      });

      it('shows a 400 error message and does not show editor home component', async () => {
        mockBlobContentData.mockRejectedValueOnce({
          response: {
            status: httpStatusCodes.BAD_REQUEST,
          },
        });
        createComponentWithApollo();

        await waitForPromises();

        expect(findAlert().text()).toBe(noFileAlertMsg);
        expect(findEditorHome().exists()).toBe(false);
      });

      it('shows a unkown error message', async () => {
        mockBlobContentData.mockRejectedValueOnce(new Error('My error!'));
        createComponentWithApollo();
        await waitForPromises();

        expect(findAlert().text()).toBe(wrapper.vm.$options.errorTexts[LOAD_FAILURE_UNKNOWN]);
        expect(findEditorHome().exists()).toBe(true);
      });
    });

    describe('when the user commits', () => {
      const updateFailureMessage = 'The GitLab CI configuration could not be updated.';

      describe('and the commit mutation succeeds', () => {
        beforeEach(() => {
          createComponent();

          findEditorHome().vm.$emit('commit', { type: COMMIT_SUCCESS });
        });

        it('shows a confirmation message', () => {
          expect(findAlert().text()).toBe(wrapper.vm.$options.successTexts[COMMIT_SUCCESS]);
        });
      });
      describe('and the commit mutation fails', () => {
        const commitFailedReasons = ['Commit failed'];

        beforeEach(() => {
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
      });
      describe('when an unknown error occurs', () => {
        const unknownReasons = ['Commit failed'];

        beforeEach(() => {
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
      });
    });
  });
});
