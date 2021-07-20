import { GlPopover } from '@gitlab/ui';
import { GlBreakpointInstance } from '@gitlab/ui/dist/utils';
import { mount, shallowMount } from '@vue/test-utils';

import PaidFeatureCalloutPopover from 'ee/paid_feature_callouts/components/paid_feature_callout_popover.vue';
import { POPOVER } from 'ee/paid_feature_callouts/constants';
import { mockTracking, unmockTracking } from 'helpers/tracking_helper';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import { sprintf } from '~/locale';

const { i18n, trackingEvents } = POPOVER;

describe('PaidFeatureCalloutPopover', () => {
  let trackingSpy;
  let wrapper;

  const findGlPopover = () => wrapper.findComponent(GlPopover);
  const findUpgradeBtn = () => wrapper.findByTestId('upgradeBtn');
  const findCompareBtn = () => wrapper.findByTestId('compareBtn');

  const defaultProps = {
    daysRemaining: 12,
    featureName: 'some feature',
    hrefComparePlans: '/group/test-group/-/billings',
    hrefUpgradeToPaid: '/-/subscriptions/new?namespace_id=123&plan_id=abc456',
    planNameForTrial: 'Awesomesauce',
    planNameForUpgrade: 'Amazing',
    targetId: 'some-feature-callout-target',
  };

  const createComponent = (extraProps = {}, mountFn = shallowMount) => {
    return extendedWrapper(
      mountFn(PaidFeatureCalloutPopover, {
        propsData: {
          ...defaultProps,
          ...extraProps,
        },
      }),
    );
  };

  beforeEach(() => {
    trackingSpy = mockTracking(undefined, undefined, jest.spyOn);
    wrapper = createComponent();
  });

  afterEach(() => {
    unmockTracking();
    wrapper.destroy();
  });

  describe('interpolated strings', () => {
    it('correctly interpolates them all', () => {
      wrapper = createComponent({}, mount);

      expect(wrapper.text()).not.toMatch(/%{\w+}/);
    });
  });

  describe('GlPopover attributes', () => {
    const sharedAttrs = {
      boundary: 'viewport',
      placement: 'top',
      target: defaultProps.targetId,
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
        const promoImageAltText = 'My fancy alt text';

        beforeEach(() => {
          wrapper = createComponent({
            promoImagePath: promoImagePathForTest,
            promoImageAltText,
          });
        });

        it('renders the promo image with the given alt text', () => {
          expect(findPromoImage().attributes('alt')).toBe(promoImageAltText);
        });
      });

      describe('without the optional promoImageAltText prop', () => {
        it('renders the promo image with default alt text', () => {
          expect(findPromoImage().attributes('alt')).toBe(i18n.defaultImgAltText);
        });
      });
    });

    describe('without the optional promoImagePath prop', () => {
      it('does not render a promo image', () => {
        expect(findPromoImage().exists()).toBe(false);
      });
    });
  });

  describe('title', () => {
    const expectTitleToMatch = (daysRemaining) => {
      expect(wrapper.text()).toContain(
        sprintf(i18n.title.countableTranslator(daysRemaining), {
          daysRemaining,
          featureName: defaultProps.featureName,
        }),
      );
    };

    describe('singularized form', () => {
      it('renders the title text with "1 day"', () => {
        wrapper = createComponent({ daysRemaining: 1 }, mount);

        expectTitleToMatch(1);
      });
    });

    describe('pluralized form', () => {
      it('renders the title text with "5 days"', () => {
        wrapper = createComponent({ daysRemaining: 5 }, mount);

        expectTitleToMatch(5);
      });

      it('renders the title text with "0 days"', () => {
        wrapper = createComponent({ daysRemaining: 0 }, mount);

        expectTitleToMatch(0);
      });
    });
  });

  describe('content', () => {
    it('renders the content text', () => {
      expect(findGlPopover().text()).toMatch(
        sprintf(i18n.content, {
          featureName: defaultProps.featureName,
          planNameForTrial: defaultProps.planNameForTrial,
          planNameForUpgrade: defaultProps.planNameForUpgrade,
        }),
      );
    });
  });

  describe('call-to-action buttons', () => {
    const sharedAttrs = {
      target: '_blank',
      variant: 'confirm',
      size: 'small',
      block: '',
    };

    describe('upgrade plan button', () => {
      it('correctly renders an Upgrade button', () => {
        const upgradeBtn = findUpgradeBtn();

        expect(upgradeBtn.text()).toEqual(
          sprintf(i18n.buttons.upgrade, { planNameForUpgrade: defaultProps.planNameForUpgrade }),
        );
        expect(upgradeBtn.attributes()).toMatchObject({
          ...sharedAttrs,
          href: defaultProps.hrefUpgradeToPaid,
          category: 'primary',
        });
      });

      it('tracks on click', () => {
        const { action, ...trackingOpts } = trackingEvents.upgradeBtnClick;
        findUpgradeBtn().vm.$emit('click');

        expect(trackingSpy).toHaveBeenCalledWith(
          undefined,
          action,
          expect.objectContaining(trackingOpts),
        );
      });
    });

    describe('compare plans button', () => {
      it('correctly renders a Compare button', () => {
        const compareBtn = findCompareBtn();

        expect(compareBtn.text()).toEqual(i18n.buttons.comparePlans);
        expect(compareBtn.attributes()).toMatchObject({
          ...sharedAttrs,
          href: defaultProps.hrefComparePlans,
          category: 'secondary',
        });
      });

      it('tracks on click', () => {
        const { action, ...trackingOpts } = trackingEvents.compareBtnClick;
        findCompareBtn().vm.$emit('click');

        expect(trackingSpy).toHaveBeenCalledWith(
          undefined,
          action,
          expect.objectContaining(trackingOpts),
        );
      });
    });
  });

  describe('onShown', () => {
    it('tracks that the popover has been shown', () => {
      const { action, label } = trackingEvents.popoverShown;
      findGlPopover().vm.$emit('shown');

      expect(trackingSpy).toHaveBeenCalledWith(
        undefined,
        action,
        expect.objectContaining({
          label: `${label}:${defaultProps.featureName}`,
        }),
      );
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
