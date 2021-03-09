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
} from '../mock_data';

const mockEvent = { preventDefault: jest.fn() };
const mutate = jest.fn().mockResolvedValue({
  data: {
    createDevopsAdoptionSegment: {
      errors: [],
    },
  },
});
const mutateWithDataErrors = () =>
  jest.fn().mockResolvedValue({
    data: {
      createDevopsAdoptionSegment: {
        errors: [dataErrorMessage],
      },
    },
  });
const mutateLoading = jest.fn().mockResolvedValue(new Promise(() => {}));
const mutateWithErrors = jest.fn().mockRejectedValue(genericErrorMessage);

describe('DevopsAdoptionSegmentModal', () => {
  let wrapper;

  const createComponent = ({ mutationMock = mutate } = {}) => {
    const $apollo = {
      mutate: mutationMock,
    };

    wrapper = shallowMount(DevopsAdoptionSegmentModal, {
      propsData: {
        groups: groupNodes,
      },
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
    wrapper = null;
  });

  it('contains the corrrect id', () => {
    createComponent();

    const modal = findModal();

    expect(modal.exists()).toBe(true);
    expect(modal.props('modalId')).toBe(DEVOPS_ADOPTION_SEGMENT_MODAL_ID);
  });

  describe('displays the correct content', () => {
    beforeEach(() => createComponent());

    const isCorrectShape = (option) => {
      const keys = Object.keys(option);
      return keys.includes('text') && keys.includes('value');
    };

    it('contains the radio group component', () => {
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
    state        | action    | expected
    ${'opening'} | ${'show'} | ${true}
    ${'closing'} | ${'hide'} | ${false}
  `('$state the modal', ({ action, expected }) => {
    beforeEach(() => {
      createComponent();
      findModal().vm.$emit(action);
    });

    it(`emits trackModalOpenState as ${expected}`, () => {
      expect(wrapper.emitted('trackModalOpenState')).toStrictEqual([[expected]]);
    });
  });

  it.each`
    selectedGroupId | disabled | values        | state
    ${null}         | ${true}  | ${'checkbox'} | ${'disables'}
    ${1}            | ${false} | ${'nothing'}  | ${'enables'}
  `('$state the primary action if $values is missing', async ({ selectedGroupId, disabled }) => {
    createComponent();

    wrapper.setData({ selectedGroupId });

    await nextTick();

    expect(actionButtonDisabledState()).toBe(disabled);
  });

  describe('handles the form submission correctly when creating a new segment', () => {
    const additionalData = { selectedGroupId: groupIds[0] };

    describe('submitting the form', () => {
      describe('while waiting for the mutation', () => {
        beforeEach(() => {
          createComponent({ mutationMock: mutateLoading });

          wrapper.setData(additionalData);
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

      describe('successful submission', () => {
        beforeEach(() => {
          createComponent();

          wrapper.setData(additionalData);

          wrapper.vm.$refs.modal.hide = jest.fn();

          findModal().vm.$emit('primary', mockEvent);
        });

        it('submits the correct request variables', async () => {
          expect(mutate).toHaveBeenCalledWith(
            expect.objectContaining({
              variables: { namespaceId: groupGids[0] },
            }),
          );
        });

        it('closes the modal after a successful mutation', async () => {
          expect(wrapper.vm.$refs.modal.hide).toHaveBeenCalled();
        });

        it('resets the form fields', async () => {
          expect(wrapper.vm.selectedGroupId).toEqual(null);
          expect(wrapper.vm.filter).toBe('');
        });
      });

      describe('error handling', () => {
        it.each`
          errorType     | errorLocation  | mutationSpy               | message
          ${'generic'}  | ${'top level'} | ${mutateWithErrors}       | ${genericErrorMessage}
          ${'specific'} | ${'data'}      | ${mutateWithDataErrors()} | ${dataErrorMessage}
        `(
          'displays a $errorType error if the mutation has a $errorLocation error',
          async ({ mutationSpy, message }) => {
            createComponent({ mutationMock: mutationSpy });

            wrapper.setData(additionalData);

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

          wrapper.setData(additionalData);

          findModal().vm.$emit('primary', mockEvent);

          await waitForPromises();

          expect(captureException).toHaveBeenCalledWith(genericErrorMessage);
        });
      });
    });
  });
});
