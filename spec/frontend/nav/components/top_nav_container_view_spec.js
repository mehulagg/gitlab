import { shallowMount } from '@vue/test-utils';
import FrequentItemsApp from '~/frequent_items/components/app.vue';
import { FREQUENT_ITEMS_PROJECTS } from '~/frequent_items/constants';
import eventHub from '~/frequent_items/event_hub';
import TopNavContainerView from '~/nav/components/top_nav_container_view.vue';
import TopNavMenuItem from '~/nav/components/top_nav_menu_item.vue';
import VuexModuleProvider from '~/vue_shared/components/vuex_module_provider.vue';
import { TEST_NAV_DATA } from '../mock_data';

const DEFAULT_PROPS = {
  frequentItemsDropdownType: FREQUENT_ITEMS_PROJECTS.namespace,
  frequentItemsVuexModule: FREQUENT_ITEMS_PROJECTS.vuexModule,
  linksPrimary: TEST_NAV_DATA.primary,
  linksSecondary: TEST_NAV_DATA.secondary,
};
const TEST_OTHER_PROPS = {
  namespace: 'projects',
  currentUserName: '',
  currentItem: {},
};

describe('~/nav/components/top_nav_container_view.vue', () => {
  let wrapper;

  const createComponent = (props = {}) => {
    wrapper = shallowMount(TopNavContainerView, {
      propsData: {
        ...DEFAULT_PROPS,
        ...TEST_OTHER_PROPS,
        ...props,
      },
    });
  };

  const findAllMenuItems = (parent = wrapper) =>
    parent.findAll(TopNavMenuItem).wrappers.map((x) => x.props());
  const findMenuItemGroups = () =>
    wrapper.findAll('[data-testid="menu-item-group"]').wrappers.map(findAllMenuItems);
  const findFrequentItemsApp = () => {
    const parent = wrapper.findComponent(VuexModuleProvider);

    return {
      vuexModule: parent.props('vuexModule'),
      props: parent.findComponent(FrequentItemsApp).props(),
    };
  };

  afterEach(() => {
    wrapper.destroy();
  });

  it.each(['projects', 'groups'])(
    'emits frequent items event to event hub (%s)',
    async (frequentItemsDropdownType) => {
      const listener = jest.fn();
      eventHub.$on(`${frequentItemsDropdownType}-dropdownOpen`, listener);
      createComponent({ frequentItemsDropdownType });

      expect(listener).not.toHaveBeenCalled();

      await wrapper.vm.$nextTick();

      expect(listener).toHaveBeenCalled();
    },
  );

  describe('default', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders frequent items app', () => {
      expect(findFrequentItemsApp()).toEqual({
        vuexModule: DEFAULT_PROPS.frequentItemsVuexModule,
        props: TEST_OTHER_PROPS,
      });
    });

    it('renders menu item groups', () => {
      expect(findMenuItemGroups()).toEqual([
        TEST_NAV_DATA.primary.map((menuItem) => ({ menuItem })),
        TEST_NAV_DATA.secondary.map((menuItem) => ({ menuItem })),
      ]);
    });
  });

  describe('without secondary links', () => {
    beforeEach(() => {
      createComponent({
        linksSecondary: [],
      });
    });

    it('renders one menu item group', () => {
      expect(findMenuItemGroups()).toEqual([
        TEST_NAV_DATA.primary.map((menuItem) => ({ menuItem })),
      ]);
    });
  });
});
