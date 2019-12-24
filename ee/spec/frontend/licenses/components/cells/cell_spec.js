import { shallowMount } from '@vue/test-utils';
import { Cell } from 'ee/licenses/components/cells';

describe('Cell', () => {
  let wrapper;
  const defaultProps = {
    title: 'title',
    value: 'value',
  };

  function createComponent(props, slots) {
    const propsData = Object.assign({}, defaultProps, props);

    wrapper = shallowMount(Cell, {
      sync: false,
      propsData,
      slots,
    });
  }

  afterEach(() => {
    if (wrapper) wrapper.destroy();
  });

  it('renders a string value and title through props', () => {
    createComponent();

    expect(wrapper.element).toMatchSnapshot();
  });

  it('renders a number value and title through props', () => {
    createComponent({ value: 100 });

    expect(wrapper.element).toMatchSnapshot();
  });

  it('renders value and title slots that override props', () => {
    createComponent(null, { title: '<h1>tanuki</h1>', value: '<marquee>party</marquee>' });

    expect(wrapper.element).toMatchSnapshot();
  });

  it('renders an inflexible variant', () => {
    createComponent({ isFlexible: false });

    expect(wrapper.element).toMatchSnapshot();
  });
});
