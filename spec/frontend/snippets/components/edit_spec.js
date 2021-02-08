import VueApollo, { ApolloMutation } from 'vue-apollo';
import { GlLoadingIcon } from '@gitlab/ui';
import { shallowMount, createLocalVue } from '@vue/test-utils';
import { nextTick } from 'vue';
import { merge } from 'lodash';
import waitForPromises from 'helpers/wait_for_promises';
import createMockApollo from 'helpers/mock_apollo_helper';
import { stubComponent } from 'helpers/stub_component';
import GetSnippetQuery from 'shared_queries/snippet/snippet.query.graphql';
import { deprecatedCreateFlash as Flash } from '~/flash';
import * as urlUtils from '~/lib/utils/url_utility';
import SnippetEditApp from '~/snippets/components/edit.vue';
import CaptchaModal from '~/captcha/captcha_modal.vue';
import SnippetDescriptionEdit from '~/snippets/components/snippet_description_edit.vue';
import SnippetVisibilityEdit from '~/snippets/components/snippet_visibility_edit.vue';
import SnippetBlobActionsEdit from '~/snippets/components/snippet_blob_actions_edit.vue';
import TitleField from '~/vue_shared/components/form/title.vue';
import FormFooterActions from '~/vue_shared/components/form/form_footer_actions.vue';
import {
  SNIPPET_VISIBILITY_PRIVATE,
  SNIPPET_VISIBILITY_INTERNAL,
  SNIPPET_VISIBILITY_PUBLIC,
} from '~/snippets/constants';
import UpdateSnippetMutation from '~/snippets/mutations/updateSnippet.mutation.graphql';
import CreateSnippetMutation from '~/snippets/mutations/createSnippet.mutation.graphql';
import { testEntries, createGQLSnippetsQueryResponse, createGQLSnippet } from '../test_utils';

jest.mock('~/flash');

const TEST_UPLOADED_FILES = ['foo/bar.txt', 'alpha/beta.js'];
const TEST_API_ERROR = new Error('TEST_API_ERROR');
const TEST_MUTATION_ERROR = 'Bummer';
const TEST_CAPTCHA_RESPONSE = 'i-got-a-captcha';
const TEST_CAPTCHA_SITE_KEY = 'abc123';

const TEST_ACTIONS = {
  NO_CONTENT: {
    ...testEntries.created.diff,
    content: '',
  },
  NO_PATH: {
    ...testEntries.created.diff,
    filePath: '',
  },
  VALID: {
    ...testEntries.created.diff,
  },
};

const TEST_WEB_URL = '/snippets/7';
const TEST_SNIPPET_GID = 'gid://gitlab/PersonalSnippet/42';

const createSnippet = () =>
  merge(createGQLSnippet(), {
    webUrl: TEST_WEB_URL,
    visibilityLevel: SNIPPET_VISIBILITY_PRIVATE,
  });

const createQueryResponse = (obj = {}) =>
  createGQLSnippetsQueryResponse([merge(createSnippet(), obj)]);

const createMutationResponseObject = () => ({
  errors: [],
  snippet: {
    __typename: 'Snippet',
    webUrl: TEST_WEB_URL,
  },
  spamLogId: null,
  needsCaptchaResponse: false,
  captchaSiteKey: null,
});

const createMutationResponse = (key, obj = {}) => ({
  data: {
    [key]: merge(createMutationResponseObject(), obj),
  },
});

const createMutationResponseWithErrors = (key) =>
  createMutationResponse(key, { errors: [TEST_MUTATION_ERROR] });

const createMutationResponseWithRecaptcha = (key) =>
  createMutationResponse(key, {
    errors: ['ignored captcha error message'],
    needsCaptchaResponse: true,
    captchaSiteKey: TEST_CAPTCHA_SITE_KEY,
  });

const localVue = createLocalVue();
localVue.use(VueApollo);

