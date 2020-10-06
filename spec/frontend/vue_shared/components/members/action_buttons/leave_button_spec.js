import { shallowMount } from '@vue/test-utils';
import { GlButton } from '@gitlab/ui';
import { createMockDirective, getBinding } from 'helpers/vue_mock_directive';
import LeaveButton from '~/vue_shared/components/members/action_buttons/leave_button.vue';
import LeaveModal from '~/vue_shared/components/members/modals/leave_modal.vue';
import { LEAVE_MODAL_ID } from '~/vue_shared/components/members/constants';
import { member } from '../mock_data';

describe('LeaveButton', () => {
  let wrapper;

  const createComponent = (propsData = {}) => {
    wrapper = shallowMount(LeaveButton, {
      propsData: {
        member,
        ...propsData,
      },
      directives: {
        GlTooltip: createMockDirective(),
        GlModalDirective: createMockDirective(),
      },
    });
  };

  const findButton = () => wrapper.find(GlButton);

  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('displays `title` prop as a tooltip', () => {
    expect(getBinding(findButton().element, 'gl-tooltip')).not.toBeUndefined();
    expect(findButton().attributes('title')).toBe('Leave');
  });

  it('sets `aria-label` attribute', () => {
    expect(findButton().attributes('aria-label')).toBe('Leave');
  });

  it('renders leave modal', () => {
    const leaveModal = wrapper.find(LeaveModal);

    expect(leaveModal.exists()).toBe(true);
    expect(leaveModal.props('member')).toEqual(member);
  });

  it('triggers leave modal', () => {
    const binding = getBinding(findButton().element, 'gl-modal-directive');

    expect(binding).not.toBeUndefined();
    expect(binding.value).toBe(LEAVE_MODAL_ID);
  });
});
