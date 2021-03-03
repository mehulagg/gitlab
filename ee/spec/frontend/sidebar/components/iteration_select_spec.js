import { GlDropdown, GlDropdownItem, GlDropdownText, GlLink, GlSearchBoxByType } from '@gitlab/ui';
import * as Sentry from '@sentry/browser';
import { createLocalVue, shallowMount } from '@vue/test-utils';
import VueApollo from 'vue-apollo';

import IterationSelect from 'ee/sidebar/components/iteration_select.vue';
import { iterationSelectTextMap, iterationDisplayState } from 'ee/sidebar/constants';
import groupIterationsQuery from 'ee/sidebar/queries/group_iterations.query.graphql';
import currentIterationQuery from 'ee/sidebar/queries/issue_iteration.query.graphql';
import setIssueIterationMutation from 'ee/sidebar/queries/set_iteration_on_issue.mutation.graphql';
import createMockApollo from 'helpers/mock_apollo_helper';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import waitForPromises from 'helpers/wait_for_promises';
import createFlash from '~/flash';

import {
  mockIssue,
  mockIterationsResponse,
  mockIteration2,
  mockMutationResponse,
  emptyIterationsResponse,
  noCurrentIterationResponse,
} from '../mock_data';

jest.mock('~/flash');

const localVue = createLocalVue();

