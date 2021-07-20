import { GlAvatar, GlAvatarLink, GlAvatarsInline } from '@gitlab/ui';
import { mount, shallowMount } from '@vue/test-utils';
import DrawerAvatarsList from 'ee/compliance_dashboard/components/shared/drawer_avatars_list.vue';
import DrawerSectionSubHeader from 'ee/compliance_dashboard/components/shared/drawer_section_sub_header.vue';
import { createApprovers } from '../../mock_data';

describe('DrawerAvatarsList component', () => {
  let wrapper;
  const header = 'Section sub header';
  const emptyHeader = 'Empty section sub header';
  const avatars = createApprovers(3);

  const findHeader = () => wrapper.findComponent(DrawerSectionSubHeader);
  const findInlineAvatars = () => wrapper.findComponent(GlAvatarsInline);
  const findAvatarLinks = () => wrapper.findAllComponents(GlAvatarLink);
  const findAvatars = () => wrapper.findAllComponents(GlAvatar);

  const createComponent = (mountFn = shallowMount, propsData = {}) => {
    return mountFn(DrawerAvatarsList, {
      propsData,
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('header', () => {
    it('does not render the header if it is not given', () => {
      wrapper = createComponent();

      expect(findHeader().exists()).toBe(false);
    });

    it('Renders the header if avatars are given', () => {
      wrapper = createComponent(shallowMount, { avatars, header, emptyHeader });

      expect(findHeader().text()).toBe(header);
    });

    it('renders the empty header if no avatars are given', () => {
      wrapper = createComponent(shallowMount, { header, emptyHeader });

      expect(findHeader().text()).toBe(emptyHeader);
    });
  });

  it('does not render the avatars list if they are not given', () => {
    wrapper = createComponent();

    expect(findInlineAvatars().exists()).toBe(false);
  });

  describe('With avatars', () => {
    beforeEach(() => {
      wrapper = createComponent(mount, { avatars });
    });

    it('renders the avatars', () => {
      expect(findAvatarLinks()).toHaveLength(avatars.length);
      expect(findInlineAvatars().props()).toMatchObject({
        avatars,
        badgeTooltipProp: 'name',
      });
    });

    it('sets the correct attributes to the avatar links', () => {
      expect(findAvatarLinks().at(0).classes()).toContain('js-user-link');
      expect(findAvatarLinks().at(0).attributes()).toMatchObject({
        title: avatars[0].name,
        href: avatars[0].web_url,
        'data-name': avatars[0].name,
        'data-user-id': `${avatars[0].id}`,
      });
    });

    it('sets the correct props to the avatars', () => {
      expect(findAvatars().at(0).props()).toMatchObject({
        entityName: avatars[0].name,
        src: avatars[0].avatar_url,
      });
    });
  });
});
