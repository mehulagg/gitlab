import { ApolloMutation } from 'vue-apollo';
import { shallowMount } from '@vue/test-utils';
import { GlModal, GlFormInput, GlSprintf, GlAlert, GlIcon } from '@gitlab/ui';
import { getByText } from '@testing-library/dom';
import { nextTick } from 'vue';
import waitForPromises from 'helpers/wait_for_promises';
import DevopsAdoptionSegmentModal from 'ee/admin/dev_ops_report/components/devops_adoption_segment_modal.vue';
import { DEVOPS_ADOPTION_SEGMENT_MODAL_ID } from 'ee/admin/dev_ops_report/constants';
import * as Sentry from '~/sentry/wrapper';
import {
  groupNodes,
  groupIds,
  groupGids,
  segmentName,
  genericErrorMessage,
  dataErrorMessage,
  devopsAdoptionSegmentsData,
  groupNodeLabelValues,
} from '../mock_data';

const mockEvent = { preventDefault: jest.fn() };
const mutate = jest.fn().mockResolvedValue({
  data: {
    createDevopsAdoptionSegment: {
      errors: [],
    },
    updateDevopsAdoptionSegment: {
      errors: [],
    },
  },
});
const mutateWithDataErrors = (segment) =>
  jest.fn().mockResolvedValue({
    data: {
      [segment ? 'updateDevopsAdoptionSegment' : 'createDevopsAdoptionSegment']: {
        errors: [dataErrorMessage],
      },
    },
  });
const mutateLoading = jest.fn().mockResolvedValue(new Promise(() => {}));
const mutateWithErrors = jest.fn().mockRejectedValue(genericErrorMessage);

describe('DevopsAdoptionSegmentModal', () => {
  let wrapper;

  const createComponent = ({ mutationMock = mutate, segment = null } = {}) => {
    const $apollo = {
      mutate: mutationMock,
    };

    wrapper = shallowMount(DevopsAdoptionSegmentModal, {
      propsData: {
        segment,
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

  const assertHelperText = (text) => expect(getByText(wrapper.element, text)).not.toBeNull();

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
      return keys.includes('label') && keys.includes('value');
    };

    it('displays the name field', () => {
      const name = findByTestId('name');

      expect(name.exists()).toBe(true);
      expect(name.find(GlFormInput).exists()).toBe(true);
    });

    it('contains the checkbox tree component', () => {
      const checkboxes = findByTestId('groups');

      expect(checkboxes.exists()).toBe(true);

      const options = checkboxes.props('options');

      expect(options.length).toBe(2);
      expect(options.every(isCorrectShape)).toBe(true);
    });

    describe('selected groups helper text', () => {
      it('displays the plural text when 0 groups are selected', () => {
        assertHelperText('0 groups selected (20 max)');
      });

      it('dispalys the singular text when only 1 group is selected', async () => {
        wrapper.setData({ checkboxValues: [groupNodes[0]] });

        await nextTick();

        assertHelperText('1 group selected (20 max)');
      });

      it('displays the plural text when multiple groups are selected', async () => {
        wrapper.setData({ checkboxValues: groupNodes });

        await nextTick();

        assertHelperText('2 groups selected (20 max)');
      });
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

  it.each`
    checkboxValues | name           | disabled | values                 | state
    ${[]}          | ${''}          | ${true}  | ${'checkbox and name'} | ${'disables'}
    ${[1]}         | ${''}          | ${true}  | ${'checkbox'}          | ${'disables'}
    ${[]}          | ${segmentName} | ${true}  | ${'name'}              | ${'disables'}
    ${[1]}         | ${segmentName} | ${false} | ${'nothing'}           | ${'enables'}
  `(
    '$state the primary action if $values is missing',
    async ({ checkboxValues, name, disabled }) => {
      createComponent();

      wrapper.setData({ checkboxValues, name });

      await nextTick();

      expect(actionButtonDisabledState()).toBe(disabled);
    },
  );

  describe.each`
    action                            | segment                                | additionalData
    ${'creating a new segment'}       | ${null}                                | ${{ checkboxValues: groupIds, name: segmentName }}
    ${'updating an existing segment'} | ${devopsAdoptionSegmentsData.nodes[0]} | ${{}}
  `('handles the form submission correctly when $action', ({ segment, additionalData }) => {
    describe('submitting the form', () => {
      describe('while waiting for the mutation', () => {
        beforeEach(() => {
          createComponent({ mutationMock: mutateLoading, segment });

          wrapper.setData(additionalData);
        });

        it('disables the form inputs', async () => {
          const checkboxes = findByTestId('groups');
          const name = findByTestId('name');

          expect(checkboxes.attributes('disabled')).not.toBeDefined();
          expect(name.attributes('disabled')).not.toBeDefined();

          findModal().vm.$emit('primary', mockEvent);

          await nextTick();

          expect(checkboxes.attributes('disabled')).toBeDefined();
          expect(name.attributes('disabled')).toBeDefined();
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
          createComponent({ segment });

          wrapper.setData(additionalData);

          wrapper.vm.$refs.modal.hide = jest.fn();

          findModal().vm.$emit('primary', mockEvent);
        });

        it('submits the correct request variables', async () => {
          const variables = segment
            ? {
                id: segment.id,
                groupIds: [groupGids[0]],
                name: segment.name,
              }
            : {
                groupIds: groupGids,
                name: segmentName,
              };

          expect(mutate).toHaveBeenCalledWith(
            expect.objectContaining({
              variables,
            }),
          );
        });

        it('closes the modal after a successful mutation', async () => {
          expect(wrapper.vm.$refs.modal.hide).toHaveBeenCalled();
        });

        it('resets the form fields', async () => {
          const name = segment ? 'Segment 1' : '';
          const checkboxValues = segment ? [1] : [];

          expect(wrapper.vm.name).toBe(name);
          expect(wrapper.vm.checkboxValues).toEqual(checkboxValues);
          expect(wrapper.vm.filter).toBe('');
        });
      });

      describe('error handling', () => {
        it.each`
          errorType     | errorLocation  | mutationSpy                      | message
          ${'generic'}  | ${'top level'} | ${mutateWithErrors}              | ${genericErrorMessage}
          ${'specific'} | ${'data'}      | ${mutateWithDataErrors(segment)} | ${dataErrorMessage}
        `(
          'displays a $errorType error if the mutation has a $errorLocation error',
          async ({ mutationSpy, message }) => {
            createComponent({ mutationMock: mutationSpy, segment });

            findModal().vm.$emit('primary', mockEvent);

            await waitForPromises();

            const alert = findAlert();

            expect(alert.exists()).toBe(true);
            expect(alert.props('variant')).toBe('danger');
            expect(alert.text()).toBe(message);
          },
        );

        it('calls sentry on top level error', async () => {
          jest.spyOn(Sentry, 'captureException');

          createComponent({ mutationMock: mutateWithErrors, segment });

          findModal().vm.$emit('primary', mockEvent);

          await waitForPromises();

          expect(Sentry.captureException.mock.calls[0][0]).toBe(genericErrorMessage);
        });
      });
    });
  });
});
