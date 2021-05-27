import {
  GlDropdown,
  GlDropdownItem,
  GlDropdownText,
  GlLink,
  GlSearchBoxByType,
  GlFormInput,
  GlLoadingIcon,
} from '@gitlab/ui';
import * as Sentry from '@sentry/browser';
import { createLocalVue, shallowMount, mount } from '@vue/test-utils';
import VueApollo from 'vue-apollo';

import SidebarIterationWidget from 'ee/sidebar/components/sidebar_iteration_widget.vue';
import { iterationSelectTextMap, iterationDisplayState } from 'ee/sidebar/constants';
import groupIterationsQuery from 'ee/sidebar/queries/group_iterations.query.graphql';
import projectIssueIterationMutation from 'ee/sidebar/queries/project_issue_iteration.mutation.graphql';
import projectIssueIterationQuery from 'ee/sidebar/queries/project_issue_iteration.query.graphql';
import createMockApollo from 'helpers/mock_apollo_helper';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import waitForPromises from 'helpers/wait_for_promises';
import createFlash from '~/flash';
import { IssuableType } from '~/issue_show/constants';
import SidebarEditableItem from '~/sidebar/components/sidebar_editable_item.vue';

import {
  mockIssue,
  mockGroupIterationsResponse,
  mockIteration2,
  mockIterationMutationResponse,
  emptyGroupIterationsResponse,
  noCurrentIterationResponse,
} from '../mock_data';

jest.mock('~/flash');

const localVue = createLocalVue();

