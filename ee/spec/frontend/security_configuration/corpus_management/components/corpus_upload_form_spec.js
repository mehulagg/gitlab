import { createLocalVue, mount } from '@vue/test-utils';
import VueApollo from 'vue-apollo';
import CorpusUploadForm from 'ee/security_configuration/corpus_management/components/corpus_upload_form.vue';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';

const TEST_PROJECT_FULL_PATH = '/namespace/project';

const localVue = createLocalVue();
localVue.use(VueApollo);

let mockTotalSize;
let mockData;
let mockIsUploading;
let mockProgress;

const mockResolver = {
  Query: {
    /* eslint-disable no-unused-vars */
    mockedPackages(_, { projectPath }) {
      return {
        totalSize: mockTotalSize(),
        data: mockData(),
        __typename: 'MockedPackages',
      };
    },
    /* eslint-disable no-unused-vars */
    uploadState(_, { projectPath }) {
      return {
        isUploading: mockIsUploading(),
        progress: mockProgress(),
        __typename: 'UploadState',
      };
    },
  },
};

describe('Corpus upload modal', () => {
  let wrapper;

  const findCorpusName = () => wrapper.find('[data-testid="corpus-name"]');
  const findUploadAttachment = () => wrapper.find('[data-testid="upload-attachment-button"]');
  const findUploadCorpus = () => wrapper.find('[data-testid="upload-corpus"]');
  const findUploadStatus = () => wrapper.find('[data-testid="upload-status"]');

  const createMockApolloProvider = (resolverMock) => {
    return createMockApollo([], resolverMock);
  };

  const createComponent = (resolverMock, options = {}) => {
    wrapper = mount(CorpusUploadForm, {
      localVue,
      apolloProvider: createMockApolloProvider(resolverMock),
      provide: {
        projectFullPath: TEST_PROJECT_FULL_PATH,
      },
      ...options,
    });
  };

  beforeEach(() => {
    mockTotalSize = jest.fn();
    mockData = jest.fn();
    mockIsUploading = jest.fn();
    mockProgress = jest.fn();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('corpus modal', () => {
    describe('initial state', () => {
      beforeEach(() => {
        const data = () => {
          return {
            attachmentName: '',
            corpusName: '',
            files: [],
            uploadTimeout: null,
          };
        };

        mockTotalSize.mockResolvedValue(0);
        mockData.mockResolvedValue([]);
        mockIsUploading.mockResolvedValue(false);
        mockProgress.mockResolvedValue(0);

        createComponent(mockResolver, { data });
      });

      it('shows empty name field', () => {
        expect(findCorpusName().element.value).toBe('');
      });

      it('shows the choose file button', () => {
        expect(findUploadAttachment().exists()).toBe(true);
      });

      it('does not show the upload corpus button', () => {
        expect(findUploadCorpus().exists()).toBe(false);
      });

      it('does not show the upload progress', () => {
        expect(findUploadStatus().exists()).toBe(false);
      });
    });

    describe('file selected state', () => {
      const attachmentName = 'corpus.zip';
      const corpusName = 'User entered name';

      beforeEach(() => {
        const data = () => {
          return {
            attachmentName,
            corpusName,
            files: [attachmentName],
            uploadTimeout: null,
          };
        };

        mockTotalSize.mockResolvedValue(0);
        mockData.mockResolvedValue([]);
        mockIsUploading.mockResolvedValue(false);
        mockProgress.mockResolvedValue(0);

        createComponent(mockResolver, { data });
      });

      it('shows name field', () => {
        expect(findCorpusName().element.value).toBe(corpusName);
      });

      it('shows the choose file button', () => {
        expect(findUploadAttachment().exists()).toBe(true);
      });

      it('shows the upload corpus button', () => {
        expect(findUploadCorpus().exists()).toBe(true);
      });

      it('does not show the upload progress', () => {
        expect(findUploadStatus().exists()).toBe(false);
      });
    });

    describe('uploading state', () => {
      const attachmentName = 'corpus.zip';
      const corpusName = 'User entered name';

      beforeEach(async () => {
        const data = () => {
          return {
            attachmentName,
            corpusName,
            files: [attachmentName],
            uploadTimeout: null,
          };
        };

        mockTotalSize.mockResolvedValue(0);
        mockData.mockResolvedValue([]);
        mockIsUploading.mockResolvedValue(true);
        mockProgress.mockResolvedValue(25);

        createComponent(mockResolver, { data });

        await waitForPromises();
      });

      it('shows name field', () => {
        expect(findCorpusName().element.value).toBe(corpusName);
      });

      it('shows the choose file button as disabled', () => {
        expect(findUploadAttachment().exists()).toBe(true);
        expect(findUploadAttachment().attributes('disabled')).toBe('disabled');
      });

      it('does not show the upload corpus button', () => {
        expect(findUploadCorpus().exists()).toBe(false);
      });

      it('does show the upload progress', () => {
        expect(findUploadStatus().exists()).toBe(true);
        expect(findUploadStatus().element).toMatchSnapshot();
      });
    });

    describe('file uploaded state', () => {
      const attachmentName = 'corpus.zip';
      const corpusName = 'User entered name';

      beforeEach(async () => {
        const data = () => {
          return {
            attachmentName,
            corpusName,
            files: [attachmentName],
            uploadTimeout: null,
          };
        };

        mockTotalSize.mockResolvedValue(0);
        mockData.mockResolvedValue([]);
        mockIsUploading.mockResolvedValue(false);
        mockProgress.mockResolvedValue(100);

        createComponent(mockResolver, { data });

        await waitForPromises();
      });

      it('shows name field', () => {
        expect(findCorpusName().element.value).toBe(corpusName);
      });

      it('does not show the choose file button', () => {
        expect(findUploadAttachment().exists()).toBe(false);
      });

      it('does not show the upload corpus button', () => {
        expect(findUploadCorpus().exists()).toBe(false);
      });

      it('does not show the upload progress', () => {
        expect(findUploadStatus().exists()).toBe(false);
      });
    });
  });
});
