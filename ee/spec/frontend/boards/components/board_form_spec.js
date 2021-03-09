import { GlModal } from '@gitlab/ui';
import { createLocalVue, shallowMount } from '@vue/test-utils';
import Vuex from 'vuex';

import BoardForm from 'ee/boards/components/board_form.vue';
import createEpicBoardMutation from 'ee/boards/graphql/epic_board_create.mutation.graphql';

import { TEST_HOST } from 'helpers/test_constants';
import waitForPromises from 'helpers/wait_for_promises';

import { formType } from '~/boards/constants';
import { deprecatedCreateFlash as createFlash } from '~/flash';
import { visitUrl } from '~/lib/utils/url_utility';

jest.mock('~/lib/utils/url_utility', () => ({
  visitUrl: jest.fn().mockName('visitUrlMock'),
  stripFinalUrlSegment: jest.requireActual('~/lib/utils/url_utility').stripFinalUrlSegment,
}));
jest.mock('~/flash');

const localVue = createLocalVue();
localVue.use(Vuex);

const currentBoard = {
  id: 1,
  name: 'test',
  labels: [],
  milestone_id: undefined,
  assignee: {},
  assignee_id: undefined,
  weight: null,
  hide_backlog_list: false,
  hide_closed_list: false,
};

const defaultProps = {
  canAdminBoard: false,
  labelsPath: `${TEST_HOST}/labels/path`,
  labelsWebUrl: `${TEST_HOST}/-/labels`,
  currentBoard,
  currentPage: '',
};

describe('BoardForm', () => {
  let wrapper;
  let mutate;
  let location;

  const findModal = () => wrapper.findComponent(GlModal);
  const findModalActionPrimary = () => findModal().props('actionPrimary');
  const findFormWrapper = () => wrapper.find('[data-testid="board-form-wrapper"]');
  const findDeleteConfirmation = () => wrapper.find('[data-testid="delete-confirmation-message"]');
  const findInput = () => wrapper.find('#board-new-name');

  const createStore = () => {
    return new Vuex.Store({
      getters: {
        isEpicBoard: () => true,
      },
    });
  };

  const store = createStore();

  const createComponent = (props) => {
    wrapper = shallowMount(BoardForm, {
      localVue,
      propsData: { ...defaultProps, ...props },
      provide: {
        rootPath: 'root',
      },
      mocks: {
        $apollo: {
          mutate,
        },
      },
      attachTo: document.body,
      store,
    });
  };

  beforeAll(() => {
    location = window.location;
    delete window.location;
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
    mutate = null;
    window.location = location;
  });

  describe('when creating a new epic board', () => {
    describe('on non-scoped-board', () => {
      beforeEach(() => {
        createComponent({ canAdminBoard: true, currentPage: formType.new });
      });

      it('clears the form', () => {
        expect(findInput().element.value).toBe('');
      });

      it('shows a correct title about creating a board', () => {
        expect(findModal().attributes('title')).toBe('Create new board');
      });

      it('passes correct primary action text and variant', () => {
        expect(findModalActionPrimary().text).toBe('Create board');
        expect(findModalActionPrimary().attributes[0].variant).toBe('success');
      });

      it('does not render delete confirmation message', () => {
        expect(findDeleteConfirmation().exists()).toBe(false);
      });

      it('renders form wrapper', () => {
        expect(findFormWrapper().exists()).toBe(true);
      });
    });

    describe('when submitting a create event', () => {
      const fillForm = () => {
        findInput().value = 'Test name';
        findInput().trigger('input');
        findInput().trigger('keyup.enter', { metaKey: true });
      };

      beforeEach(() => {
        mutate = jest.fn().mockResolvedValue({
          data: {
            epicBoardCreate: {
              epicBoard: { id: 'gid://gitlab/Boards::EpicBoard/123', webPath: 'test-path' },
            },
          },
        });
      });

      it('does not call API if board name is empty', async () => {
        createComponent({ canAdminBoard: true, currentPage: formType.new });
        findInput().trigger('keyup.enter', { metaKey: true });

        await waitForPromises();

        expect(mutate).not.toHaveBeenCalled();
      });

      it('calls a correct GraphQL mutation and redirects to correct page from existing board', async () => {
        createComponent({ canAdminBoard: true, currentPage: formType.new });
        fillForm();

        await waitForPromises();

        expect(mutate).toHaveBeenCalledWith({
          mutation: createEpicBoardMutation,
          variables: {
            input: expect.objectContaining({
              name: 'test',
            }),
          },
        });

        await waitForPromises();
        expect(visitUrl).toHaveBeenCalledWith('test-path');
      });

      it('shows an error flash if GraphQL mutation fails', async () => {
        mutate = jest.fn().mockRejectedValue('Houston, we have a problem');
        createComponent({ canAdminBoard: true, currentPage: formType.new });
        fillForm();

        await waitForPromises();

        expect(mutate).toHaveBeenCalled();

        await waitForPromises();
        expect(visitUrl).not.toHaveBeenCalled();
        expect(createFlash).toHaveBeenCalled();
      });
    });
  });
});
