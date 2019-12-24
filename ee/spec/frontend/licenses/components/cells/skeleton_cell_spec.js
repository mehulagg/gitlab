import { shallowMount } from '@vue/test-utils';
import { SkeletonCell } from 'ee/licenses/components/cells';

describe('SkeletonCell', () => {
  let wrapper;

  function createComponent() {
    wrapper = shallowMount(SkeletonCell, {
      sync: false,
    });
  }

  afterEach(() => {
    if (wrapper) wrapper.destroy();
  });

  it('renders a skeleton cell with a title and value loading bar', () => {
    createComponent();

    expect(wrapper.element).toMatchSnapshot();
  });
});
