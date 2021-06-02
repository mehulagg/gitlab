import { GlButton, GlModal, GlFormInput } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import { stubComponent } from 'helpers/stub_component';
import waitForPromises from 'helpers/wait_for_promises';
import DeleteBranchModal from '~/branches/components/delete_branch_modal.vue';

let wrapper;

const branchName = 'test_modal';
const defaultBranchName = 'default';
const deletePath = '/path/to/branch';
const merged = false;
const isProtectedBranch = false;

const createComponent = (data = {}) => {
  wrapper = shallowMount(DeleteBranchModal, {
    data() {
      return {
        branchName,
        deletePath,
        defaultBranchName,
        merged,
        isProtectedBranch,
        ...data,
      };
    },
    attrs: {
      visible: true,
    },
    stubs: {
      GlModal: stubComponent(GlModal, {
        template:
          '<div><slot name="modal-title"></slot><slot></slot><slot name="modal-footer"></slot></div>',
      }),
      GlButton,
      GlFormInput,
    },
  });
};

const findModal = () => wrapper.findComponent(GlModal);
const findDeleteButton = () => wrapper.find('[data-testid="delete_branch_confirmation_button"]');
const findCancelButton = () => wrapper.find('[data-testid="delete_branch_cancel_button"]');
const findFormInput = () => wrapper.findComponent(GlFormInput);

describe('Delete branch modal', () => {
  afterEach(() => {
    wrapper.destroy();
  });

  describe('Deleting a regular branch', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders the modal correctly', () => {
      expect(findModal().props('title')).toBe('Delete branch. Are you ABSOLUTELY SURE?');
      expect(wrapper.vm.message).toBe(
        "You're about to permanently delete the branch %{strongStart}test_modal.%{strongEnd}",
      );
      expect(wrapper.vm.buttonText).toBe('Yes, delete branch');
      expect(wrapper.vm.$data).toMatchObject({
        branchName,
        deletePath,
        defaultBranchName,
      });
    });

    it('submits the form when clicked', () => {
      const submitFormSpy = jest.spyOn(wrapper.vm.$refs.form, 'submit');

      findDeleteButton().trigger('click');

      expect(submitFormSpy).toHaveBeenCalled();
    });

    it('calls hide on the modal when cancel button is clicked', async () => {
      const closeModalSpy = jest.spyOn(wrapper.vm.$refs.modal, 'hide');

      findCancelButton().trigger('click');

      await waitForPromises;

      expect(closeModalSpy).toHaveBeenCalled();
    });
  });

  describe('Deleting a protected branch (for owner or maintainer)', () => {
    beforeEach(() => {
      createComponent({ isProtectedBranch: true, merged: true });
    });

    it('renders the modal correctly for a protected branch', () => {
      expect(findModal().props('title')).toBe('Delete protected branch. Are you ABSOLUTELY SURE?');
      expect(wrapper.vm.message).toBe(
        "You're about to permanently delete the protected branch %{strongStart}test_modal.%{strongEnd}",
      );
      expect(wrapper.vm.buttonText).toBe('Yes, delete protected branch');
      expect(wrapper.vm.$data).toMatchObject({
        branchName,
        deletePath,
        defaultBranchName,
        isProtectedBranch: true,
        merged: true,
      });
    });

    it('disables the delete button when branch name input is unconfirmed', () => {
      expect(findDeleteButton().attributes('disabled')).toBe('true');
    });

    it('enables the delete button when branch name input is confirmed', async () => {
      findFormInput().vm.$emit('input', branchName);

      await waitForPromises();

      expect(findDeleteButton()).not.toBeDisabled();
    });
  });
});
