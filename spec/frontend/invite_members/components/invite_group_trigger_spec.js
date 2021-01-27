import { shallowMount } from '@vue/test-utils';
import { GlButton } from '@gitlab/ui';
import InviteGroupTrigger from '~/invite_members/components/invite_group_trigger.vue';

const displayText = 'Invite a group';

const createComponent = (props = {}) => {
  return shallowMount(InviteGroupTrigger, {
    propsData: {
      displayText,
      ...props,
    },
  });
};

describe('InviteGroupTrigger', () => {
  let wrapper;

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('displayText', () => {
    const findButton = () => wrapper.find(GlButton);

    beforeEach(() => {
      wrapper = createComponent();
    });

    it('includes the correct displayText for the link', () => {
      expect(findButton().text()).toBe(displayText);
    });
  });
});
