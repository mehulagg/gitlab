import { GlPopover } from '@gitlab/ui';
import { mount } from '@vue/test-utils';
import { makeMockUserCalloutDismisser } from 'helpers/mock_user_callout_dismisser';
import TopNavApp from '~/nav/components/top_nav_app.vue';
import TopNavAppWithCallout from '~/nav/components/top_nav_app_with_callout.vue';
import UserCalloutDismisser from '~/vue_shared/components/user_callout_dismisser.vue';
import { TEST_NAV_DATA } from '../mock_data';

const cleanSprintfPlaceholders = (str) => str.replace(/%\{.+?\}/g, '');

describe('~/nav/components/top_nav_app_with_callout.vue', () => {
  let wrapper;
  let dismissSpy;

  const createComponent = ({ shouldShowCallout = false } = {}) => {
    wrapper = mount(TopNavAppWithCallout, {
      propsData: {
        navData: TEST_NAV_DATA,
      },
      stubs: {
        UserCalloutDismisser: makeMockUserCalloutDismisser({
          shouldShowCallout,
          dismiss: dismissSpy,
        }),
      },
    });
  };

  const findTopNavApp = () => wrapper.findComponent(TopNavApp);
  const findPopover = () => wrapper.findComponent(GlPopover);
  const findPopoverContent = () => findPopover().find('[data-testid="popover-content"]');
  const findUserCalloutDismisser = () => wrapper.findComponent(UserCalloutDismisser);

  beforeEach(() => {
    dismissSpy = jest.fn();
  });

  describe('default', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders user callout dismisser', () => {
      expect(findUserCalloutDismisser().attributes('feature-name')).toBe('combined_menu_top_nav');
    });

    it('renders top nav app', () => {
      expect(findTopNavApp().props()).toEqual({
        navData: TEST_NAV_DATA,
      });
    });

    it('does not render popover', () => {
      expect(findPopover().exists()).toBe(false);
    });

    it('when shown is emitted, does not dismiss', () => {
      findTopNavApp().vm.$emit('shown');

      expect(dismissSpy).not.toHaveBeenCalled();
    });
  });

  describe('when shouldShowCallout=true', () => {
    beforeEach(() => {
      createComponent({ shouldShowCallout: true });
    });

    it('renders top nav app', () => {
      expect(findTopNavApp().props()).toEqual({
        navData: TEST_NAV_DATA,
      });
    });

    it('renders popover', () => {
      expect(findPopover().props()).toEqual(
        expect.objectContaining({
          triggers: 'manual',
          placement: 'bottomright',
        }),
      );

      expect(findPopover().attributes('show')).toBe('');
    });

    it('renders popover target', () => {
      const targetSelector = findPopover().props('target');

      const target = targetSelector();

      expect(target).toHaveClass('js-top-nav-dropdown-toggle');
    });

    it('renders popover content', () => {
      const message = cleanSprintfPlaceholders(TopNavAppWithCallout.MESSAGE);

      expect(findPopoverContent().text()).toBe(message);
    });

    it('renders help link', () => {
      const link = findPopoverContent().find('a');

      expect(link.text()).toBe('feedback issue');
      expect(link.attributes('href')).toBe(TopNavAppWithCallout.FEEDBACK_URL);
    });

    it('when shown is emitted, does dismiss', () => {
      expect(dismissSpy).not.toHaveBeenCalled();

      findTopNavApp().vm.$emit('shown');

      expect(dismissSpy).toHaveBeenCalled();
    });

    it('when popover click is emitted, does dismiss', () => {
      expect(dismissSpy).not.toHaveBeenCalled();

      findPopoverContent().trigger('click');

      expect(dismissSpy).toHaveBeenCalled();
    });
  });
});
