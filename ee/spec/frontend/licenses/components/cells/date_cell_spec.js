import { shallowMount } from '@vue/test-utils';
import { DateCell } from 'ee/licenses/components/cells';

describe('DateCell', () => {
  let wrapper;
  const defaultProps = {
    title: 'title',
    value: '2018/10/24',
  };

  function createComponent(props) {
    const propsData = Object.assign({}, defaultProps, props);

    wrapper = shallowMount(DateCell, {
      sync: false,
      propsData,
    });
  }

  afterEach(() => {
    if (wrapper) wrapper.destroy();
  });

  it('renders a string value that represents a date in words and title through props', () => {
    createComponent();

    expect(wrapper.element).toMatchSnapshot();
  });

  it('renders a date value that represents a date in words and title through props', () => {
    createComponent({ value: new Date('2018/03/06') });

    expect(wrapper.element).toMatchSnapshot();
  });

  it('renders an expired warning if isExpirable and date value is before now', () => {
    createComponent({ isExpirable: true });

    expect(wrapper.element).toMatchSnapshot();
  });

  it('renders date value with no warning if isExpirable and date value is after now', () => {
    createComponent({ isExpirable: true, dateNow: new Date('2017/10/10') });

    expect(wrapper.element).toMatchSnapshot();
  });

  it('renders a fallback value if isExpirable and no value', () => {
    createComponent({ isExpirable: true, value: undefined });

    expect(wrapper.element).toMatchSnapshot();
  });
});
