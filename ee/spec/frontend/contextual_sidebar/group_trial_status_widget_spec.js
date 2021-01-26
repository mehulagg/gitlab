import { shallowMount } from '@vue/test-utils';

import TrialStatusWidget from 'ee/contextual_sidebar/components/trial_status_widget.vue';

describe('TrialStatusWidget component', () => {
  let wrapper;

  const createComponent = () => {
    return shallowMount(TrialStatusWidget, {
      propsData: {
        href: 'billing/path-for/group',
        navIconImagePath: 'illustrations/golden_tanuki.svg',
        percentageComplete: 10,
        title: 'Gold Trial – 27 days left',
      },
    });
  };

  beforeEach(() => {
    wrapper = createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('matches the snapshot', () => {
    expect(wrapper.element).toMatchSnapshot();
  });
});
