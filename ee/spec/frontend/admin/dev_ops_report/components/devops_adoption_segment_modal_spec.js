import { ApolloMutation } from 'vue-apollo';
import { shallowMount } from '@vue/test-utils';
import { GlModal, GlFormInput, GlSprintf, GlAlert } from '@gitlab/ui';
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
} from '../mock_data';

const mockEvent = { preventDefault: jest.fn() };
const mutate = jest.fn().mockResolvedValue({
  data: {
    createDevopsAdoptionSegment: {
      errors: [],
    },
  },
});
const mutateWithDataErrors = jest.fn().mockResolvedValue({
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
  const findByTestId = testId => findModal().find(`[data-testid="${testId}"]`);
  const actionButtonDisabledState = () => findModal().props('actionPrimary').attributes[0].disabled;
  const cancelButtonDisabledState = () => findModal().props('actionCancel').attributes[0].disabled;
  const actionButtonLoadingState = () => findModal().props('actionPrimary').attributes[0].loading;
  const findAlert = () => findModal().find(GlAlert);

  const assertHelperText = text => expect(getByText(wrapper.element, text)).not.toBeNull();

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

    const isCorrectShape = option => {
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

  describe('submitting the form', () => {
    describe('while waiting for the mutation', () => {
      beforeEach(() => {
        createComponent({ mutationMock: mutateLoading });

        wrapper.setData({ checkboxValues: [1], name: segmentName });
      });

      it('disables the form inputs', async () => {
        const checkboxes = findByTestId('groups');
        const name = findByTestId('name');

        expect(checkboxes.attributes('disabled')).not.toBeDefined();
        expect(name.attributes('disabled')).not.toBeDefined();

        findModal().vm.$emit('primary', mockEvent);

        await waitForPromises();

        expect(checkboxes.attributes('disabled')).toBeDefined();
        expect(name.attributes('disabled')).toBeDefined();
      });

      it('disables the cancel button', async () => {
        expect(cancelButtonDisabledState()).toBe(false);

        findModal().vm.$emit('primary', mockEvent);

        await waitForPromises();

        expect(cancelButtonDisabledState()).toBe(true);
      });

      it('sets the action button state to loading', async () => {
        expect(actionButtonLoadingState()).toBe(false);

        findModal().vm.$emit('primary', mockEvent);

        await waitForPromises();

        expect(actionButtonLoadingState()).toBe(true);
      });
    });

    describe('successful submission', () => {
      beforeEach(async () => {
        createComponent();

        wrapper.setData({ checkboxValues: groupIds, name: segmentName });
        wrapper.vm.$refs.modal.hide = jest.fn();

        findModal().vm.$emit('primary', mockEvent);

        await waitForPromises();
      });

      it('submits the correct request variables', async () => {
        expect(mutate).toHaveBeenCalledWith(
          expect.objectContaining({
            variables: {
              groupIds: groupGids,
              name: segmentName,
            },
          }),
        );
      });

      it('closes the modal after a successful mutation', async () => {
        expect(wrapper.vm.$refs.modal.hide).toHaveBeenCalled();
      });
    });

    describe('error handling', () => {
      it.each`
        errorType     | errorLocation  | mutationSpy             | message
        ${'generic'}  | ${'top level'} | ${mutateWithErrors}     | ${genericErrorMessage}
        ${'specific'} | ${'data'}      | ${mutateWithDataErrors} | ${dataErrorMessage}
      `(
        'displays a $errorType error if the mutation has a $errorLocation error',
        async ({ mutationSpy, message }) => {
          createComponent({ mutationMock: mutationSpy });

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

        createComponent({ mutationMock: mutateWithErrors });

        findModal().vm.$emit('primary', mockEvent);

        await waitForPromises();

        expect(Sentry.captureException.mock.calls[0][0]).toBe(genericErrorMessage);
      });
    });
  });
});
