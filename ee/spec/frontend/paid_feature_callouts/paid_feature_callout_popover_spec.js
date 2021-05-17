import { GlPopover } from '@gitlab/ui';
import { GlBreakpointInstance } from '@gitlab/ui/dist/utils';
import { shallowMount } from '@vue/test-utils';

import PaidFeatureCalloutPopover from 'ee/paid_feature_callouts/components/paid_feature_callout_popover.vue';
import { mockTracking } from 'helpers/tracking_helper';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';

describe('PaidFeatureCalloutPopover', () => {
  let trackingSpy;
  let wrapper;

  const trackingExperimentKey = 'experiment:highlight_paid_features_during_active_trial';

  const findGlPopover = () => wrapper.findComponent(GlPopover);

  const defaultProps = {
    daysRemaining: 12,
    featureName: 'some feature',
    hrefComparePlans: '/group/test-group/-/billings',
    hrefUpgradeToPaid: '/-/subscriptions/new?namespace_id=123&plan_id=abc456',
    planNameForTrial: 'Awesomesauce',
    planNameForUpgrade: 'Amazing',
    targetId: 'some-feature-callout-target',
  };

  const createComponent = (extraProps = {}) => {
    return extendedWrapper(
      shallowMount(PaidFeatureCalloutPopover, {
        propsData: {
          ...defaultProps,
          ...extraProps,
        },
      }),
    );
  };

  beforeEach(() => {
    wrapper = createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('GlPopover attributes', () => {
    const sharedAttrs = {
      boundary: 'viewport',
      placement: 'top',
      target: 'some-feature-callout-target',
    };

    describe('with some default props', () => {
      it('sets attributes on the GlPopover component', () => {
        const attributes = findGlPopover().attributes();

        expect(attributes).toMatchObject(sharedAttrs);
        expect(attributes.containerId).toBeUndefined();
      });
    });

    describe('with additional, optional props', () => {
      beforeEach(() => {
        wrapper = createComponent({ containerId: 'some-container-id' });
      });

      it('sets more attributes on the GlPopover component', () => {
        expect(findGlPopover().attributes()).toMatchObject({
          ...sharedAttrs,
          container: 'some-container-id',
        });
      });
    });
  });

  describe('popoverTitle', () => {
    it('renders the title text', () => {
      expect(wrapper.vm.popoverTitle).toEqual('12 days remaining to enjoy some feature');
    });
  });

  describe('popoverContent', () => {
    it('renders the content text', () => {
      expect(wrapper.vm.popoverContent).toEqual(
        'Enjoying your GitLab Awesomesauce trial? To continue using some feature after your trial ends, upgrade to ' +
          'GitLab Amazing.',
      );
    });
  });

  describe('promo image', () => {
    const promoImagePathForTest = 'path/to/some/image.svg';

    const findPromoImage = () => wrapper.findByTestId('promo-img');

    describe('with the optional promoImagePath prop', () => {
      beforeEach(() => {
        wrapper = createComponent({ promoImagePath: promoImagePathForTest });
      });

      it('renders the promo image', () => {
        expect(findPromoImage().exists()).toBe(true);
      });

      describe('with the optional promoImageAltText prop', () => {
        beforeEach(() => {
          wrapper = createComponent({
            promoImagePath: promoImagePathForTest,
            promoImageAltText: 'My fancy alt text',
          });
        });

        it('renders the promo image with the given alt text', () => {
          expect(findPromoImage().attributes('alt')).toBe('My fancy alt text');
        });
      });

      describe('without the optional promoImageAltText prop', () => {
        it('renders the promo image with default alt text', () => {
          expect(findPromoImage().attributes('alt')).toBe('SVG illustration');
        });
      });
    });

    describe('without the optional promoImagePath prop', () => {
      it('does not render a promo image', () => {
        expect(findPromoImage().exists()).toBe(false);
      });
    });
  });

  describe('call-to-action buttons', () => {
    const sharedAttrs = {
      target: '_blank',
      variant: 'confirm',
      size: 'small',
      block: '',
      'data-track-action': 'click_button',
      'data-track-property': trackingExperimentKey,
    };

    const findUpgradeBtn = () => wrapper.findByTestId('upgradeBtn');
    const findCompareBtn = () => wrapper.findByTestId('compareBtn');

    it('correctly renders an Upgrade button', () => {
      const upgradeBtn = findUpgradeBtn();

      expect(upgradeBtn.text()).toEqual('Upgrade to GitLab Amazing');
      expect(upgradeBtn.attributes()).toMatchObject({
        ...sharedAttrs,
        href: '/-/subscriptions/new?namespace_id=123&plan_id=abc456',
        category: 'primary',
        'data-track-label': 'upgrade_to_ultimate',
      });
    });

    it('correctly renders a Compare button', () => {
      const compareBtn = findCompareBtn();

      expect(compareBtn.text()).toEqual('Compare all plans');
      expect(compareBtn.attributes()).toMatchObject({
        ...sharedAttrs,
        href: '/group/test-group/-/billings',
        category: 'secondary',
        'data-track-label': 'compare_all_plans',
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
        property: trackingExperimentKey,
      });
    });
  });

  describe('onResize', () => {
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
