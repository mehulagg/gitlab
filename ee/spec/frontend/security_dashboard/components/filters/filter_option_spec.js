import { GlTruncate, GlIcon } from '@gitlab/ui';
import FilterOption from 'ee/security_dashboard/components/filters/filter_option.vue';
import { shallowMount } from '@vue/test-utils';

describe('FilterOption component', () => {
  let wrapper;

  const defaultProps = {
    displayName: 'display name',
    isSelected: false,
  };

  const createWrapper = props => {
    wrapper = shallowMount(FilterOption, { propsData: { ...defaultProps, ...props } });
  };

  const displayName = () => wrapper.find(GlTruncate);
  const checkmarkIcon = () => wrapper.find(GlIcon);

  afterEach(() => {
    wrapper.destroy();
  });

  it('shows the display name', () => {
    createWrapper();
    expect(displayName().props('text')).toBe(defaultProps.displayName);
  });

  it.each([true, false])('shows the expected checkmark when isSelected is %s', isSelected => {
    createWrapper({ isSelected });
    expect(checkmarkIcon().exists()).toBe(isSelected);
  });

  it('emits click event when clicked', () => {
    createWrapper();
    wrapper.find('a').element.click();

    expect(wrapper.emitted('click')).toHaveLength(1);
  });
});
