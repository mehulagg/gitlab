import { GlModal } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import AddEscalationPolicyForm from 'ee/escalation_policies/components/add_edit_escalation_policy_form.vue';
import AddEscalationPolicyModal, {
  i18n,
} from 'ee/escalation_policies/components/add_edit_escalation_policy_modal.vue';
import { addEscalationPolicyModalId } from 'ee/escalation_policies/components/escalation_policies_wrapper.vue';

describe('AddEscalationPolicyModal', () => {
  let wrapper;
  const projectPath = 'group/project';

  const createComponent = ({ escalationPolicy, isEditMode, modalId, data } = {}) => {
    wrapper = shallowMount(AddEscalationPolicyModal, {
      data() {
        return {
          ...data,
        };
      },
      propsData: {
        modalId,
        escalationPolicy,
        isEditMode,
      },
      provide: {
        projectPath,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  const findModal = () => wrapper.findComponent(GlModal);
  const findEscalationPolicyForm = () => wrapper.findComponent(AddEscalationPolicyForm);

  describe('Schedule create', () => {
    beforeEach(() => {
      createComponent({ modalId: addEscalationPolicyModalId });
    });

    describe('renders create modal with the correct information', () => {
      it('renders name of correct modal id', () => {
        expect(findModal().attributes('modalid')).toBe(addEscalationPolicyModalId);
      });

      it('renders modal title', () => {
        expect(findModal().attributes('title')).toBe(i18n.addEscalationPolicy);
      });

      it('renders the form inside the modal', () => {
        expect(findEscalationPolicyForm().exists()).toBe(true);
      });
    });
  });
});
