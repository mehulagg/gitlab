import { shallowMount } from '@vue/test-utils';
import { GlToggle } from '@gitlab/ui';
import BoardSidebarSubscription from '~/boards/components/sidebar/board_sidebar_subscription.vue';
import { createStore } from '~/boards/stores';

describe('BoardSidebarSubscription', () => {
  let wrapper;
  let store;

  const findNotificationHeader = () => wrapper.find("[data-testid='notification-header-text']");
  const findToggle = () => wrapper.find(GlToggle);

  const createComponent = options => {
    wrapper = shallowMount(BoardSidebarSubscription, {
      store,
      ...options,
    });
  };

  beforeEach(() => {
    store = createStore();
    store.state.issues = {
      '1': {
        emailsDisabled: false,
      },
      '2': {
        emailsDisabled: true,
      },
    };
    store.state.activeId = '1';
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe.skip('computed', () => {});

  describe.skip('methods', () => {});

  describe('template', () => {
    beforeEach(() => {
      createComponent();
    });

    it('displays "notifications" heading', () => {
      expect(findNotificationHeader().text()).toEqual('Notifications');
    });

    it('renders a toggle', () => {
      expect(findToggle().exists()).toBe(true);
    });

    describe('when notification emails have been disabled', () => {
      beforeEach(() => {
        store.state.activeId = '2';
      });

      it('displays a message that notification emails have been disabled', () => {
        expect(findNotificationHeader().text()).toEqual(
          'Notifications have been disabled by the project or group owner',
        );
      });

      it('does not render a toggle', () => {
        expect(findToggle().exists()).toBe(false);
      });
    });
  });
});
