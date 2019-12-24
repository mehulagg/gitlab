import { shallowMount } from '@vue/test-utils';
import { HeaderCell } from 'ee/licenses/components/cells';

describe('HeaderCell', () => {
  let wrapper;

  function createComponent() {
    wrapper = shallowMount(HeaderCell, {
      sync: false,

      propsData: {
        title: 'title',
        icon: 'retry',
      },
    });
  }

  afterEach(() => {
    if (wrapper) wrapper.destroy();
  });

  it('renders an inflexible cell with a title with an icon through props', () => {
    createComponent();

    expect(wrapper.element).toMatchSnapshot();
  });
});
