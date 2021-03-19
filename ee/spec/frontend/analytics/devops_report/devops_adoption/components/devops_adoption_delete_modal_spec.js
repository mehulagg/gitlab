import { GlModal, GlSprintf, GlAlert } from '@gitlab/ui';
import * as Sentry from '@sentry/browser';
import { shallowMount } from '@vue/test-utils';
import { ApolloMutation } from 'vue-apollo';
import DevopsAdoptionDeleteModal from 'ee/analytics/devops_report/devops_adoption/components/devops_adoption_delete_modal.vue';
import { DEVOPS_ADOPTION_SEGMENT_DELETE_MODAL_ID } from 'ee/analytics/devops_report/devops_adoption/constants';
import waitForPromises from 'helpers/wait_for_promises';
import {
  genericDeleteErrorMessage,
  dataErrorMessage,
  devopsAdoptionSegmentsData,
} from '../mock_data';

const mockEvent = { preventDefault: jest.fn() };
const mutate = jest.fn().mockResolvedValue({
  data: {
    deleteDevopsAdoptionSegment: {
      errors: [],
    },
  },
});
const mutateWithDataErrors = jest.fn().mockResolvedValue({
  data: {
    deleteDevopsAdoptionSegment: {
      errors: [dataErrorMessage],
    },
  },
});
const mutateLoading = jest.fn().mockResolvedValue(new Promise(() => {}));
const mutateWithErrors = jest.fn().mockRejectedValue(genericDeleteErrorMessage);

describe('DevopsAdoptionDeleteModal', () => {
  let wrapper;

  const createComponent = ({ mutationMock = mutate } = {}) => {
    const $apollo = {
      mutate: mutationMock,
    };

    wrapper = shallowMount(DevopsAdoptionDeleteModal, {
      propsData: {
        segment: devopsAdoptionSegmentsData.nodes[0],
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
  const cancelButtonDisabledState = () => findModal().props('actionCancel').attributes[0].disabled;
  const actionButtonLoadingState = () => findModal().props('actionPrimary').attributes[0].loading;
  const findAlert = () => findModal().find(GlAlert);

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('default display', () => {
    beforeEach(() => createComponent());

    it('contains the corrrect id', () => {
      const modal = findModal();

      expect(modal.exists()).toBe(true);
      expect(modal.props('modalId')).toBe(DEVOPS_ADOPTION_SEGMENT_DELETE_MODAL_ID);
    });

    it('displays the confirmation message', () => {
      const text = `Are you sure that you would like to remove ${devopsAdoptionSegmentsData.nodes[0].namespace.fullName} from the table?`;

      expect(findModal().text()).toBe(text);
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

  describe('submitting the form', () => {
    describe('while waiting for the mutation', () => {
      beforeEach(() => createComponent({ mutationMock: mutateLoading }));

      it('disables the cancel button', async () => {
        expect(cancelButtonDisabledState()).toBe(false);

        findModal().vm.$emit('primary', mockEvent);

        await wrapper.vm.$nextTick();

        expect(cancelButtonDisabledState()).toBe(true);
      });

      it('sets the action button state to loading', async () => {
        expect(actionButtonLoadingState()).toBe(false);

        findModal().vm.$emit('primary', mockEvent);

        await wrapper.vm.$nextTick();

        expect(actionButtonLoadingState()).toBe(true);
      });
    });

    describe('successful submission', () => {
      beforeEach(() => {
        createComponent();

        wrapper.vm.$refs.modal.hide = jest.fn();

        findModal().vm.$emit('primary', mockEvent);
      });

      it('submits the correct request variables', () => {
        expect(mutate).toHaveBeenCalledWith(
          expect.objectContaining({
            variables: {
              id: [devopsAdoptionSegmentsData.nodes[0].id],
            },
          }),
        );
      });

      it('closes the modal after a successful mutation', () => {
        expect(wrapper.vm.$refs.modal.hide).toHaveBeenCalled();
      });
    });

    describe('error handling', () => {
      it.each`
        errorType     | errorLocation  | mutationSpy             | message
        ${'generic'}  | ${'top level'} | ${mutateWithErrors}     | ${genericDeleteErrorMessage}
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

        expect(Sentry.captureException.mock.calls[0][0]).toBe(genericDeleteErrorMessage);
      });
    });
  });
});
