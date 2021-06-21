import { GlPopover } from '@gitlab/ui';
import { GlBreakpointInstance } from '@gitlab/ui/dist/utils';
import { mount, shallowMount } from '@vue/test-utils';
import Vue from 'vue';
import TrialStatusPopover from 'ee/contextual_sidebar/components/trial_status_popover.vue';
import { mockTracking } from 'helpers/tracking_helper';

Vue.config.ignoredElements = ['gl-emoji'];

describe('TrialStatusPopover component', () => {
  let wrapper;
  let trackingSpy;

  const findByTestId = (testId) => wrapper.find(`[data-testid="${testId}"]`);
  const findGlPopover = () => wrapper.findComponent(GlPopover);

  const createComponent = (props = {}, mountFn = shallowMount) => {
    return mountFn(TrialStatusPopover, {
      propsData: {
        groupName: 'Some Test Group',
        planName: 'Ultimate',
        plansHref: 'billing/path-for/group',
        purchaseHref: 'transactions/new',
        targetId: 'target-element-identifier',
        trialEndDate: new Date('2021-02-28'),
        ...props,
      },
    });
  };

  beforeEach(() => {
    wrapper = createComponent();
    trackingSpy = mockTracking('_category_', wrapper.element, jest.spyOn);
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('matches the snapshot', () => {
    expect(wrapper.element).toMatchSnapshot();
  });

  it('renders the upgrade button with correct tracking data attrs', () => {
    const attrs = findByTestId('upgradeBtn').attributes();
    expect(attrs['data-track-event']).toBe('click_button');
    expect(attrs['data-track-label']).toBe('upgrade_to_ultimate');
    expect(attrs['data-track-property']).toBe('experiment:show_trial_status_in_sidebar');
  });

  it('renders the compare plans button with correct tracking data attrs', () => {
    const attrs = findByTestId('compareBtn').attributes();
    expect(attrs['data-track-event']).toBe('click_button');
    expect(attrs['data-track-label']).toBe('compare_all_plans');
    expect(attrs['data-track-property']).toBe('experiment:show_trial_status_in_sidebar');
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

      it('tracks the popover_shown event', () => {
        expect(trackingSpy).toHaveBeenCalledWith(undefined, 'popover_shown', {
          label: 'trial_status_popover',
          property: 'experiment:show_trial_status_in_sidebar',
        });
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
    beforeEach(async () => {
      wrapper = createComponent({ startInitiallyShown: true }, mount);
      findByTestId('closeBtn').trigger('click');
      await wrapper.vm.$nextTick();
    });

    it('closes the popover component', () => {
      expect(findGlPopover().attributes('show')).toBeFalsy();
    });

    it('tracks an event', () => {
      expect(trackingSpy).toHaveBeenCalledWith(undefined, 'click_button', {
        label: 'close_popover',
        property: 'experiment:show_trial_status_in_sidebar',
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
      beforeEach(() => {
        findGlPopover().vm.$emit('shown');
      });

      it('dispatches tracking event', () => {
        expect(trackingSpy).toHaveBeenCalledWith(undefined, 'popover_shown', {
          label: 'trial_status_popover',
          property: 'experiment:show_trial_status_in_sidebar',
        });
      });
    });
  });
});
