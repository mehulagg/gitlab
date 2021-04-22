import { GlPopover, GlIcon } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import StatusCheckIcon from 'ee/approvals/components/status_check_icon.vue';

jest.mock('lodash/uniqueId', () => (id) => `${id}mock`);

describe('StatusCheckIcon', () => {
  let wrapper;

  const findPopover = () => wrapper.findComponent(GlPopover);
  const findIcon = () => wrapper.findComponent(GlIcon);

  const createComponent = () => {
    return shallowMount(StatusCheckIcon, {
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
    expect(findIcon().attributes('id')).toBe('status-check-icon-mock');
  });

  it('renders the popover with the URL for the icon', () => {
    expect(findPopover().exists()).toBe(true);
    expect(findPopover().attributes()).toMatchObject({
      content: 'https://gitlab.com/',
      title: 'Status check',
      target: 'status-check-icon-mock',
    });
  });
});
