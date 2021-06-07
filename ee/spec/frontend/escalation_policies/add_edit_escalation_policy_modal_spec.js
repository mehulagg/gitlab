import { GlModal, GlAlert } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import AddEscalationPolicyForm from 'ee/escalation_policies/components/add_edit_escalation_policy_form.vue';
import AddEscalationPolicyModal, {
  i18n,
} from 'ee/escalation_policies/components/add_edit_escalation_policy_modal.vue';
import waitForPromises from 'helpers/wait_for_promises';
import mockPolicy from './mocks/mockPolicy.json';

describe('AddEscalationPolicyModal', () => {
  let wrapper;
  const projectPath = 'group/project';
  const mockHideModal = jest.fn();
  const mutate = jest.fn();

  const createComponent = ({ escalationPolicy, data } = {}) => {
    wrapper = shallowMount(AddEscalationPolicyModal, {
      data() {
        return {
          form: mockPolicy,
          ...data,
        };
      },
      propsData: {
        escalationPolicy,
      },
      provide: {
        projectPath,
      },
      mocks: {
        $apollo: {
          mutate,
        },
      },
    });

    wrapper.vm.$refs.addUpdateEscalationPolicyModal.hide = mockHideModal;
  };
  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  const findModal = () => wrapper.findComponent(GlModal);
  const findEscalationPolicyForm = () => wrapper.findComponent(AddEscalationPolicyForm);
  const findAlert = () => wrapper.findComponent(GlAlert);

  describe('renders create modal with the correct information', () => {
    it('renders modal title', () => {
      expect(findModal().attributes('title')).toBe(i18n.addEscalationPolicy);
    });

    it('renders the form inside the modal', () => {
      expect(findEscalationPolicyForm().exists()).toBe(true);
    });

    it('makes a request with form data to create an escalation policy', () => {
      mutate.mockResolvedValueOnce({});
      findModal().vm.$emit('primary', { preventDefault: jest.fn() });
      expect(mutate).toHaveBeenCalledWith(
        expect.objectContaining({
          variables: {
            input: {
              projectPath,
              ...mockPolicy,
            },
          },
        }),
      );
    });

    it('hides the modal on successful policy creation', async () => {
      mutate.mockResolvedValueOnce({ data: { escalationPolicyCreate: { errors: [] } } });
      findModal().vm.$emit('primary', { preventDefault: jest.fn() });
      await waitForPromises();
      expect(mockHideModal).toHaveBeenCalled();
    });

    it("doesn't hide a modal and shows error alert on creation failure", async () => {
      const error = 'some error';
      mutate.mockResolvedValueOnce({ data: { escalationPolicyCreate: { errors: [error] } } });
      findModal().vm.$emit('primary', { preventDefault: jest.fn() });
      await waitForPromises();
      const alert = findAlert();
      expect(mockHideModal).not.toHaveBeenCalled();
      expect(alert.exists()).toBe(true);
      expect(alert.text()).toContain(error);
    });

    it('clears the form on modal cancel', () => {
      expect(wrapper.vm.form).toEqual(mockPolicy);
      findModal().vm.$emit('canceled', { preventDefault: jest.fn() });
      expect(wrapper.vm.form).toEqual({
        name: '',
        description: '',
        rules: [],
      });

      expect(wrapper.vm.validationState).toEqual({
        name: null,
        rules: [],
      });
    });

    it('clears the validation state on modal cancel', () => {
      expect(wrapper.vm.validationState.name).toBe(null);
      findEscalationPolicyForm().vm.$emit('update-escalation-policy-form', {
        field: 'name',
        value: '',
      });
      expect(wrapper.vm.validationState.name).toBe(false);
      findModal().vm.$emit('canceled', { preventDefault: jest.fn() });
      expect(wrapper.vm.validationState.name).toBe(null);
    });
  });

  describe('modal buttons', () => {
    it('should disable primary button when form is invalid', async () => {
      findEscalationPolicyForm().vm.$emit('update-escalation-policy-form', {
        field: 'name',
        value: '',
      });
      await wrapper.vm.$nextTick();
      expect(findModal().props('actionPrimary').attributes).toContainEqual({ disabled: true });
    });

    it('should enable primary button when form is valid', async () => {
      findEscalationPolicyForm().vm.$emit('update-escalation-policy-form', {
        field: 'name',
        value: 'Some policy name',
      });
      await wrapper.vm.$nextTick();
      expect(findModal().props('actionPrimary').attributes).toContainEqual({ disabled: false });
    });
  });
});
