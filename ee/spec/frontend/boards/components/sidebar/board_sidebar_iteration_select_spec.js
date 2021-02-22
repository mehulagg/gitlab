import { GlDropdown, GlDropdownItem, GlDropdownText, GlLink, GlSearchBoxByType } from '@gitlab/ui';
import * as Sentry from '@sentry/browser';

import { createLocalVue, shallowMount } from '@vue/test-utils';
import VueApollo from 'vue-apollo';
import Vuex from 'vuex';

import BoardSidebarIterationSelect from 'ee/boards/components/sidebar/board_sidebar_iteration_select.vue';
import { iterationSelectTextMap, iterationDisplayState } from 'ee/sidebar/constants';
import groupIterationsQuery from 'ee/sidebar/queries/group_iterations.query.graphql';
import currentIterationQuery from 'ee/sidebar/queries/issue_iteration.query.graphql';
import setIssueIterationMutation from 'ee/sidebar/queries/set_iteration_on_issue.mutation.graphql';
import createMockApollo from 'helpers/mock_apollo_helper';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import waitForPromises from 'helpers/wait_for_promises';
import BoardEditableItem from '~/boards/components/sidebar/board_editable_item.vue';
import getters from '~/boards/stores/getters';
import createFlash from '~/flash';

import {
  mockIssue2 as mockIssue,
  mockProjectPath,
  mockGroupPath,
  mockIterationsResponse,
  mockIteration2,
  mockMutationResponse,
  emptyIterationsResponse,
  noCurrentIterationResponse,
} from '../../../sidebar/mock_data';

jest.mock('~/flash');

const localVue = createLocalVue();
localVue.use(Vuex);

