import { GlBadge } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';

import PaidFeatureCalloutBadge from 'ee/paid_feature_callouts/components/paid_feature_callout_badge.vue';
import { mockTracking } from 'helpers/tracking_helper';

describe('PaidFeatureCalloutBadge component', () => {
  let trackingSpy;
  let wrapper;

  const findGlBadge = () => wrapper.findComponent(GlBadge);

  const createComponent = () => {
    return shallowMount(PaidFeatureCalloutBadge);
  };

  beforeEach(() => {
    trackingSpy = mockTracking(undefined, undefined, jest.spyOn);
    wrapper = createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders the title', () => {
    expect(findGlBadge().attributes('title')).toBe(
      'This feature is part of your GitLab Ultimate trial.',
    );
  });

  it('tracks that the badge has been displayed when mounted', () => {
    expect(trackingSpy).toHaveBeenCalledWith(undefined, 'display_badge', {
      label: 'feature_highlight_badge',
      property: 'experiment:highlight_paid_features_during_active_trial',
    });
  });
});