describe('IterationSelect', () => {
  let wrapper;
  let mockApollo;
  let showDropdown;

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

  const findIterationItems = () => wrapper.findByTestId('iteration-items');
  const findSelectedIteration = () => wrapper.findByTestId('select-iteration');
  const findNoIterationItem = () => wrapper.findByTestId('no-iteration-item');
  const findLoadingIconTitle = () => wrapper.findByTestId('loading-icon-title');
  const findLoadingIconDropdown = () => wrapper.findByTestId('loading-icon-dropdown');
  const findEditButton = () => wrapper.findByTestId('iteration-edit-link');

  const toggleDropdown = async (spy = () => {}) => {
    findEditButton().vm.$emit('click', { stopPropagation: spy });

    await wrapper.vm.$nextTick();
  };

  const createComponentWithApollo = async ({
    props = { canEdit: true },
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
      shallowMount(IterationSelect, {
        localVue,
        apolloProvider: mockApollo,
        propsData: {
          groupPath: mockIssue.groupPath,
          projectPath: mockIssue.projectPath,
          issueIid: mockIssue.iid,
          ...props,
        },
      }),
    );

    showDropdown = jest.spyOn(wrapper.vm, 'showDropdown').mockImplementation();
  };

  const createComponent = ({
    data = {},
    mutationPromise = mutationSuccess,
    queries = {},
    props = { canEdit: true },
    stubs = { GlSearchBoxByType },
  } = {}) => {
    wrapper = extendedWrapper(
      shallowMount(IterationSelect, {
        data() {
          return data;
        },
        propsData: {
          groupPath: '',
          projectPath: '',
          issueIid: '',
          ...props,
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
        stubs,
      }),
    );

    showDropdown = jest.spyOn(wrapper.vm, 'showDropdown').mockImplementation();
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
      expect(findSelectedIteration().text()).toBe('title');
    });

    it('links to the current iteration', () => {
      expect(findGlLink().attributes().href).toBe('webUrl');
    });

    it('does not show a loading spinner next to the iteration heading', () => {
      expect(findLoadingIconTitle().exists()).toBe(false);
    });

    it('shows a loading spinner while fetching the current iteration', () => {
      createComponent({
        queries: {
          currentIteration: { loading: true },
        },
        stubs: {
          GlDropdown,
        },
      });

      expect(findLoadingIconTitle().exists()).toBe(true);
    });

    it('shows the title of the selected iteration while updating', () => {
      createComponent({
        data: {
          updating: true,
          selectedTitle: 'Some iteration title',
        },
        queries: {
          currentIteration: { loading: false },
        },
        stubs: {
          GlDropdown,
        },
      });

      expect(findLoadingIconTitle().exists()).toBe(true);
      expect(findSelectedIteration().text()).toBe('Some iteration title');
    });

    describe('when current iteration does not exist', () => {
      it('renders "None" as the selected iteration title', () => {
        createComponent({
          stubs: {
            GlDropdown,
          },
        });

        expect(findSelectedIteration().text()).toBe('None');
      });
    });
  });

  describe('when a user cannot edit', () => {
    it('cannot find the edit button', () => {
      createComponent({
        props: { canEdit: false },
        stubs: {
          GlDropdown,
        },
      });

      expect(findEditButton().exists()).toBe(false);
    });
  });

  describe('when a user can edit', () => {
    it('opens the dropdown on click of the edit button', async () => {
      createComponent({ props: { canEdit: true } });

      expect(findDropdown().isVisible()).toBe(false);

      await toggleDropdown();

      expect(findDropdown().isVisible()).toBe(true);
      expect(showDropdown).toHaveBeenCalledTimes(1);
    });

    it('focuses on the input on click of the edit button', async () => {
      createComponent({ props: { canEdit: true } });
      const setFocus = jest.spyOn(wrapper.vm, 'setFocus').mockImplementation();

      await toggleDropdown();

      findDropdown().vm.$emit('shown');

      await wrapper.vm.$nextTick();

      expect(setFocus).toHaveBeenCalledTimes(1);
    });

    it('stops propagation of the click event to avoid opening milestone dropdown', async () => {
      const spy = jest.fn();
      createComponent({ props: { canEdit: true } });

      expect(findDropdown().isVisible()).toBe(false);

      await toggleDropdown(spy);

      expect(spy).toHaveBeenCalledTimes(1);
    });

    describe('when user is editing', () => {
      describe('when rendering the dropdown', () => {
        it('shows a loading spinner while fetching a list of iterations', async () => {
          createComponent({
            queries: {
              iterations: { loading: true },
            },
          });

          await toggleDropdown();

          expect(findLoadingIconDropdown().exists()).toBe(true);
        });

        describe('GlDropdownItem with the right title and id', () => {
          const id = 'id';
          const title = 'title';

          beforeEach(async () => {
            createComponent({
              data: { iterations: [{ id, title }], currentIteration: { id, title } },
            });

            await toggleDropdown();
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

            await toggleDropdown();
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

              await toggleDropdown();

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

                  await toggleDropdown();

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

            await toggleDropdown();

            findSearchBox().vm.$emit('input', 'non existing iterations');

            await wrapper.vm.$nextTick();

            expect(findDropdownText().text()).toBe('No iterations found');
          });
        });
      });

      describe('when the user off clicks', () => {
        describe('when the dropdown is open', () => {
          beforeEach(async () => {
            createComponent();

            await toggleDropdown();
          });

          it('closes the dropdown', async () => {
            expect(findDropdown().isVisible()).toBe(true);

            await toggleDropdown();

            expect(findDropdown().isVisible()).toBe(false);
          });
        });
      });

      // A user might press "ESC" to hide the dropdown.
      // We need to make sure that
      // toggleDropdown() gets called to set 'editing' to 'false'
      describe('when the dropdown emits "hidden"', () => {
        beforeEach(async () => {
          createComponent();

          await toggleDropdown();
        });

        it('should hide the dropdown', async () => {
          expect(findDropdown().isVisible()).toBe(true);

          findDropdown().vm.$emit('hidden');
          await wrapper.vm.$nextTick();

          expect(findDropdown().isVisible()).toBe(false);
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

              await toggleDropdown();
              jest.runOnlyPendingTimers();
              await wrapper.vm.$nextTick();

              findDropdownItemWithText(mockIteration2.title).vm.$emit('click');
            });

            it('calls setIssueIteration mutation', () => {
              expect(setIssueIterationSpy).toHaveBeenCalledWith({
                iid: mockIssue.iid,
                iterationId: mockIteration2.id,
                projectPath: mockIssue.projectPath,
              });
            });

            it('sets the value returned from the mutation to currentIteration', async () => {
              expect(findSelectedIteration().text()).toBe(mockIteration2.title);
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

          await toggleDropdown();
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

          await toggleDropdown();
          jest.runOnlyPendingTimers();

          expect(groupIterationsSpy).toHaveBeenCalled();
        });

        describe('when a user is searching', () => {
          const mockSearchTerm = 'foobar';

          beforeEach(async () => {
            groupIterationsSpy = jest.fn().mockResolvedValueOnce(emptyIterationsResponse);
            createComponentWithApollo({ groupIterationsSpy });

            await toggleDropdown();
          });

          it('sends a groupIterations query with the entered search term "foo"', async () => {
            findSearchBox().vm.$emit('input', mockSearchTerm);

            await wrapper.vm.$nextTick();
            jest.runOnlyPendingTimers();

            expect(groupIterationsSpy).toHaveBeenNthCalledWith(1, {
              fullPath: mockIssue.groupPath,
              title: `"${mockSearchTerm}"`,
              state: iterationDisplayState,
            });
          });
        });
      });
    });
  });
});
//
