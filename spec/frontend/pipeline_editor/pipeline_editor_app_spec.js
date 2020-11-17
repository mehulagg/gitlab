import { nextTick } from 'vue';
import { shallowMount, createLocalVue } from '@vue/test-utils';
import { GlButton, GlAlert, GlLoadingIcon, GlTabs, GlTab } from '@gitlab/ui';
import waitForPromises from 'helpers/wait_for_promises';
import VueApollo from 'vue-apollo';
import createMockApollo from 'jest/helpers/mock_apollo_helper';

import { redirectTo, refreshCurrentPage, objectToQuery } from '~/lib/utils/url_utility';
import {
  mockProjectPath,
  mockDefaultBranch,
  mockCiConfigPath,
  mockCommitId,
  mockCiYml,
  mockNewMergeRequestPath,
  mockCommitMessage,
} from './mock_data';

import TextEditor from '~/pipeline_editor/components/text_editor.vue';
import EditorLite from '~/vue_shared/components/editor_lite.vue';
import PipelineGraph from '~/pipelines/components/pipeline_graph/pipeline_graph.vue';
import PipelineEditorApp from '~/pipeline_editor/pipeline_editor_app.vue';
import CommitForm from '~/pipeline_editor/components/commit/commit_form.vue';
import getBlobContent from '~/pipeline_editor/graphql/queries/blob_content.graphql';

const localVue = createLocalVue();
localVue.use(VueApollo);

jest.mock('~/lib/utils/url_utility', () => ({
  redirectTo: jest.fn(),
  refreshCurrentPage: jest.fn(),
  objectToQuery: jest.requireActual('~/lib/utils/url_utility').objectToQuery,
  mergeUrlParams: jest.requireActual('~/lib/utils/url_utility').mergeUrlParams,
}));

jest.mock('~/api', () => ({
  getRawFile: () => Promise.resolve(mockCiYml),
}));

