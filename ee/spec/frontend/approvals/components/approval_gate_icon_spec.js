import { GlPopover, GlIcon } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import ApprovalGateIcon from 'ee/approvals/components/approval_gate_icon.vue';

jest.mock('lodash/uniqueId', () => (id) => `${id}mock`);

describe('ApprovalGateIcon', () => {
  let wrapper;

  const findPopover = () => wrapper.findComponent(GlPopover);
  const findIcon = () => wrapper.findComponent(GlIcon);

  const createComponent = () => {
    return shallowMount(ApprovalGateIcon, {
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
    expect(findIcon().props('name')).toBe('api');
    expect(findIcon().attributes('id')).toBe('approval-icon-mock');
  });

  it('renders the popover with the URL for the icon', () => {
    expect(findPopover().exists()).toBe(true);
    expect(findPopover().attributes()).toMatchObject({
      content: 'https://gitlab.com/',
      title: 'Approval Gate',
      target: 'approval-icon-mock',
    });
  });
});
