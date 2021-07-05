import { GlSprintf } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import { cloneDeep } from 'lodash';
import EditEscalationPolicyModal from 'ee/escalation_policies/components/add_edit_escalation_policy_modal.vue';
import DeleteEscalationPolicyModal from 'ee/escalation_policies/components/delete_escalation_policy_modal.vue';
import EscalationPolicy from 'ee/escalation_policies/components/escalation_policy.vue';

import {
  deleteEscalationPolicyModalId,
  editEscalationPolicyModalId,
} from 'ee/escalation_policies/constants';
import { parsePolicy } from 'ee/escalation_policies/utils';
import mockPolicies from './mocks/mockPolicies.json';

describe('EscalationPolicy', () => {
  let wrapper;
  const escalationPolicy = parsePolicy(cloneDeep(mockPolicies[0]));

  const createComponent = () => {
    wrapper = shallowMount(EscalationPolicy, {
      propsData: {
        policy: escalationPolicy,
        index: 0,
      },
      stubs: {
        GlSprintf,
      },
    });
  };

  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  const findDeleteModal = () => wrapper.findComponent(DeleteEscalationPolicyModal);
  const findEditModal = () => wrapper.findComponent(EditEscalationPolicyModal);

  it('renders policy with rules', () => {
    expect(wrapper.element).toMatchSnapshot();
  });

  describe('Modals', () => {
    describe('delete policy modal', () => {
      it('should render a modal and provide it with correct id', () => {
        const modal = findDeleteModal();
        expect(modal.exists()).toBe(true);
        expect(modal.props('modalId')).toBe(
          `${deleteEscalationPolicyModalId}-${escalationPolicy.id}`,
        );
      });
    });

    describe('edit policy modal', () => {
      it('should render a modal and provide it with correct id and isEditMode props', () => {
        const modal = findEditModal();
        expect(modal.exists()).toBe(true);
        expect(modal.props('modalId')).toBe(
          `${editEscalationPolicyModalId}-${escalationPolicy.id}`,
        );
        expect(modal.props('isEditMode')).toBe(true);
      });
    });
  });
});
