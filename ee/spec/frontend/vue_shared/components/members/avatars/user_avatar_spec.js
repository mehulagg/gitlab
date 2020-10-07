import { mount } from '@vue/test-utils';
import { GlBadge } from '@gitlab/ui';
import { member as memberMock } from 'jest/vue_shared/components/members/mock_data';
import UserAvatar from '~/vue_shared/components/members/avatars/user_avatar.vue';

describe('UserAvatar', () => {
  let wrapper;

  const createComponent = (propsData = {}) => {
    wrapper = mount(UserAvatar, {
      propsData: {
        isCurrentUser: false,
        ...propsData,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('badges', () => {
    it.each`
      member                                          | badgeText
      ${{ ...memberMock, usingLicense: true }}        | ${'Is using seat'}
      ${{ ...memberMock, groupSso: true }}            | ${'SAML'}
      ${{ ...memberMock, groupManagedAccount: true }} | ${'Managed Account'}
    `('renders the "$badgeText" badge', ({ member, badgeText }) => {
      createComponent({ member });

      expect(wrapper.find(GlBadge).text()).toBe(badgeText);
    });
  });
});
