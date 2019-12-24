import { shallowMount } from '@vue/test-utils';
import { InfoCell } from 'ee/licenses/components/cells';

describe('InfoCell', () => {
  let wrapper;
  const defaultProps = {
    title: 'title',
    value: 'value',
    popoverContent: 'popoverContent',
  };

  function createComponent(props, slots) {
    const propsData = Object.assign({}, defaultProps, props);

    wrapper = shallowMount(InfoCell, {
      sync: false,
      propsData,
      slots,
    });
  }

  afterEach(() => {
    if (wrapper) wrapper.destroy();
  });

  it('renders a title and string value with an info popover through props', () => {
    createComponent();

    expect(wrapper.element).toMatchSnapshot();
  });

  it('renders a number value', () => {
    createComponent({ value: 100 });

    expect(wrapper.element).toMatchSnapshot();
  });
});