describe('SidebarIterationWidget', () => {
  let wrapper;
  let mockApollo;

  const promiseData = { issuableSetIteration: { issue: { iteration: { id: '123' } } } };
  const firstErrorMsg = 'first error';
  const promiseWithErrors = {
    ...promiseData,
    issuableSetIteration: { ...promiseData.issuableSetIteration, errors: [firstErrorMsg] },
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

  const findSidebarEditableItem = () => wrapper.findComponent(SidebarEditableItem);
  const findEditButton = () => findSidebarEditableItem().find('[data-testid="edit-button"]');
  const findEditableLoadingIcon = () => findSidebarEditableItem().find(GlLoadingIcon);
  const findIterationItems = () => wrapper.findByTestId('iteration-items');
  const findSelectedIteration = () => wrapper.findByTestId('select-iteration');
  const findNoIterationItem = () => wrapper.findByTestId('no-iteration-item');
  const findLoadingIconDropdown = () => wrapper.findByTestId('loading-icon-dropdown');

  const waitForDropdown = async () => {
    // BDropdown first changes its `visible` property
    // in a requestAnimationFrame callback.
    // It then emits `shown` event in a watcher for `visible`
    // Hence we need both of these:
    await waitForPromises();
    await wrapper.vm.$nextTick();
  };

  const waitForApollo = async () => {
    jest.runOnlyPendingTimers();
    await waitForPromises();
  };

  // Used with createComponentWithApollo which uses 'mount'
  const clickEdit = async () => {
    await findEditButton().trigger('click');

    await waitForDropdown();

    // We should wait for iterations list to be fetched.
    await waitForApollo();
  };

  // Used with createComponent which shallow mounts components
  const toggleDropdown = async () => {
    wrapper.vm.$refs.editable.expand();

    await waitForDropdown();
  };

  const createComponentWithApollo = async ({
    requestHandlers = [],
    currentIterationSpy = jest.fn().mockResolvedValue(noCurrentIterationResponse),
    groupIterationsSpy = jest.fn().mockResolvedValue(mockGroupIterationsResponse),
  } = {}) => {
    localVue.use(VueApollo);
    mockApollo = createMockApollo([
      [projectIssueIterationQuery, currentIterationSpy],
      [groupIterationsQuery, groupIterationsSpy],
      ...requestHandlers,
    ]);

    wrapper = extendedWrapper(
      mount(SidebarIterationWidget, {
        localVue,
        provide: { canUpdate: true },
        apolloProvider: mockApollo,
        propsData: {
          workspacePath: mockIssue.projectPath,
          iterationsWorkspacePath: mockIssue.groupPath,
          iid: mockIssue.iid,
          issuableType: IssuableType.Issue,
        },
        attachTo: document.body,
      }),
    );

    await waitForApollo();
  };

  const createComponent = ({ data = {}, mutationPromise = mutationSuccess, queries = {} } = {}) => {
    wrapper = extendedWrapper(
      shallowMount(SidebarIterationWidget, {
        provide: { canUpdate: true },
        data() {
          return data;
        },
        propsData: {
          workspacePath: '',
          iterationsWorkspacePath: '',
          iid: '',
          issuableType: IssuableType.Issue,
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
          SidebarEditableItem,
          GlSearchBoxByType,
          GlDropdown,
        },
      }),
    );

    // We need to mock out `showDropdown` which
    // invokes `show` method of BDropdown used inside GlDropdown.
    jest.spyOn(wrapper.vm, 'showDropdown').mockImplementation();
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
          SidebarEditableItem,
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
      expect(findEditableLoadingIcon().exists()).toBe(false);
    });

    it('shows a loading spinner while fetching the current iteration', () => {
      createComponent({
        queries: {
          currentIteration: { loading: true },
        },
      });

      expect(findEditableLoadingIcon().exists()).toBe(true);
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
      });

      expect(findEditableLoadingIcon().exists()).toBe(true);
      expect(findSelectedIteration().text()).toBe('Some iteration title');
    });

    describe('when current iteration does not exist', () => {
      it('renders "None" as the selected iteration title', () => {
        createComponent();

        expect(findSelectedIteration().text()).toBe('None');
      });
    });
  });

  describe('when a user can edit', () => {
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

                it(`calls createFlash with "${expectedMsg}"`, async () => {
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
    });
  });

  describe('with mock apollo', () => {
    let error;

    beforeEach(() => {
      jest.spyOn(Sentry, 'captureException');
      error = new Error('mayday');
    });

    describe("when issuable type is 'issue'", () => {
      describe('when dropdown is expanded and user can edit', () => {
        let iterationMutationSpy;
        beforeEach(async () => {
          iterationMutationSpy = jest.fn().mockResolvedValue(mockIterationMutationResponse);

          await createComponentWithApollo({
            requestHandlers: [[projectIssueIterationMutation, iterationMutationSpy]],
          });

          await clickEdit();
        });

        it('renders the dropdown on clicking edit', async () => {
          expect(findDropdown().isVisible()).toBe(true);
        });

        it('focuses on the input when dropdown is shown', async () => {
          expect(document.activeElement).toEqual(wrapper.find(GlFormInput).element);
        });

        describe('when currentIteration is not equal to iteration id', () => {
          describe('when update is successful', () => {
            beforeEach(() => {
              findDropdownItemWithText(mockIteration2.title).vm.$emit('click');
            });

            it('calls setIssueIteration mutation', () => {
              expect(iterationMutationSpy).toHaveBeenCalledWith({
                iid: mockIssue.iid,
                iterationId: mockIteration2.id,
                fullPath: mockIssue.projectPath,
              });
            });

            it('sets the value returned from the mutation to currentIteration', async () => {
              expect(findSelectedIteration().text()).toBe(mockIteration2.title);
            });
          });
        });

        describe('iterations', () => {
          let groupIterationsSpy;

          it('should call createFlash and Sentry if iterations query fails', async () => {
            await createComponentWithApollo({
              groupIterationsSpy: jest.fn().mockRejectedValue(error),
            });

            await clickEdit();

            expect(createFlash).toHaveBeenNthCalledWith(1, {
              message: wrapper.vm.$options.i18n.iterationsFetchError,
            });
            expect(Sentry.captureException.mock.calls[0][0].networkError).toBe(error);
          });

          it('only fetches iterations when dropdown is opened', async () => {
            groupIterationsSpy = jest.fn().mockResolvedValueOnce(emptyGroupIterationsResponse);
            await createComponentWithApollo({ groupIterationsSpy });

            expect(groupIterationsSpy).not.toHaveBeenCalled();

            await clickEdit();

            expect(groupIterationsSpy).toHaveBeenNthCalledWith(1, {
              fullPath: mockIssue.groupPath,
              title: '',
              state: iterationDisplayState,
            });
          });

          describe('when a user is searching', () => {
            const mockSearchTerm = 'foobar';

            beforeEach(async () => {
              groupIterationsSpy = jest.fn().mockResolvedValueOnce(emptyGroupIterationsResponse);
              await createComponentWithApollo({ groupIterationsSpy });

              await clickEdit();
            });

            it('sends a groupIterations query with the entered search term "foo"', async () => {
              findSearchBox().vm.$emit('input', mockSearchTerm);
              await wrapper.vm.$nextTick();

              // Account for debouncing
              jest.runAllTimers();

              expect(groupIterationsSpy).toHaveBeenNthCalledWith(2, {
                fullPath: mockIssue.groupPath,
                title: mockSearchTerm,
                state: iterationDisplayState,
              });
            });
          });
        });
      });

      describe('currentIterations', () => {
        it('should call createFlash and Sentry if currentIterations query fails', async () => {
          await createComponentWithApollo({
            currentIterationSpy: jest.fn().mockRejectedValue(error),
          });

          expect(createFlash).toHaveBeenNthCalledWith(1, {
            message: wrapper.vm.$options.i18n.currentIterationFetchError,
          });
          expect(Sentry.captureException.mock.calls[0][0].networkError).toBe(error);
        });
      });
    });
  });
});
