import { shallowMount } from '@vue/test-utils';
import { SkeletonLicenseCard } from 'ee/licenses/components/cards';

describe('SkeletonLicenseCard', () => {
  let wrapper;

  function createComponent() {
    wrapper = shallowMount(SkeletonLicenseCard, {
      sync: false,
    });
  }

  afterEach(() => {
    if (wrapper) wrapper.destroy();
  });

  it('renders a skeleton license card', () => {
    createComponent();

    expect(wrapper.element).toMatchSnapshot();
  });
});
