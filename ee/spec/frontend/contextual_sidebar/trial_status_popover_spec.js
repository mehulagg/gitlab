import { GlPopover } from '@gitlab/ui';
import { GlBreakpointInstance } from '@gitlab/ui/dist/utils';
import { mount, shallowMount } from '@vue/test-utils';
import Vue from 'vue';
import { POPOVER, TRACKING_PROPERTY } from 'ee/contextual_sidebar/components/constants';
import TrialStatusPopover from 'ee/contextual_sidebar/components/trial_status_popover.vue';
import { mockTracking, unmockTracking } from 'helpers/tracking_helper';

Vue.config.ignoredElements = ['gl-emoji'];

describe('TrialStatusPopover component', () => {
  let wrapper;
  let trackingSpy;

  const { trackingEvents } = POPOVER;

  const findByTestId = (testId) => wrapper.find(`[data-testid="${testId}"]`);
  const findGlPopover = () => wrapper.findComponent(GlPopover);

  const expectTracking = ({ action, ...options } = {}) => {
    return expect(trackingSpy).toHaveBeenCalledWith(undefined, action, {
      ...options,
      property: TRACKING_PROPERTY,
    });
  };

  const createComponent = (mountFn = shallowMount) => {
    return mountFn(TrialStatusPopover, {
      provide: {
        groupName: 'Some Test Group',
        planName: 'Ultimate',
        plansHref: 'billing/path-for/group',
        purchaseHref: 'transactions/new',
        targetId: 'target-element-identifier',
        trialEndDate: new Date('2021-02-28'),
      },
    });
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
    findByTestId('upgradeBtn').vm.$emit('click');

    expectTracking(trackingEvents.upgradeBtnClick);
  });

  it('tracks when the compare button is clicked', () => {
    findByTestId('compareBtn').vm.$emit('click');

    expectTracking(trackingEvents.compareBtnClick);
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
