import { GlNavItemDropdown } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import TopNavApp from '~/nav/components/top_nav_app.vue';
import TopNavDropdownMenu from '~/nav/components/top_nav_dropdown_menu.vue';
import { TEST_NAV_DATA } from '../mock_data';

describe('~/nav/components/top_nav_app.vue', () => {
  let wrapper;
  let shownSpy;

  const createComponent = () => {
    wrapper = shallowMount(TopNavApp, {
      propsData: {
        navData: TEST_NAV_DATA,
      },
      listeners: {
        shown: shownSpy,
      },
    });
  };

  const findNavItemDropdown = () => wrapper.findComponent(GlNavItemDropdown);
  const findMenu = () => wrapper.findComponent(TopNavDropdownMenu);

  beforeEach(() => {
    shownSpy = jest.fn();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('default', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders nav item dropdown', () => {
      expect(findNavItemDropdown().attributes('href')).toBeUndefined();
      expect(findNavItemDropdown().attributes()).toMatchObject({
        icon: 'hamburger',
        text: TEST_NAV_DATA.activeTitle,
        'no-flip': '',
      });
    });

    it('renders top nav dropdown menu', () => {
      expect(findMenu().props()).toStrictEqual({
        primary: TEST_NAV_DATA.primary,
        secondary: TEST_NAV_DATA.secondary,
        views: TEST_NAV_DATA.views,
      });
    });

    it('emits nav item dropdown events', () => {
      expect(shownSpy).not.toHaveBeenCalled();

      findNavItemDropdown().vm.$emit('shown', 'arg');

      expect(shownSpy).toHaveBeenCalledWith('arg');
    });
  });
});
