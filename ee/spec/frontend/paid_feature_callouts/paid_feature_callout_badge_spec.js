import { GlBadge } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';

import PaidFeatureCalloutWidget from 'ee/paid_feature_callouts/components/paid_feature_callout_badge.vue';
import { mockTracking } from 'helpers/tracking_helper';

describe('PaidFeatureCalloutBadge component', () => {
  let wrapper;

  const getGlBadge = () => wrapper.findComponent(GlBadge);

  const createComponent = ({ props } = {}) => {
    return shallowMount(PaidFeatureCalloutWidget, {
      propsData: {
        ...props,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('without the optional title prop', () => {
    beforeEach(() => {
      wrapper = createComponent();
    });

    it('renders the default title', () => {
      expect(getGlBadge().attributes('title')).toBe(
        'This feature is part of your GitLab Ultimate trial.',
      );
    });
  });

  describe('with the optional title prop', () => {
    beforeEach(() => {
      wrapper = createComponent({ props: { title: 'My new title to display.' } });
    });

    it('renders with the given title', () => {
      expect(getGlBadge().attributes('title')).toBe('My new title to display.');
    });
  });

  describe('tracking', () => {
    let trackingSpy;

    beforeEach(() => {
      trackingSpy = mockTracking(undefined, undefined, jest.spyOn);
      wrapper = createComponent();
    });

    it('tracks that the badge has been displayed when mounted', () => {
      expect(trackingSpy).toHaveBeenCalledWith(undefined, 'display_badge', {
        label: 'feature_highlight_badge',
        property: 'experiment:highlight_paid_features_during_active_trial',
      });
    });
  });
});
