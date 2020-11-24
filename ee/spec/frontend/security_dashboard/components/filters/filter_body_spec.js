import { GlDropdown, GlSearchBoxByType } from '@gitlab/ui';
import { mount } from '@vue/test-utils';
import FilterBody from 'ee/security_dashboard/components/filters/filter_body.vue';

describe('Filter Body component', () => {
  let wrapper;

  const defaultProps = {
    name: 'Some Name',
    selectedOptions: [],
  };

  const createComponent = (props, slotContent = '') => {
    wrapper = mount(FilterBody, {
      propsData: { ...defaultProps, ...props },
      slots: { default: slotContent },
    });
  };

  const dropdownButton = () => wrapper.find('.dropdown-toggle');
  const searchBox = () => wrapper.find(GlSearchBoxByType);

  afterEach(() => {
    wrapper.destroy();
  });

  it('shows the correct label name and dropdown header name', () => {
    createComponent();

    expect(wrapper.find('[data-testid="name"]').text()).toBe(defaultProps.name);
    expect(wrapper.find(GlDropdown).props('headerText')).toBe(defaultProps.name);
  });

  describe('dropdown button', () => {
    it('shows the selected option name if only one option is selected', () => {
      const option = { name: 'Some Selected Option' };
      const props = { selectedOptions: [option] };
      createComponent(props);

      expect(dropdownButton().text()).toBe(option.name);
    });

    it('shows the selected option name and "+x more" if more than one option is selected', () => {
      const options = [{ name: 'Option 1' }, { name: 'Option 2' }, { name: 'Option 3' }];
      const props = { selectedOptions: options };
      createComponent(props);

      expect(dropdownButton().text()).toMatchInterpolatedText('Option 1 +2 more');
    });
  });

  describe('search box', () => {
    it.each([true, false])('shows/hides search box when the showSearchBox prop is %s', show => {
      createComponent({ showSearchBox: show });

      expect(searchBox().exists()).toBe(show);
    });

    it('emits input event on component when search box input is changed', () => {
      const text = 'abc';
      createComponent({ showSearchBox: true });
      searchBox().vm.$emit('input', text);

      expect(wrapper.emitted('input')[0][0]).toBe(text);
    });
  });

  describe('dropdown body', () => {
    it('shows slot content', () => {
      const slotContent = 'some slot content';
      createComponent({}, slotContent);

      expect(wrapper.text()).toContain(slotContent);
    });

    it('shows no matching results text if there is no slot content', () => {
      createComponent();

      expect(wrapper.text()).toContain('No matching results');
    });
  });
});
