import { shallowMount } from '@vue/test-utils';
import { GlDropdownItem } from '@gitlab/ui';
import DateRangeDropdown from 'ee/analytics/shared/components/date_range_dropdown.vue';

describe('DateRangeDropdown component', () => {
  let wrapper;
  const defaultProps = {
    availableDaysInPast: [7, 14, 30],
  };

  function createComponent(props = {}) {
    const propsData = {
      ...defaultProps,
      ...props,
    };

    wrapper = shallowMount(DateRangeDropdown, {
      propsData,
    });
  }

  beforeEach(() => {
    createComponent();
  });

  const findDropdownElements = () => wrapper.findAll(GlDropdownItem);
  const findFirstDropdownElement = () => findDropdownElements().at(0);

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders 3 dropdown items', () => {
    expect(findDropdownElements().length).toBe(3);
  });

  it('displays the correct label for the first dropdown item', () => {
    expect(findFirstDropdownElement().text()).toBe('Last 7 days');
  });

  it('emits the "selected" event with the selected item value', () => {
    findFirstDropdownElement().vm.$emit('click');

    return wrapper.vm.$nextTick().then(() => {
      expect(wrapper.emitted().selected[0]).toEqual([7]);
    });
  });

  it('it renders the correct dropdown text when no item is selected', () => {
    expect(wrapper.vm.dropdownText).toBe('Select timeframe');
  });

  it('it renders the correct dropdown text when defaultSelected is set', () => {
    createComponent({ defaultSelected: 14 });
    expect(wrapper.vm.dropdownText).toBe('Last 14 days');
  });

  it('it renders the correct dropdown text when an item is selected', () => {
    findFirstDropdownElement().vm.$emit('click');
    expect(wrapper.vm.dropdownText).toBe('Last 7 days');
  });
});
