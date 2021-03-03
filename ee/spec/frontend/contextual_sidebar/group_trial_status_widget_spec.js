import { GlLink } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';

import TrialStatusWidget from 'ee/contextual_sidebar/components/trial_status_widget.vue';

describe('TrialStatusWidget component', () => {
  let wrapper;

  const getGlLink = () => wrapper.findComponent(GlLink);

  const createComponent = ({ props } = {}) => {
    return shallowMount(TrialStatusWidget, {
      propsData: {
        daysRemaining: 20,
        navIconImagePath: 'illustrations/golden_tanuki.svg',
        percentageComplete: 10,
        planName: 'Ultimate',
        plansHref: 'billing/path-for/group',
        ...props,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('without the optional containerId prop', () => {
    beforeEach(() => {
      wrapper = createComponent();
    });

    it('matches the snapshot', () => {
      expect(wrapper.element).toMatchSnapshot();
    });

    it('renders without an id', () => {
      expect(getGlLink().attributes('id')).toBe(undefined);
    });
  });

  describe('with the optional containerId prop', () => {
    beforeEach(() => {
      wrapper = createComponent({ props: { containerId: 'some-id' } });
    });

    it('renders with the given id', () => {
      expect(getGlLink().attributes('id')).toBe('some-id');
    });
  });
});