describe('~/pipeline_editor/pipeline_editor_app.vue', () => {
  let wrapper;
  let mockMutate;
  let fakeApollo;

  const createComponentWithApollo = ({ props = {} } = {}, mountFn = shallowMount) => {
    fakeApollo = createMockApollo(); // only local resolvers

    // setup local resolver with writeQuery
    fakeApollo.clients.defaultClient.cache.writeQuery({
      query: getBlobContent,
      data: {
        mockGetBlobContent: {
          __typename: 'BlobContent',
          rawData: mockCiYml,
        },
      },
    });

    wrapper = mountFn(PipelineEditorApp, {
      localVue,
      propsData: {
        projectPath: mockProjectPath,
        defaultBranch: mockDefaultBranch,
        ciConfigPath: mockCiConfigPath,
        newMergeRequestPath: mockNewMergeRequestPath,
        commitId: mockCommitId,
        ...props,
      },
      stubs: {
        GlTabs,
        GlButton,
        TextEditor,
        CommitForm,
      },
      apolloProvider: fakeApollo,
    });
  };

  const createComponent = ({ props = {}, loading = false } = {}, mountFn = shallowMount) => {
    mockMutate = jest.fn().mockResolvedValue({
      data: {
        commitCreate: {
          errors: [],
          commit: {},
        },
      },
    });

    wrapper = mountFn(PipelineEditorApp, {
      // localVue,
      propsData: {
        projectPath: mockProjectPath,
        defaultBranch: mockDefaultBranch,
        ciConfigPath: mockCiConfigPath,
        newMergeRequestPath: mockNewMergeRequestPath,
        commitId: mockCommitId,
        ...props,
      },
      stubs: {
        GlTabs,
        GlButton,
        TextEditor,
        CommitForm,
      },
      mocks: {
        $apollo: {
          queries: {
            content: {
              loading,
            },
          },
          mutate: mockMutate,
        },
      },
    });
  };

  const findLoadingIcon = () => wrapper.find(GlLoadingIcon);
  const findAlert = () => wrapper.find(GlAlert);
  const findTabAt = i => wrapper.findAll(GlTab).at(i);
  const findEditorLite = () => wrapper.find(EditorLite);
  const findCommitForm = () => wrapper.find(CommitForm);
  const findCommitBtnLoadingIcon = () => wrapper.find('[type="submit"]').find(GlLoadingIcon);

  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    refreshCurrentPage.mockReset();
    redirectTo.mockReset();
    mockMutate.mockReset();

    wrapper.destroy();
    wrapper = null;
  });

  it('displays a loading icon if the query is loading', () => {
    createComponent({ loading: true });

    expect(findLoadingIcon().exists()).toBe(true);
    expect(findEditorLite().exists()).toBe(false);
  });

  describe('handle apollo query errors', () => {
    class MockError extends Error {
      constructor(message, data) {
        super(message);
        if (data) {
          this.networkError = {
            response: { data },
          };
        }
      }
    }

    it.only('sets a general error message', async () => {
      // TODO Setup error conditions to run content -> error(error)
      // Simulating 3 possible error states:
      // - unknown error
      // - ref is missing
      // - file not found

      createComponentWithApollo();

      await nextTick();

      expect(findAlert().text()).toMatch('CI file could not be loaded: An error');
    });

    it('sets a 404 error message', async () => {
      wrapper.vm.handleBlobContentError(new MockError('Error!', { message: 'file not found' }));
      await nextTick();

      expect(findAlert().text()).toMatch('CI file could not be loaded: file not found');
    });

    it('sets a 400 error message', async () => {
      wrapper.vm.handleBlobContentError(new MockError('Error!', { error: 'ref is missing' }));
      await nextTick();

      expect(findAlert().text()).toMatch('CI file could not be loaded: ref is missing');
    });

    it('sets a unkown error error message', async () => {
      wrapper.vm.handleBlobContentError({ message: null });
      await nextTick();

      expect(findAlert().text()).toMatch('CI file could not be loaded: Unknown Error');
    });
  });

  describe('tabs', () => {
    it('displays tabs and their content', async () => {
      expect(
        findTabAt(0)
          .find(EditorLite)
          .exists(),
      ).toBe(true);
      expect(
        findTabAt(1)
          .find(PipelineGraph)
          .exists(),
      ).toBe(true);
    });

    it('displays editor tab lazily, until editor is ready', async () => {
      expect(findTabAt(0).attributes('lazy')).toBe('true');

      findEditorLite().vm.$emit('editor-ready');

      await nextTick();

      expect(findTabAt(0).attributes('lazy')).toBe(undefined);
    });
  });

  describe('when data is set', () => {
    beforeEach(() => {
      wrapper.setData({
        content: mockCiYml,
        contentModel: mockCiYml,
      });
    });

    it('displays content after the query loads', async () => {
      await nextTick();

      expect(findLoadingIcon().exists()).toBe(false);
      expect(findEditorLite().props('value')).toBe(mockCiYml);
    });

    describe('commit form', () => {
      const mockVariables = {
        projectPath: mockProjectPath,
        filePath: mockCiConfigPath,
        content: mockCiYml,
        startBranch: mockDefaultBranch,
        lastCommitId: mockCommitId,
        message: mockCommitMessage,
      };

      const emitSubmit = event => {
        findCommitForm().vm.$emit('submit', {
          message: mockCommitMessage,
          branch: mockDefaultBranch,
          openMergeRequest: false,
          ...event,
        });
      };

      describe('when the user commits changes to the current branch', () => {
        beforeEach(async () => {
          emitSubmit();
          await nextTick();
        });

        it('calls the mutation with the default branch', () => {
          expect(mockMutate).toHaveBeenCalledWith({
            mutation: expect.any(Object),
            variables: {
              ...mockVariables,
              branch: mockDefaultBranch,
            },
          });
        });

        it('refreshes the page', () => {
          expect(refreshCurrentPage).toHaveBeenCalledWith();
        });

        it('shows no saving state', () => {
          expect(findCommitBtnLoadingIcon().exists()).toBe(true);
        });
      });

      describe('when the user commits changes to a new branch', () => {
        const newBranch = 'new-branch';

        beforeEach(() => {
          emitSubmit({
            branch: newBranch,
          });
        });

        it('calls the mutation with the new branch', () => {
          expect(mockMutate).toHaveBeenCalledWith({
            mutation: expect.any(Object),
            variables: {
              ...mockVariables,
              branch: newBranch,
            },
          });
        });

        it('refreshes the page', () => {
          expect(refreshCurrentPage).toHaveBeenCalledWith();
        });
      });

      describe('when the user commits changes to open a new merge request', () => {
        const newBranch = 'new-branch';

        beforeEach(() => {
          emitSubmit({
            branch: newBranch,
            openMergeRequest: true,
          });
        });

        it('redirects to the merge request page with source and target branches', () => {
          const branchesQuery = objectToQuery({
            'merge_request[source_branch]': newBranch,
            'merge_request[target_branch]': mockDefaultBranch,
          });

          expect(redirectTo).toHaveBeenCalledWith(`${mockNewMergeRequestPath}?${branchesQuery}`);
        });
      });

      describe('when the commit is ocurring', () => {
        it('shows a saving state', async () => {
          await mockMutate.mockImplementationOnce(() => {
            expect(findCommitBtnLoadingIcon().exists()).toBe(true);
            return Promise.resolve();
          });

          findCommitForm().vm.$emit('submit', {
            message: mockCommitMessage,
            branch: mockDefaultBranch,
            openMergeRequest: false,
          });
        });
      });

      describe('when the commit fails', () => {
        it('shows a the error message', async () => {
          mockMutate.mockRejectedValueOnce(new Error('commit failed'));

          emitSubmit();

          await waitForPromises();

          expect(findAlert().text()).toBe('CI file could not be saved: commit failed');
        });

        it('shows an unkown error', async () => {
          mockMutate.mockRejectedValueOnce();

          emitSubmit();

          await waitForPromises();

          expect(findAlert().text()).toBe('CI file could not be saved: Unknown Error');
        });
      });

      describe('when the commit is cancelled', () => {
        const otherContent = 'other content';

        beforeEach(async () => {
          findEditorLite().vm.$emit('input', otherContent);
          await nextTick();
        });

        it('content is restored after cancel is called', async () => {
          findCommitForm().vm.$emit('cancel');

          await nextTick();

          expect(findEditorLite().props('value')).toBe(mockCiYml);
        });
      });
    });
  });
});
