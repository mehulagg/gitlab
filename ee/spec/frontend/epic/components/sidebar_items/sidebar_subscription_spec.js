import Vue from 'vue';

import SidebarSubscription from 'ee/epic/components/sidebar_items/sidebar_subscription.vue';
import createStore from 'ee/epic/store';

import { mountComponentWithStore } from 'helpers/vue_mount_component_helper';
import { mockEpicMeta, mockEpicData } from '../../mock_data';

describe('SidebarSubscriptionComponent', () => {
  let vm;
  let store;

  beforeEach(() => {
    const Component = Vue.extend(SidebarSubscription);
    store = createStore();
    store.dispatch('setEpicMeta', mockEpicMeta);
    store.dispatch('setEpicData', mockEpicData);

    vm = mountComponentWithStore(Component, {
      store,
      props: { sidebarCollapsed: false },
    });
  });

  afterEach(() => {
    vm.$destroy();
  });

  describe('template', () => {
    it('renders subscription toggle element container', () => {
      expect(vm.$el.classList.contains('block')).toBe(true);
      expect(vm.$el.classList.contains('subscription')).toBe(true);
    });

    it('renders toggle title text', () => {
      expect(vm.$el.querySelector('.issuable-header-text').innerText.trim()).toBe('Notifications');
    });

    it('renders toggle button element', () => {
      expect(vm.$el.querySelector('.js-issuable-subscribe-button button')).not.toBeNull();
    });
  });
});