describe('Snippet Edit app', () => {
  let wrapper;
  let getSpy;

  // Mutate spy receives a "key" so that we can:
  // - Use the same spy whether we are creating or updating.
  // - Build the correct response object
  // - Assert which mutation was sent
  let mutateSpy;

  const relativeUrlRoot = '/foo/';
  const originalRelativeUrlRoot = gon.relative_url_root;

  beforeEach(() => {
    getSpy = jest.fn().mockResolvedValue(createQueryResponse());

    // See `mutateSpy` declaration comment for why we send a key
    mutateSpy = jest.fn().mockImplementation((key) => Promise.resolve(createMutationResponse(key)));

    gon.relative_url_root = relativeUrlRoot;
    jest.spyOn(urlUtils, 'redirectTo').mockImplementation();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
    gon.relative_url_root = originalRelativeUrlRoot;
  });

  const createComponent = ({ props = {}, selectedLevel = SNIPPET_VISIBILITY_PRIVATE } = {}) => {
    if (wrapper) {
      throw new Error('wrapper already created');
    }

    const requestHandlers = [
      [GetSnippetQuery, getSpy],
      // See `mutateSpy` declaration comment for why we send a key
      [UpdateSnippetMutation, (...args) => mutateSpy('updateSnippet', ...args)],
      [CreateSnippetMutation, (...args) => mutateSpy('createSnippet', ...args)],
    ];
    const apolloProvider = createMockApollo(requestHandlers);

    wrapper = shallowMount(SnippetEditApp, {
      apolloProvider,
      localVue,
      stubs: {
        ApolloMutation,
        FormFooterActions,
        CaptchaModal: stubComponent(CaptchaModal),
      },
      provide: {
        selectedLevel,
      },
      propsData: {
        snippetGid: TEST_SNIPPET_GID,
        markdownPreviewPath: 'http://preview.foo.bar',
        markdownDocsPath: 'http://docs.foo.bar',
        ...props,
      },
    });
  };

  const findBlobActions = () => wrapper.find(SnippetBlobActionsEdit);
  const findCaptchaModal = () => wrapper.find(CaptchaModal);
  const findSubmitButton = () => wrapper.find('[data-testid="snippet-submit-btn"]');
  const findCancelButton = () => wrapper.find('[data-testid="snippet-cancel-btn"]');
  const hasDisabledSubmit = () => Boolean(findSubmitButton().attributes('disabled'));

  const clickSubmitBtn = () => wrapper.find('[data-testid="snippet-edit-form"]').trigger('submit');
  const triggerBlobActions = (actions) => findBlobActions().vm.$emit('actions', actions);
  const setUploadFilesHtml = (paths) => {
    wrapper.vm.$el.innerHTML = paths
      .map((path) => `<input name="files[]" value="${path}">`)
      .join('');
  };
  const getApiData = ({
    id,
    title = '',
    description = '',
    visibilityLevel = SNIPPET_VISIBILITY_PRIVATE,
  } = {}) => ({
    id,
    title,
    description,
    visibilityLevel,
    blobActions: [],
  });
  const setTitle = (val) => wrapper.find(TitleField).vm.$emit('input', val);
  const setDescription = (val) => wrapper.find(SnippetDescriptionEdit).vm.$emit('input', val);

  // Creates comopnent and waits for gql load
  const createComponentAndLoad = async (...args) => {
    createComponent(...args);

    await waitForPromises();
  };

  // Creates loaded component and submits form
  const createComponentAndSubmit = async (...args) => {
    await createComponentAndLoad(...args);

    clickSubmitBtn();

    await waitForPromises();
  };

  describe('when loading', () => {
    it('renders loader', () => {
      createComponent();

      expect(wrapper.find(GlLoadingIcon).exists()).toBe(true);
    });
  });

  describe.each`
    snippetGid          | expectedQueries
    ${TEST_SNIPPET_GID} | ${[[{ ids: [TEST_SNIPPET_GID] }]]}
    ${''}               | ${[]}
  `('when loaded with snippetGid=$snippetGid', ({ snippetGid, expectedQueries }) => {
    beforeEach(() => createComponentAndLoad({ props: { snippetGid } }));

    it(`queries with ${JSON.stringify(expectedQueries)}`, () => {
      expect(getSpy.mock.calls).toEqual(expectedQueries);
    });

    it('should render components', () => {
      expect(wrapper.find(CaptchaModal).exists()).toBe(true);
      expect(wrapper.find(TitleField).exists()).toBe(true);
      expect(wrapper.find(SnippetDescriptionEdit).exists()).toBe(true);
      expect(wrapper.find(SnippetVisibilityEdit).exists()).toBe(true);
      expect(wrapper.find(FormFooterActions).exists()).toBe(true);
      expect(findBlobActions().exists()).toBe(true);
    });

    it('should hide loader', () => {
      expect(wrapper.find(GlLoadingIcon).exists()).toBe(false);
    });
  });

  describe('default', () => {
    it.each`
      title    | actions                                          | shouldDisable
      ${''}    | ${[]}                                            | ${true}
      ${''}    | ${[TEST_ACTIONS.VALID]}                          | ${true}
      ${'foo'} | ${[]}                                            | ${false}
      ${'foo'} | ${[TEST_ACTIONS.VALID]}                          | ${false}
      ${'foo'} | ${[TEST_ACTIONS.VALID, TEST_ACTIONS.NO_CONTENT]} | ${true}
      ${'foo'} | ${[TEST_ACTIONS.VALID, TEST_ACTIONS.NO_PATH]}    | ${false}
    `(
      'should handle submit disable (title="$title", actions="$actions", shouldDisable="$shouldDisable")',
      async ({ title, actions, shouldDisable }) => {
        getSpy.mockResolvedValue(createQueryResponse({ title }));

        await createComponentAndLoad();

        triggerBlobActions(actions);

        await nextTick();

        expect(hasDisabledSubmit()).toBe(shouldDisable);
      },
    );

    it.each`
      props                                                            | expectation
      ${{ projectPath: '', snippetGid: '' }}                           | ${urlUtils.joinPaths('/', relativeUrlRoot, '-', 'snippets')}
      ${{ projectPath: 'project/path', snippetGid: '' }}               | ${urlUtils.joinPaths('/', relativeUrlRoot, 'project/path/-', 'snippets')}
      ${{ projectPath: '', snippetGid: TEST_SNIPPET_GID }}             | ${TEST_WEB_URL}
      ${{ projectPath: 'project/path', snippetGid: TEST_SNIPPET_GID }} | ${TEST_WEB_URL}
    `('should set cancel href with props=$props', async ({ props, expectation }) => {
      await createComponentAndLoad({ props });

      expect(findCancelButton().attributes('href')).toBe(expectation);
    });

    it.each([SNIPPET_VISIBILITY_PRIVATE, SNIPPET_VISIBILITY_INTERNAL, SNIPPET_VISIBILITY_PUBLIC])(
      'marks %s visibility by default',
      async (visibility) => {
        createComponent({
          props: { snippetGid: '' },
          selectedLevel: visibility,
        });

        expect(wrapper.find(SnippetVisibilityEdit).props('value')).toBe(visibility);
      },
    );

    describe('form submission handling', () => {
      it.each`
        props                                                            | uploadedFiles          | input                                                                       | mutationType
        ${{ snippetGid: '', projectPath: 'project/path' }}               | ${[]}                  | ${{ ...getApiData(), projectPath: 'project/path', uploadedFiles: [] }}      | ${'createSnippet'}
        ${{ snippetGid: '', projectPath: '' }}                           | ${[]}                  | ${{ ...getApiData(), projectPath: '', uploadedFiles: [] }}                  | ${'createSnippet'}
        ${{ snippetGid: '', projectPath: '' }}                           | ${TEST_UPLOADED_FILES} | ${{ ...getApiData(), projectPath: '', uploadedFiles: TEST_UPLOADED_FILES }} | ${'createSnippet'}
        ${{ snippetGid: TEST_SNIPPET_GID, projectPath: 'project/path' }} | ${[]}                  | ${getApiData(createSnippet())}                                              | ${'updateSnippet'}
        ${{ snippetGid: TEST_SNIPPET_GID, projectPath: '' }}             | ${[]}                  | ${getApiData(createSnippet())}                                              | ${'updateSnippet'}
      `(
        'should submit mutation with props=$props and uploadedFiles=$uploadedFiles',
        async ({ props, uploadedFiles, mutationType, input }) => {
          await createComponentAndLoad({ props });

          setUploadFilesHtml(uploadedFiles);

          await nextTick();

          clickSubmitBtn();

          expect(mutateSpy).toHaveBeenCalledTimes(1);
          expect(mutateSpy).toHaveBeenCalledWith(mutationType, {
            input,
          });
        },
      );

      it('should redirect to snippet view on successful mutation', async () => {
        await createComponentAndSubmit();

        expect(urlUtils.redirectTo).toHaveBeenCalledWith(TEST_WEB_URL);
      });

      it.each`
        snippetGid          | projectPath       | mutationRes                                          | expectMessage
        ${''}               | ${'project/path'} | ${createMutationResponseWithErrors('createSnippet')} | ${`Can't create snippet: ${TEST_MUTATION_ERROR}`}
        ${''}               | ${''}             | ${createMutationResponseWithErrors('createSnippet')} | ${`Can't create snippet: ${TEST_MUTATION_ERROR}`}
        ${TEST_SNIPPET_GID} | ${'project/path'} | ${createMutationResponseWithErrors('updateSnippet')} | ${`Can't update snippet: ${TEST_MUTATION_ERROR}`}
        ${TEST_SNIPPET_GID} | ${''}             | ${createMutationResponseWithErrors('updateSnippet')} | ${`Can't update snippet: ${TEST_MUTATION_ERROR}`}
      `(
        'should flash error with (snippet=$snippetGid, projectPath=$projectPath)',
        async ({ snippetGid, projectPath, mutationRes, expectMessage }) => {
          mutateSpy.mockResolvedValue(mutationRes);

          await createComponentAndSubmit({
            props: {
              projectPath,
              snippetGid,
            },
          });

          expect(urlUtils.redirectTo).not.toHaveBeenCalled();
          expect(Flash).toHaveBeenCalledWith(expectMessage);
        },
      );

      describe('with apollo network error', () => {
        beforeEach(async () => {
          jest.spyOn(console, 'error').mockImplementation();
          mutateSpy.mockRejectedValue(TEST_API_ERROR);

          await createComponentAndSubmit();
        });

        it('should not redirect', () => {
          expect(urlUtils.redirectTo).not.toHaveBeenCalled();
        });

        it('should flash', () => {
          // Apollo automatically wraps the resolver's error in a NetworkError
          expect(Flash).toHaveBeenCalledWith(
            `Can't update snippet: Network error: ${TEST_API_ERROR.message}`,
          );
        });

        it('should console error', () => {
          // eslint-disable-next-line no-console
          expect(console.error).toHaveBeenCalledTimes(1);
          // eslint-disable-next-line no-console
          expect(console.error).toHaveBeenCalledWith(
            '[gitlab] unexpected error while updating snippet',
            expect.objectContaining({ message: `Network error: ${TEST_API_ERROR.message}` }),
          );
        });
      });

      describe('when needsCaptchaResponse is true', () => {
        let modal;

        beforeEach(async () => {
          mutateSpy
            .mockResolvedValueOnce(createMutationResponseWithRecaptcha('updateSnippet'))
            .mockResolvedValueOnce(createMutationResponseWithErrors('updateSnippet'));

          await createComponentAndSubmit();

          modal = findCaptchaModal();

          mutateSpy.mockClear();
        });

        it('should display captcha modal', () => {
          expect(urlUtils.redirectTo).not.toHaveBeenCalled();
          expect(modal.props()).toEqual({
            needsCaptchaResponse: true,
            captchaSiteKey: TEST_CAPTCHA_SITE_KEY,
          });
        });

        describe.each`
          response                 | expectedCalls
          ${null}                  | ${[]}
          ${TEST_CAPTCHA_RESPONSE} | ${[['updateSnippet', { input: { ...getApiData(createSnippet()), captchaResponse: TEST_CAPTCHA_RESPONSE } }]]}
        `('when captcha response is $response', ({ response, expectedCalls }) => {
          beforeEach(async () => {
            modal.vm.$emit('receivedCaptchaResponse', response);

            await nextTick();
          });

          it('sets needsCaptchaResponse to false', () => {
            expect(modal.props('needsCaptchaResponse')).toEqual(false);
          });

          it(`expected to call times = ${expectedCalls.length}`, () => {
            expect(mutateSpy.mock.calls).toEqual(expectedCalls);
          });
        });
      });
    });
  });

  describe('on before unload', () => {
    it.each([
      ['there are no actions', false, () => triggerBlobActions([])],
      ['there is an empty action', false, () => triggerBlobActions([testEntries.empty.diff])],
      ['there are actions', true, () => triggerBlobActions([testEntries.updated.diff])],
      [
        'the title is set',
        true,
        () => {
          triggerBlobActions([testEntries.empty.diff]);
          setTitle('test');
        },
      ],
      [
        'the description is set',
        true,
        () => {
          triggerBlobActions([testEntries.empty.diff]);
          setDescription('test');
        },
      ],
      [
        'the snippet is being saved',
        false,
        () => {
          triggerBlobActions([testEntries.updated.diff]);
          clickSubmitBtn();
        },
      ],
    ])(
      'handles before unload prevent when %s (expectPrevented=%s)',
      async (_, expectPrevented, action) => {
        await createComponentAndLoad({
          props: {
            snippetGid: '',
          },
        });

        action();

        const event = new Event('beforeunload');
        const returnValueSetter = jest.spyOn(event, 'returnValue', 'set');

        window.dispatchEvent(event);

        if (expectPrevented) {
          expect(returnValueSetter).toHaveBeenCalledWith(
            'Are you sure you want to lose unsaved changes?',
          );
        } else {
          expect(returnValueSetter).not.toHaveBeenCalled();
        }
      },
    );
  });
});
