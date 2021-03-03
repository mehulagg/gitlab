import { GlToggle } from '@gitlab/ui';
import { mount } from '@vue/test-utils';
import SidebarSubscription from 'ee/epic/components/sidebar_items/sidebar_subscription.vue';
import createStore from 'ee/epic/store';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';

describe('SidebarSubscriptionComponent', () => {
  let wrapper;

  beforeEach(() => {
    wrapper = extendedWrapper(
      mount(SidebarSubscription, {
        store: createStore(),
        propsData: { sidebarCollapsed: false },
      }),
    );
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('template', () => {
    it('renders subscription toggle element container', () => {
      expect(wrapper.classes('block')).toBe(true);
      expect(wrapper.classes('subscription')).toBe(true);
    });

    it('renders toggle title text', () => {
      expect(wrapper.findByTestId('subscription-title').text()).toBe('Notifications');
    });

    it('renders toggle button element', () => {
      expect(wrapper.findComponent(GlToggle).exists()).toBe(true);
    });
  });
});
