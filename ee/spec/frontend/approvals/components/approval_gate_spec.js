import { GlPopover, GlIcon } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import ApprovalGate from 'ee/approvals/components/approval_gate.vue';

jest.mock('lodash/uniqueId', () => (id) => `${id}mock`);

describe('ApprovalGate', () => {
  let wrapper;

  const findPopover = () => wrapper.findComponent(GlPopover);
  const findIcon = () => wrapper.findComponent(GlIcon);

  const createComponent = () => {
    return shallowMount(ApprovalGate, {
      propsData: {
        url: 'https://gitlab.com/',
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  beforeEach(() => {
    wrapper = createComponent();
  });

  it('renders the icon', () => {
    expect(findIcon().props('name')).toBe('cloud-gear');
    expect(findIcon().attributes('id')).toBe('approval-icon-mock');
  });

  it('renders the popover with the URL for the icon', () => {
    expect(findPopover().exists()).toBe(true);
    expect(findPopover().attributes('content')).toBe('https://gitlab.com/');
    expect(findPopover().attributes('title')).toBe('Approval Gate');
    expect(findPopover().attributes('target')).toBe('approval-icon-mock');
  });
});
