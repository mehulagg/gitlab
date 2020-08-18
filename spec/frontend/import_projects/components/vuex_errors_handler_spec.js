import { shallowMount } from '@vue/test-utils';
import createFlash from '~/flash';
import {
  RECEIVE_REPOS_ERROR,
  RECEIVE_IMPORT_ERROR,
  RECEIVE_JOBS_ERROR,
  RECEIVE_NAMESPACES_ERROR,
} from '~/import_projects/store/mutation_types';
import VuexErrorsHandler from '~/import_projects/components/vuex_errors_handler.vue';
import WatchStoreMutation from '~/vue_shared/components/watch_store_mutation.vue';
import { visitUrl } from '~/lib/utils/url_utility';

jest.mock('~/flash');
jest.mock('~/lib/utils/url_utility', () => ({
  visitUrl: jest.fn(),
}));

const DUMMY_ERROR_PAYLOAD = { error: {} };

describe('VuexErrorsHandler', () => {
  let wrapper;

  const findMutationWatcher = type =>
    wrapper
      .findAll(WatchStoreMutation)
      .filter(w => w.props().type === type)
      .at(0);

  const PROVIDER_TITLE = 'dummy-provider';

  beforeEach(() => {
    wrapper = shallowMount(VuexErrorsHandler, {
      propsData: { providerTitle: PROVIDER_TITLE },
    });
  });

  describe('handles receive repos error', () => {
    const mutation = RECEIVE_REPOS_ERROR;
    it(`watches for ${mutation} mutation`, () => {
      expect(findMutationWatcher(mutation).exists()).toBe(true);
    });

    it('shows flash when error occurs', () => {
      findMutationWatcher(mutation).vm.$emit('mutation', DUMMY_ERROR_PAYLOAD);

      expect(createFlash).toHaveBeenCalledWith({
        message: `Requesting your ${PROVIDER_TITLE} repositories failed`,
      });
    });

    it('invokes redirect when requested', () => {
      const DUMMY_URL = 'http://dummy.path';

      findMutationWatcher(mutation).vm.$emit('mutation', {
        error: {
          redirectUrl: DUMMY_URL,
        },
      });

      expect(visitUrl).toHaveBeenCalledWith(DUMMY_URL);
    });
  });

  describe('handles receive namespaces error', () => {
    const mutation = RECEIVE_NAMESPACES_ERROR;
    it(`watches for ${mutation} mutation`, () => {
      expect(findMutationWatcher(mutation).exists()).toBe(true);
    });

    it('shows flash when error occurs', () => {
      findMutationWatcher(mutation).vm.$emit('mutation', DUMMY_ERROR_PAYLOAD);

      expect(createFlash).toHaveBeenCalledWith({ message: 'Requesting namespaces failed' });
    });
  });

  describe('handles importing project error', () => {
    const mutation = RECEIVE_IMPORT_ERROR;
    it(`watches for ${mutation} mutation`, () => {
      expect(findMutationWatcher(mutation).exists()).toBe(true);
    });

    it('shows flash with generic error message if no server-side error message provided', () => {
      findMutationWatcher(mutation).vm.$emit('mutation', DUMMY_ERROR_PAYLOAD);

      expect(createFlash).toHaveBeenCalledWith({ message: 'Importing the project failed' });
    });

    it('shows flash with server-side error message if provided', () => {
      const MESSAGE = 'dummy message';
      findMutationWatcher(mutation).vm.$emit('mutation', { error: { reason: MESSAGE } });

      expect(createFlash).toHaveBeenCalledWith({
        message: `Importing the project failed: ${MESSAGE}`,
      });
    });
  });

  describe('handles receive jobs error', () => {
    const mutation = RECEIVE_JOBS_ERROR;
    it(`watches for ${mutation} mutation`, () => {
      expect(findMutationWatcher(mutation).exists()).toBe(true);
    });

    it('shows flash when error occurs', () => {
      findMutationWatcher(mutation).vm.$emit('mutation', DUMMY_ERROR_PAYLOAD);

      expect(createFlash).toHaveBeenCalledWith({
        message: 'Update of imported projects with realtime changes failed',
      });
    });

    it('invokes redirect when requested', () => {
      const DUMMY_URL = 'http://dummy.path';

      findMutationWatcher(mutation).vm.$emit('mutation', {
        error: {
          redirectUrl: DUMMY_URL,
        },
      });

      expect(visitUrl).toHaveBeenCalledWith(DUMMY_URL);
    });
  });
});
