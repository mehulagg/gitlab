import { shallowMount } from '@vue/test-utils';
import ResponsiveHome from '~/nav/components/responsive_home.vue';
import { TEST_NAV_DATA } from '../mock_data';

describe('~/nav/components/responsive_home.vue', () => {
  let wrapper;

  const createComponent = () => {
    wrapper = shallowMount(ResponsiveHome, {
      propsData: {
        navData: TEST_NAV_DATA,
      },
    });
  };

  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('has placeholder text for now', () => {
    expect(wrapper.text()).toBe(ResponsiveHome.TEMPORARY_PLACEHOLDER);
  });
});
