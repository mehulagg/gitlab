import { GlModal, GlFormInput, GlSprintf, GlAlert, GlIcon } from '@gitlab/ui';
import * as Sentry from '@sentry/browser';
import { shallowMount } from '@vue/test-utils';
import { nextTick } from 'vue';
import { ApolloMutation } from 'vue-apollo';
import DevopsAdoptionSegmentModal from 'ee/analytics/devops_report/devops_adoption/components/devops_adoption_segment_modal.vue';
import { DEVOPS_ADOPTION_SEGMENT_MODAL_ID } from 'ee/analytics/devops_report/devops_adoption/constants';
import waitForPromises from 'helpers/wait_for_promises';
import {
  groupNodes,
  groupIds,
  groupGids,
  genericErrorMessage,
  dataErrorMessage,
  groupNodeLabelValues,
  devopsAdoptionSegmentsData,
} from '../mock_data';

const mockEvent = { preventDefault: jest.fn() };
const mutate = jest.fn().mockResolvedValue({
  data: {
    bulkFindOrCreateDevopsAdoptionSegments: {
      errors: [],
    },
    deleteDevopsAdoptionSegment: {
      errors: [],
    },
  },
});
const mutateWithDataErrors = jest.fn().mockResolvedValue({
  data: {
    bulkFindOrCreateDevopsAdoptionSegments: {
      errors: [dataErrorMessage],
    },
    deleteDevopsAdoptionSegment: {
      errors: [],
    },
  },
});
const mutateLoading = jest.fn().mockResolvedValue(new Promise(() => {}));
const mutateWithErrors = jest.fn().mockRejectedValue(genericErrorMessage);

