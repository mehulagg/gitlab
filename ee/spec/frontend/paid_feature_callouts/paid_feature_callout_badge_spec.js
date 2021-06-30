import { GlBadge, GlIcon } from '@gitlab/ui';
import { GlBreakpointInstance } from '@gitlab/ui/dist/utils';
import { shallowMount } from '@vue/test-utils';

import PaidFeatureCalloutBadge from 'ee/paid_feature_callouts/components/paid_feature_callout_badge.vue';
import { BADGE } from 'ee/paid_feature_callouts/constants';
import { mockTracking } from 'helpers/tracking_helper';
import { sprintf } from '~/locale';

describe('PaidFeatureCalloutBadge component', () => {
  let trackingSpy;
  let wrapper;
  const { i18n, trackingEvents } = BADGE;

  const findGlBadge = () => wrapper.findComponent(GlBadge);
  const findGlIcon = () => wrapper.findComponent(GlIcon);

  const createComponent = (props = {}) => {
    return shallowMount(PaidFeatureCalloutBadge, { propsData: props });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('default rendering', () => {
    beforeEach(() => {
      wrapper = createComponent();
    });

    it('sets attributes on the GlBadge component', () => {
      expect(findGlBadge().attributes()).toMatchObject({
        title: i18n.title.generic,
        tabindex: '0',
        size: 'sm',
        class: 'feature-highlight-badge',
      });
    });

    it('sets attributes on the GlIcon component', () => {
      expect(findGlIcon().attributes()).toEqual({
        name: 'license',
        size: '14',
      });
    });
  });

  describe('title', () => {
    describe('when no featureName is provided', () => {
      it('sets the title to a sensible default', () => {
        wrapper = createComponent();
        expect(findGlBadge().attributes('title')).toBe(i18n.title.generic);
      });
    });

    describe('when an optional featureName is provided', () => {
      it('sets the title using the given feature name', () => {
        const props = { featureName: 'fantastical thing' };
        wrapper = createComponent(props);
        expect(findGlBadge().attributes('title')).toBe(sprintf(i18n.title.specific, props));
      });
    });
  });

  describe('tracking', () => {
    beforeEach(() => {
      trackingSpy = mockTracking(undefined, undefined, jest.spyOn);
      wrapper = createComponent();
    });

    it('tracks that the badge has been displayed when mounted', () => {
      const { action, ...trackingOpts } = trackingEvents.displayBadge;

      expect(trackingSpy).toHaveBeenCalledWith(
        undefined,
        action,
        expect.objectContaining(trackingOpts),
      );
    });
  });

  describe('onResize', () => {
    beforeEach(() => {
      wrapper = createComponent();
    });

    it.each`
      bp      | tooltipDisabled
      ${'xs'} | ${false}
      ${'sm'} | ${true}
      ${'md'} | ${true}
      ${'lg'} | ${true}
      ${'xl'} | ${true}
    `(
      'sets tooltipDisabled to `$tooltipDisabled` when the breakpoint is "$bp"',
      async ({ bp, tooltipDisabled }) => {
        jest.spyOn(GlBreakpointInstance, 'getBreakpointSize').mockReturnValue(bp);

        wrapper.vm.onResize();
        await wrapper.vm.$nextTick();

        expect(wrapper.vm.tooltipDisabled).toBe(tooltipDisabled);
      },
    );
  });
});
