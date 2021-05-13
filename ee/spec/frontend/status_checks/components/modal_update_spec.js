import { GlButton, GlModal } from '@gitlab/ui';
import Vue from 'vue';
import Vuex from 'vuex';
import Form from 'ee/status_checks/components/form.vue';
import ModalUpdate, { i18n } from 'ee/status_checks/components/modal_update.vue';
import { stubComponent } from 'helpers/stub_component';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import waitForPromises from 'helpers/wait_for_promises';
import { TEST_PROTECTED_BRANCHES } from '../mock_data';

Vue.use(Vuex);

const projectId = '1';
const statusChecksPath = '/api/v4/projects/1/external_approval_rules';
const statusCheck = {
  externalUrl: 'https://foo.com',
  id: 1,
  name: 'Foo',
  protectedBranches: TEST_PROTECTED_BRANCHES,
};
const formData = {
  branches: statusCheck.protectedBranches.map(({ id }) => id),
  name: statusCheck.name,
  url: statusCheck.externalUrl,
};
const modalId = 'status-checks-update-modal';

describe('Modal update', () => {
  let wrapper;
  let store;
  const glModalDirective = jest.fn();
  const actions = {
    putStatusCheck: jest.fn(),
  };

  const createWrapper = () => {
    store = new Vuex.Store({
      actions,
      state: {
        isLoading: false,
        settings: { projectId, statusChecksPath },
        statusChecks: [],
      },
    });

    wrapper = shallowMountExtended(ModalUpdate, {
      directives: {
        glModal: {
          bind(el, { modifiers }) {
            glModalDirective(modifiers);
          },
        },
      },
      propsData: {
        statusCheck,
      },
      store,
      stubs: {
        GlButton: stubComponent(GlButton, {
          props: ['v-gl-modal', 'loading'],
        }),
      },
    });

    wrapper.vm.$refs.modal.hide = jest.fn();
    wrapper.vm.$refs.form.isValid = jest.fn();
    wrapper.vm.$refs.form.formData = formData;
  };

  beforeEach(() => {
    createWrapper();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  const findModal = () => wrapper.findComponent(GlModal);
  const findForm = () => wrapper.findComponent(Form);

  describe('Modal', () => {
    it('sets the modals props', () => {
      expect(findModal().props()).toMatchObject({
        actionPrimary: { text: i18n.title, attributes: [{ variant: 'confirm', loading: false }] },
        actionCancel: { text: i18n.cancelButton },
        modalId,
        size: 'sm',
        title: i18n.title,
      });
    });

    it('shows the form', () => {
      expect(findForm().props()).toStrictEqual({
        projectId,
        serverValidationErrors: [],
        showValidation: false,
        statusCheck,
      });
    });
  });

  describe('Submission', () => {
    it('sets showValidation to true when values are invalid', async () => {
      wrapper.vm.$refs.form.isValid.mockReturnValueOnce(false);

      await findModal().vm.$emit('ok', { preventDefault: () => null });

      expect(findForm().props()).toStrictEqual({
        projectId,
        serverValidationErrors: [],
        showValidation: true,
        statusCheck,
      });
    });

    it('submits valid values and hides the modal', async () => {
      wrapper.vm.$refs.form.isValid.mockReturnValueOnce(true);

      await findModal().vm.$emit('ok', { preventDefault: () => null });
      await waitForPromises();

      expect(actions.putStatusCheck).toHaveBeenCalledWith(expect.any(Object), {
        externalUrl: formData.url,
        id: statusCheck.id,
        name: formData.name,
        protectedBranchIds: formData.branches,
      });

      expect(wrapper.vm.$refs.modal.hide).toHaveBeenCalled();
    });

    it('submits invalid values and does not hide the modal', async () => {
      wrapper.vm.$refs.form.isValid.mockReturnValueOnce(true);

      const message = ['Name has already been taken'];

      actions.putStatusCheck.mockRejectedValueOnce({
        response: { data: { message } },
      });

      await findModal().vm.$emit('ok', { preventDefault: () => null });
      await waitForPromises();

      expect(actions.putStatusCheck).toHaveBeenCalledWith(expect.any(Object), {
        externalUrl: formData.url,
        id: statusCheck.id,
        name: formData.name,
        protectedBranchIds: formData.branches,
      });

      expect(wrapper.vm.$refs.modal.hide).not.toHaveBeenCalled();

      expect(findForm().props()).toStrictEqual({
        projectId,
        serverValidationErrors: message,
        showValidation: true,
        statusCheck,
      });
    });
  });
});
