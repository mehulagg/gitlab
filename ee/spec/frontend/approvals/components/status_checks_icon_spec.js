import { GlPopover, GlIcon } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import StatusChecksIcon from 'ee/approvals/components/status_checks_icon.vue';

jest.mock('lodash/uniqueId', () => (id) => `${id}mock`);

describe('StatusChecksIcon', () => {
  let wrapper;

  const findPopover = () => wrapper.findComponent(GlPopover);
  const findIcon = () => wrapper.findComponent(GlIcon);

  const createComponent = () => {
    return shallowMount(StatusChecksIcon, {
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
    expect(findIcon().attributes('id')).toBe('status-checks-icon-mock');
  });

  it('renders the popover with the URL for the icon', () => {
    expect(findPopover().exists()).toBe(true);
    expect(findPopover().attributes()).toMatchObject({
      content: 'https://gitlab.com/',
      title: 'Status to check',
      target: 'status-checks-icon-mock',
    });
  });
});
