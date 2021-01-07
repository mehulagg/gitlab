import { GlProgressBar } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';

import TrialStatusWidget from 'ee/contextual_sidebar/components/trial_status_widget.vue'

describe('TrialStatusWidget component', () => {
  let wrapper;

  const defaultProps = {
    href: 'billing/path-for/group',
    navIconImagePath: 'illustrations/golden_tanuki.svg',
    percentageComplete: 10,
    title: 'Gold Trial – 27 days left',
  }

  const createComponent = (props = {}) => {
    return shallowMount(TrialStatusWidget, {
      propsData: {
        ...defaultProps,
        ...props
      },
      stubs: {
        GlProgressBar,
      }
    })
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('when …', () => {
    beforeEach(() => {
      wrapper = createComponent();
    });

    it('matches the snapshot', () => {
      expect(wrapper.element).toMatchSnapshot();
    });
  });
});
