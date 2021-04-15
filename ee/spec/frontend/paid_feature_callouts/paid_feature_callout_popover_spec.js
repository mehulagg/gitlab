import { GlPopover } from '@gitlab/ui';
import { GlBreakpointInstance } from '@gitlab/ui/dist/utils';
import { shallowMount } from '@vue/test-utils';

import PaidFeatureCalloutPopover from 'ee/paid_feature_callouts/components/paid_feature_callout_popover.vue';
import { mockTracking } from 'helpers/tracking_helper';

describe('PaidFeatureCalloutPopover', () => {
  let trackingSpy;
  let wrapper;

  const findGlPopover = () => wrapper.findComponent(GlPopover);

  const defaultProps = {
    containerId: 'some-feature-callout-container',
    daysRemaining: 12,
    featureName: 'some feature',
    planNameForTrial: 'Ultimate',
    planNameForUpgrade: 'Premium',
    promoImagePath: 'path/to/some/image.svg',
    targetId: 'some-feature-callout-target',
  };

  const createComponent = (props = defaultProps) => {
    return shallowMount(PaidFeatureCalloutPopover, {
      propsData: props,
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('with some default props', () => {
    beforeEach(() => {
      wrapper = createComponent();
    });

    it('sets attributes on the GlPopover component', () => {
      expect(findGlPopover().attributes()).toMatchObject({
        container: 'some-feature-callout-container',
        target: 'some-feature-callout-target',
        placement: 'top',
        boundary: 'viewport',
      });
    });
  });

  describe('onShown', () => {
    beforeEach(() => {
      trackingSpy = mockTracking(undefined, undefined, jest.spyOn);
      wrapper = createComponent();
      findGlPopover().vm.$emit('shown');
    });

    it('tracks that the popover has been shown', () => {
      expect(trackingSpy).toHaveBeenCalledWith(undefined, 'popover_shown', {
        label: 'feature_highlight_popover:some feature',
        property: 'experiment:highlight_paid_features_during_active_trial',
      });
    });
  });

  describe('onResize', () => {
    beforeEach(() => {
      wrapper = createComponent();
    });

    it.each`
      bp      | disabled
      ${'xs'} | ${'true'}
      ${'sm'} | ${undefined}
      ${'md'} | ${undefined}
      ${'lg'} | ${undefined}
      ${'xl'} | ${undefined}
    `(
      'sets the GlPopover’s disabled attribute to `$disabled` when the breakpoint is "$bp"',
      async ({ bp, disabled }) => {
        jest.spyOn(GlBreakpointInstance, 'getBreakpointSize').mockReturnValue(bp);

        wrapper.vm.onResize();
        await wrapper.vm.$nextTick();

        expect(findGlPopover().attributes('disabled')).toBe(disabled);
      },
    );
  });
});
