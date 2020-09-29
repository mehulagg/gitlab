import { mount, createWrapper } from '@vue/test-utils';
import { within } from '@testing-library/dom';
import { GlAvatarLink, GlBadge } from '@gitlab/ui';
import { member as memberMock, orphanedMember } from '../mock_data';
import UserAvatar from '~/vue_shared/components/members/avatars/user_avatar.vue';

describe('MemberList', () => {
  let wrapper;

  const { user } = memberMock;

  const createComponent = (propsData = {}) => {
    wrapper = mount(UserAvatar, {
      propsData: {
        member: memberMock,
        isCurrentUser: false,
        ...propsData,
      },
    });
  };

  const getByText = (text, options) =>
    createWrapper(within(wrapper.element).findByText(text, options));

  afterEach(() => {
    wrapper.destroy();
  });

  it("renders link to user's profile", () => {
    createComponent();

    const link = wrapper.find(GlAvatarLink);

    expect(link.exists()).toBe(true);
    expect(link.attributes()).toMatchObject({
      href: user.webUrl,
      'data-user-id': `${user.id}`,
      'data-username': user.username,
    });
  });

  it("renders user's name", () => {
    createComponent();

    expect(getByText(user.name).exists()).toBe(true);
  });

  it("renders user's username", () => {
    createComponent();

    expect(getByText(`@${user.username}`).exists()).toBe(true);
  });

  it("renders user's avatar", () => {
    createComponent();

    expect(wrapper.find('img').attributes('src')).toBe(user.avatarUrl);
  });

  describe('when user property does not exist', () => {
    it('displays an orphaned user', () => {
      createComponent({ member: orphanedMember });

      expect(getByText('Orphaned member').exists()).toBe(true);
    });
  });

  describe('badges', () => {
    it.each`
      member                                                                     | badgeText
      ${{ ...memberMock, usingLicense: true }}                                   | ${'Is using seat'}
      ${{ ...memberMock, user: { ...memberMock.user, blocked: true } }}          | ${'Blocked'}
      ${{ ...memberMock, user: { ...memberMock.user, twoFactorEnabled: true } }} | ${'2FA'}
      ${{ ...memberMock, groupSso: true }}                                       | ${'SAML'}
      ${{ ...memberMock, groupManagedAccount: true }}                            | ${'Managed Account'}
    `('renders the "$badgeText" badge', ({ member, badgeText }) => {
      createComponent({ member });

      const badgeComponent = wrapper.find(GlBadge);

      expect(badgeComponent.exists()).toBe(true);
      expect(badgeComponent.text()).toBe(badgeText);
    });

    it('renders the "It\'s you" badge when member is current user', () => {
      createComponent({ isCurrentUser: true });

      expect(getByText("It's you").exists()).toBe(true);
    });
  });
});