describe('BoardSidebarIterationSelect', () => {
  let wrapper;
  let store;
  let mockApollo;

  const promiseData = { issueSetIteration: { issue: { iteration: { id: '123' } } } };
  const firstErrorMsg = 'first error';
  const promiseWithErrors = {
    ...promiseData,
    issueSetIteration: { ...promiseData.issueSetIteration, errors: [firstErrorMsg] },
  };

  const mutationSuccess = () => jest.fn().mockResolvedValue({ data: promiseData });
  const mutationError = () => jest.fn().mockRejectedValue();
  const mutationSuccessWithErrors = () => jest.fn().mockResolvedValue({ data: promiseWithErrors });

  const findGlLink = () => wrapper.find(GlLink);
  const findDropdown = () => wrapper.find(GlDropdown);
  const findDropdownText = () => wrapper.find(GlDropdownText);
  const findSearchBox = () => wrapper.find(GlSearchBoxByType);
  const findAllDropdownItems = () => wrapper.findAll(GlDropdownItem);
  const findDropdownItemWithText = (text) =>
    findAllDropdownItems().wrappers.find((x) => x.text() === text);
  const findBoardEditableItem = () => wrapper.find(BoardEditableItem);

  const findIterationItems = () => wrapper.findByTestId('iteration-items');
  const findCollapsed = () => wrapper.find('[data-testid="collapsed-content"]');
  const findNoIterationItem = () => wrapper.findByTestId('no-iteration-item');
  const findLoadingIconDropdown = () => wrapper.findByTestId('loading-icon-dropdown');

  const clickEdit = async () => {
    findBoardEditableItem().vm.$emit('open');

    await wrapper.vm.$nextTick();
  };

  const createStore = ({
    initialState = {
      activeId: mockIssue.id,
      boardItems: { [mockIssue.id]: { ...mockIssue } },
    },
  } = {}) => {
    store = new Vuex.Store({
      state: initialState,
      getters,
    });
  };

  const createComponentWithApollo = async ({
    requestHandlers = [],
    currentIterationSpy = jest.fn().mockResolvedValue(noCurrentIterationResponse),
    groupIterationsSpy = jest.fn().mockResolvedValue(mockIterationsResponse),
  } = {}) => {
    localVue.use(VueApollo);
    mockApollo = createMockApollo([
      [currentIterationQuery, currentIterationSpy],
      [groupIterationsQuery, groupIterationsSpy],
      ...requestHandlers,
    ]);

    wrapper = extendedWrapper(
      shallowMount(BoardSidebarIterationSelect, {
        localVue,
        store,
        apolloProvider: mockApollo,
        provide: {
          canUpdate: true,
        },
        stubs: {
          BoardEditableItem,
        },
      }),
    );

    wrapper.vm.$refs.dropdown.show = jest.fn();
  };

  const createComponent = ({
    data = {},
    mutationPromise = mutationSuccess,
    queries = {},
    stubs = { GlSearchBoxByType },
  } = {}) => {
    createStore();

    wrapper = extendedWrapper(
      shallowMount(BoardSidebarIterationSelect, {
        localVue,
        store,
        data() {
          return data;
        },
        provide: {
          canUpdate: true,
        },
        mocks: {
          $apollo: {
            mutate: mutationPromise(),
            queries: {
              currentIteration: { loading: false },
              iterations: { loading: false },
              ...queries,
            },
          },
        },
        stubs: {
          BoardEditableItem,
          ...stubs,
        },
      }),
    );

    wrapper.vm.$refs.dropdown.show = jest.fn();
    wrapper.vm.$refs.editableItem.collapse = jest.fn();
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('when not editing', () => {
    beforeEach(() => {
      createComponent({
        data: {
          currentIteration: { id: 'id', title: 'title', webUrl: 'webUrl' },
        },
        stubs: {
          GlDropdown,
        },
      });
    });

    it('shows the current iteration', () => {
      expect(findCollapsed().text()).toBe('title');
    });

    it('links to the current iteration', () => {
      expect(findGlLink().attributes().href).toBe('webUrl');
    });

    describe('when current iteration does not exist', () => {
      it('renders "None" as the selected iteration title', () => {
        createComponent({
          stubs: {
            GlDropdown,
          },
        });

        expect(findCollapsed().text()).toBe('None');
      });
    });

    it('expands the dropdown on clicking edit', async () => {
      createComponent();

      await clickEdit();

      expect(wrapper.vm.$refs.dropdown.show).toHaveBeenCalledTimes(1);
    });
  });

  describe('when user is editing', () => {
    describe('when rendering the dropdown', () => {
      it('collapses BoardEditableItem on clicking edit', async () => {
        createComponent();

        await findBoardEditableItem().vm.$emit('close');

        expect(wrapper.vm.$refs.editableItem.collapse).toHaveBeenCalledTimes(1);
      });

      it('collapses BoardEditableItem on hiding dropdown', async () => {
        createComponent();

        await findDropdown().vm.$emit('hide');

        expect(wrapper.vm.$refs.editableItem.collapse).toHaveBeenCalledTimes(1);
      });

      it('shows a loading spinner while fetching a list of iterations', async () => {
        createComponent({
          queries: {
            iterations: { loading: true },
          },
        });

        await clickEdit();

        expect(findLoadingIconDropdown().exists()).toBe(true);
      });

      describe('GlDropdownItem with the right title and id', () => {
        const id = 'id';
        const title = 'title';

        beforeEach(async () => {
          createComponent({
            data: { iterations: [{ id, title }], currentIteration: { id, title } },
          });

          await clickEdit();
        });

        it('does not show a loading spinner', () => {
          expect(findLoadingIconDropdown().exists()).toBe(false);
        });

        it('renders title $title', () => {
          expect(findDropdownItemWithText(title).text()).toBe(title);
        });

        it('checks the correct dropdown item', () => {
          expect(
            findAllDropdownItems()
              .filter((w) => w.props('isChecked') === true)
              .at(0)
              .text(),
          ).toBe(title);
        });
      });

      describe('when no data is assigned', () => {
        beforeEach(async () => {
          createComponent();

          await clickEdit();
        });

        it('finds GlDropdownItem with "No iteration"', () => {
          expect(findNoIterationItem().text()).toBe('No iteration');
        });

        it('"No iteration" is checked', () => {
          expect(findNoIterationItem().props('isChecked')).toBe(true);
        });

        it('does not render any dropdown item', () => {
          expect(findIterationItems().exists()).toBe(false);
        });
      });

      describe('when clicking on dropdown item', () => {
        describe('when currentIteration is equal to iteration id', () => {
          it('does not call setIssueIteration mutation', async () => {
            createComponent({
              data: {
                iterations: [{ id: 'id', title: 'title' }],
                currentIteration: { id: 'id', title: 'title' },
              },
            });

            await clickEdit();

            findDropdownItemWithText('title').vm.$emit('click');

            expect(wrapper.vm.$apollo.mutate).toHaveBeenCalledTimes(0);
          });
        });

        describe('when currentIteration is not equal to iteration id', () => {
          describe('when error', () => {
            const bootstrapComponent = (mutationResp) => {
              createComponent({
                data: {
                  iterations: [
                    { id: '123', title: '123' },
                    { id: 'id', title: 'title' },
                  ],
                  currentIteration: '123',
                },
                mutationPromise: mutationResp,
              });
            };

            describe.each`
              description                 | mutationResp                 | expectedMsg
              ${'top-level error'}        | ${mutationError}             | ${iterationSelectTextMap.iterationSelectFail}
              ${'user-recoverable error'} | ${mutationSuccessWithErrors} | ${firstErrorMsg}
            `(`$description`, ({ mutationResp, expectedMsg }) => {
              beforeEach(async () => {
                bootstrapComponent(mutationResp);

                await clickEdit();

                findDropdownItemWithText('title').vm.$emit('click');
              });

              it('calls createFlash with $expectedMsg', async () => {
                await wrapper.vm.$nextTick();
                expect(createFlash).toHaveBeenCalledWith(expectedMsg);
              });
            });
          });
        });
      });
    });

    describe('when a user is searching', () => {
      describe('when search result is not found', () => {
        it('renders "No iterations found"', async () => {
          createComponent();

          await clickEdit();

          findSearchBox().vm.$emit('input', 'non existing iterations');

          await wrapper.vm.$nextTick();

          expect(findDropdownText().text()).toBe('No iterations found');
        });
      });
    });
  });

  describe('With mock apollo', () => {
    let error;

    beforeEach(() => {
      jest.spyOn(Sentry, 'captureException');
      error = new Error('mayday');
    });

    describe('when clicking on dropdown item', () => {
      describe('when currentIteration is not equal to iteration id', () => {
        let setIssueIterationSpy;

        describe('when update is successful', () => {
          setIssueIterationSpy = jest.fn().mockResolvedValue(mockMutationResponse);
          beforeEach(async () => {
            createComponentWithApollo({
              requestHandlers: [[setIssueIterationMutation, setIssueIterationSpy]],
            });

            await clickEdit();
            jest.runOnlyPendingTimers();
            await wrapper.vm.$nextTick();

            findDropdownItemWithText(mockIteration2.title).vm.$emit('click');
          });

          it('calls setIssueIteration mutation', () => {
            expect(setIssueIterationSpy).toHaveBeenCalledWith({
              iid: mockIssue.iid,
              iterationId: mockIteration2.id,
              projectPath: mockProjectPath,
            });
          });

          it('sets the value returned from the mutation to currentIteration', async () => {
            expect(findCollapsed().text()).toBe(mockIteration2.title);
          });
        });
      });
    });

    describe('currentIterations', () => {
      it('should call createFlash and Sentry if currentIterations query fails', async () => {
        createComponentWithApollo({
          currentIterationSpy: jest.fn().mockRejectedValue(error),
        });

        await waitForPromises();

        expect(createFlash).toHaveBeenNthCalledWith(1, {
          message: wrapper.vm.$options.i18n.currentIterationFetchError,
        });
        expect(Sentry.captureException.mock.calls[0][0].networkError).toBe(error);
      });
    });

    describe('iterations', () => {
      let groupIterationsSpy;

      it('should call createFlash and Sentry if iterations query fails', async () => {
        createComponentWithApollo({
          groupIterationsSpy: jest.fn().mockRejectedValue(error),
        });

        await clickEdit();
        jest.runOnlyPendingTimers();
        await waitForPromises();

        expect(createFlash).toHaveBeenNthCalledWith(1, {
          message: wrapper.vm.$options.i18n.iterationsFetchError,
        });
        expect(Sentry.captureException.mock.calls[0][0].networkError).toBe(error);
      });

      it('only fetches iterations when dropdown is opened', async () => {
        groupIterationsSpy = jest.fn().mockResolvedValueOnce(emptyIterationsResponse);
        createComponentWithApollo({ groupIterationsSpy });

        await wrapper.vm.$nextTick();
        jest.runOnlyPendingTimers();

        expect(groupIterationsSpy).not.toHaveBeenCalled();

        await clickEdit();
        jest.runOnlyPendingTimers();

        expect(groupIterationsSpy).toHaveBeenCalled();
      });

      describe('when a user is searching', () => {
        const mockSearchTerm = 'foobar';

        beforeEach(async () => {
          groupIterationsSpy = jest.fn().mockResolvedValueOnce(emptyIterationsResponse);
          createComponentWithApollo({ groupIterationsSpy });

          await clickEdit();
        });

        it('sends a groupIterations query with the entered search term "foo"', async () => {
          findSearchBox().vm.$emit('input', mockSearchTerm);

          await wrapper.vm.$nextTick();
          jest.runOnlyPendingTimers();

          expect(groupIterationsSpy).toHaveBeenNthCalledWith(1, {
            fullPath: mockGroupPath,
            title: `"${mockSearchTerm}"`,
            state: iterationDisplayState,
          });
        });
      });
    });
  });
});
