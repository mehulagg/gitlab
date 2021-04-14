import { GlDropdown, GlDropdownItem } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import { nextTick } from 'vue';
import ApprovalTypeSelect from 'ee/approvals/components/approver_type_select.vue';

jest.mock('lodash/uniqueId', () => (id) => `${id}mock`);

const OPTIONS = [
  { type: 'x', text: 'foo' },
  { type: 'y', text: 'bar' },
];

describe('ApprovalTypeSelect', () => {
  let wrapper;

  const findDropdown = () => wrapper.findComponent(GlDropdown);
  const findDropdownItems = () => wrapper.findAll(GlDropdownItem);

  const createComponent = () => {
    return shallowMount(ApprovalTypeSelect, {
      propsData: {
        approverTypeOptions: OPTIONS,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  beforeEach(() => {
    wrapper = createComponent();
  });

  it('should select the first option by default', () => {
    expect(findDropdownItems().at(0).props('isChecked')).toBe(true);
  });

  it('renders the dropdown with the selected text', () => {
    expect(findDropdown().props('text')).toBe(OPTIONS[0].text);
  });

  it('renders a dropdown item for each option', () => {
    OPTIONS.forEach((option, idx) => {
      expect(findDropdownItems().at(idx).text()).toBe(option.text);
    });
  });

  it('should select an item when clicked', async () => {
    const item = findDropdownItems().at(1);

    expect(item.props('isChecked')).toBe(false);

    item.vm.$emit('click');

    await nextTick();

    expect(item.props('isChecked')).toBe(true);
  });
});
