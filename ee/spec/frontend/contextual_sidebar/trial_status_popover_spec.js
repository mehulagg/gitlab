import { GlPopover } from '@gitlab/ui';
import { GlBreakpointInstance } from '@gitlab/ui/dist/utils';
import { mount, shallowMount } from '@vue/test-utils';
import Vue from 'vue';
import { POPOVER, TRACKING_PROPERTY } from 'ee/contextual_sidebar/components/constants';
import TrialStatusPopover from 'ee/contextual_sidebar/components/trial_status_popover.vue';
import { mockTracking, unmockTracking } from 'helpers/tracking_helper';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';

Vue.config.ignoredElements = ['gl-emoji'];

describe('TrialStatusPopover component', () => {
  let wrapper;
  let trackingSpy;

  const { trackingEvents } = POPOVER;

  const findGlPopover = () => wrapper.findComponent(GlPopover);

  const expectTracking = ({ action, ...options } = {}) => {
    return expect(trackingSpy).toHaveBeenCalledWith(undefined, action, {
      ...options,
      property: TRACKING_PROPERTY,
    });
  };

  const createComponent = (providers = {}, mountFn = shallowMount) => {
    return extendedWrapper(
      mountFn(TrialStatusPopover, {
        provide: {
          groupName: 'Some Test Group',
          planName: 'Ultimate',
          plansHref: 'billing/path-for/group',
          purchaseHref: 'transactions/new',
          targetId: 'target-element-identifier',
          trialEndDate: new Date('2021-02-28'),
          ...providers,
        },
      }),
    );
  };

  beforeEach(() => {
    wrapper = createComponent();
    trackingSpy = mockTracking('_category_', wrapper.element, jest.spyOn);
  });

  afterEach(() => {
    wrapper.destroy();
    unmockTracking();
  });

  describe('interpolated strings', () => {
    it('correctly interpolates them all', () => {
      wrapper = createComponent(mount);

      expect(wrapper.text()).not.toMatch(/%{\w+}/);
    });
  });

  it('matches the snapshot', () => {
    expect(wrapper.element).toMatchSnapshot();
  });

  it('tracks when the upgrade button is clicked', () => {
    wrapper.findByTestId('upgradeBtn').vm.$emit('click');

    expectTracking(trackingEvents.upgradeBtnClick);
  });

  it('tracks when the compare button is clicked', () => {
    wrapper.findByTestId('compareBtn').vm.$emit('click');

    expectTracking(trackingEvents.compareBtnClick);
  });

  describe('startInitiallyShown', () => {
    describe('when set to true', () => {
      beforeEach(() => {
        wrapper = createComponent({ startInitiallyShown: true });
      });

      it('causes the popover to be shown by default', () => {
        expect(findGlPopover().attributes('show')).toBeTruthy();
      });

      it('removes the popover triggers', () => {
        expect(findGlPopover().attributes('triggers')).toBe('');
      });
    });

    describe('when set to false', () => {
      beforeEach(() => {
        wrapper = createComponent({ startInitiallyShown: false });
      });

      it('does not cause the popover to be shown by default', () => {
        expect(findGlPopover().attributes('show')).toBeFalsy();
      });

      it('uses the standard triggers for the popover', () => {
        expect(findGlPopover().attributes('triggers')).toBe('hover focus');
      });
    });
  });

  describe('close button', () => {
    describe('when the popover starts off forcibly shown', () => {
      beforeEach(() => {
        wrapper = createComponent({ startInitiallyShown: true }, mount);
      });

      it('is rendered', () => {
        expect(wrapper.findByTestId('closeBtn').exists()).toBeTruthy();
      });

      describe('when clicked', () => {
        beforeEach(async () => {
          wrapper.findByTestId('closeBtn').trigger('click');
          await wrapper.vm.$nextTick();
        });

        it('closes the popover component', () => {
          expect(findGlPopover().props('show')).toBeFalsy();
        });

        it('tracks an event', () => {
          expectTracking(trackingEvents.closeBtnClick);
        });

        it('continues to be shown in the popover', () => {
          expect(wrapper.findByTestId('closeBtn').exists()).toBeTruthy();
        });
      });
    });

    describe('when the popover does not start off forcibly shown', () => {
      it('is not rendered', () => {
        expect(wrapper.findByTestId('closeBtn').exists()).toBeFalsy();
      });
    });
  });

  describe('methods', () => {
    describe('onResize', () => {
      it.each`
        bp      | isDisabled
        ${'xs'} | ${'true'}
        ${'sm'} | ${'true'}
        ${'md'} | ${undefined}
        ${'lg'} | ${undefined}
        ${'xl'} | ${undefined}
      `(
        'sets disabled to `$isDisabled` when the breakpoint is "$bp"',
        async ({ bp, isDisabled }) => {
          jest.spyOn(GlBreakpointInstance, 'getBreakpointSize').mockReturnValue(bp);

          wrapper.vm.onResize();
          await wrapper.vm.$nextTick();

          expect(findGlPopover().attributes('disabled')).toBe(isDisabled);
        },
      );
    });

    describe('onShown', () => {
      it('dispatches tracking event', () => {
        findGlPopover().vm.$emit('shown');

        expectTracking(trackingEvents.popoverShown);
      });
    });
  });
});