describe('DevopsAdoptionSegmentModal', () => {
  let wrapper;

  const createComponent = ({ mutationMock = mutate, props = {}, provide = {} } = {}) => {
    const $apollo = {
      mutate: mutationMock,
    };

    wrapper = shallowMount(DevopsAdoptionSegmentModal, {
      propsData: {
        groups: groupNodes,
        ...props,
      },
      provide,
      stubs: {
        GlSprintf,
        ApolloMutation,
      },
      mocks: {
        $apollo,
      },
    });
  };

  const findModal = () => wrapper.find(GlModal);
  const findByTestId = (testId) => findModal().find(`[data-testid="${testId}"]`);
  const actionButtonDisabledState = () => findModal().props('actionPrimary').attributes[0].disabled;
  const cancelButtonDisabledState = () => findModal().props('actionCancel').attributes[0].disabled;
  const actionButtonLoadingState = () => findModal().props('actionPrimary').attributes[0].loading;
  const findAlert = () => findModal().find(GlAlert);

  afterEach(() => {
    wrapper.destroy();
  });

  it('contains the corrrect id', () => {
    createComponent();

    const modal = findModal();

    expect(modal.exists()).toBe(true);
    expect(modal.props('modalId')).toBe(DEVOPS_ADOPTION_SEGMENT_MODAL_ID);
  });

  describe('modal title', () => {
    it('contains the correct admin level title', () => {
      createComponent();

      const modal = findModal();

      expect(modal.props('title')).toBe('Add/remove groups');
    });

    it('contains the corrrect group level title', () => {
      createComponent({ provide: { isGroup: true } });

      const modal = findModal();

      expect(modal.props('title')).toBe('Add/remove sub-groups');
    });
  });

  it.each`
    enabledGroups | checkboxValues | disabled | condition       | state
    ${[]}         | ${[]}          | ${true}  | ${'no changes'} | ${'disables'}
    ${[]}         | ${[1]}         | ${false} | ${'changes'}    | ${'enables'}
  `(
    '$state the primary action if there are $condition',
    async ({ enabledGroups, disabled, checkboxValues }) => {
      createComponent({ props: { enabledGroups } });

      wrapper.setData({ checkboxValues });

      await nextTick();

      expect(actionButtonDisabledState()).toBe(disabled);
    },
  );

  describe('displays the correct content', () => {
    beforeEach(() => createComponent());

    const isCorrectShape = (option) => {
      const keys = Object.keys(option);
      return keys.includes('label') && keys.includes('value');
    };

    it('contains the checkbox tree component', () => {
      const checkboxes = findByTestId('groups');

      expect(checkboxes.exists()).toBe(true);

      const options = checkboxes.props('options');

      expect(options.length).toBe(2);
      expect(options.every(isCorrectShape)).toBe(true);
    });

    describe('filtering', () => {
      describe('filter input field', () => {
        it('contains the filter input', () => {
          const filter = findByTestId('filter');

          expect(filter.exists()).toBe(true);
          expect(filter.find(GlFormInput).exists()).toBe(true);
        });

        it('contains the filter icon', () => {
          const icon = findByTestId('filter').find(GlIcon);

          expect(icon.exists()).toBe(true);
          expect(icon.props('name')).toBe('search');
        });
      });

      it.each`
        filter  | results
        ${''}   | ${groupNodeLabelValues}
        ${'fo'} | ${[groupNodeLabelValues[0]]}
        ${'ar'} | ${[groupNodeLabelValues[1]]}
      `(
        'displays the correct results when filtering for value "$filter"',
        async ({ filter, results }) => {
          wrapper.setData({ filter });

          await nextTick();

          const checkboxes = findByTestId('groups');

          expect(checkboxes.props('options')).toStrictEqual(results);
        },
      );

      describe('when there are no filter results', () => {
        beforeEach(async () => {
          wrapper.setData({ filter: 'lalalala' });

          await nextTick();
        });

        it('displays a warning message when there are no results', async () => {
          const warning = findByTestId('filter-warning');

          expect(warning.exists()).toBe(true);
          expect(warning.text()).toBe('No filter results.');
          expect(warning.props('variant')).toBe('info');
        });

        it('hides the checkboxes', () => {
          const checkboxes = findByTestId('groups');

          expect(checkboxes.exists()).toBe(false);
        });
      });
    });

    it('does not display an error', () => {
      expect(findAlert().exists()).toBe(false);
    });
  });

  describe.each`
    state        | action      | expected
    ${'opening'} | ${'show'}   | ${true}
    ${'closing'} | ${'hidden'} | ${false}
  `('$state the modal', ({ action, expected }) => {
    beforeEach(() => {
      createComponent();
      findModal().vm.$emit(action);
    });

    it(`emits trackModalOpenState as ${expected}`, () => {
      expect(wrapper.emitted('trackModalOpenState')).toStrictEqual([[expected]]);
    });
  });

  describe('handles the form submission correctly when saving changes', () => {
    const enableFirstGroup = { checkboxValues: [groupIds[0]] };
    const enableSecondGroup = { checkboxValues: [groupIds[1]] };
    const noEnabledGroups = { checkboxValues: [] };
    const firstGroupEnabledData = [devopsAdoptionSegmentsData.nodes[0]];
    const firstGroupId = [groupIds[0]];
    const firstGroupGid = [groupGids[0]];
    const secondGroupGid = [groupGids[1]];

    describe('submitting the form', () => {
      describe('while waiting for the mutation', () => {
        beforeEach(() => {
          createComponent({ mutationMock: mutateLoading });

          wrapper.setData(enableFirstGroup);
        });

        it('disables the form inputs', async () => {
          const checkboxes = findByTestId('groups');

          expect(checkboxes.attributes('disabled')).not.toBeDefined();

          findModal().vm.$emit('primary', mockEvent);

          await nextTick();

          expect(checkboxes.attributes('disabled')).toBeDefined();
        });

        it('disables the cancel button', async () => {
          expect(cancelButtonDisabledState()).toBe(false);

          findModal().vm.$emit('primary', mockEvent);

          await nextTick();

          expect(cancelButtonDisabledState()).toBe(true);
        });

        it('sets the action button state to loading', async () => {
          expect(actionButtonLoadingState()).toBe(false);

          findModal().vm.$emit('primary', mockEvent);

          await nextTick();

          expect(actionButtonLoadingState()).toBe(true);
        });
      });

      describe.each`
        action                   | enabledGroups            | newGroups            | expectedAddGroupGids | expectedDeleteIds
        ${'adding'}              | ${[]}                    | ${enableFirstGroup}  | ${firstGroupGid}     | ${[]}
        ${'removing'}            | ${firstGroupEnabledData} | ${noEnabledGroups}   | ${[]}                | ${firstGroupId}
        ${'adding and removing'} | ${firstGroupEnabledData} | ${enableSecondGroup} | ${secondGroupGid}    | ${firstGroupId}
      `(
        '$action groups',
        ({ enabledGroups, newGroups, expectedAddGroupGids, expectedDeleteIds }) => {
          describe('successful submission', () => {
            beforeEach(async () => {
              createComponent({ props: { enabledGroups } });

              wrapper.setData(newGroups);

              wrapper.vm.$refs.modal.hide = jest.fn();

              findModal().vm.$emit('primary', mockEvent);

              await waitForPromises();
            });

            if (expectedAddGroupGids.length) {
              it('submits the correct add request variables', () => {
                expect(mutate).toHaveBeenCalledWith(
                  expect.objectContaining({
                    variables: { namespaceIds: expectedAddGroupGids },
                  }),
                );
              });
            }

            if (expectedDeleteIds.length) {
              it('submits the correct delete request variables', () => {
                expect(mutate).toHaveBeenCalledWith(
                  expect.objectContaining({
                    variables: { id: expectedDeleteIds },
                  }),
                );
              });
            }

            it('closes the modal after a successful mutation', () => {
              expect(wrapper.vm.$refs.modal.hide).toHaveBeenCalled();
            });

            it('resets the form fields', () => {
              findModal().vm.$emit('hidden');

              expect(wrapper.vm.checkboxValues).toEqual([]);
              expect(wrapper.vm.filter).toBe('');
            });
          });
        },
      );

      describe('error handling', () => {
        it.each`
          errorType     | errorLocation  | mutationSpy             | message
          ${'generic'}  | ${'top level'} | ${mutateWithErrors}     | ${genericErrorMessage}
          ${'specific'} | ${'data'}      | ${mutateWithDataErrors} | ${dataErrorMessage}
        `(
          'displays a $errorType error if the mutation has a $errorLocation error',
          async ({ mutationSpy, message }) => {
            createComponent({ mutationMock: mutationSpy });

            wrapper.setData(enableFirstGroup);

            findModal().vm.$emit('primary', mockEvent);

            await waitForPromises();

            const alert = findAlert();

            expect(alert.exists()).toBe(true);
            expect(alert.props('variant')).toBe('danger');
            expect(alert.text()).toBe(message);
          },
        );

        it('calls sentry on top level error', async () => {
          const captureException = jest.spyOn(Sentry, 'captureException');

          createComponent({ mutationMock: mutateWithErrors });

          wrapper.setData(enableFirstGroup);

          findModal().vm.$emit('primary', mockEvent);

          await waitForPromises();

          expect(captureException).toHaveBeenCalledWith(genericErrorMessage);
        });
      });
    });
  });
});
