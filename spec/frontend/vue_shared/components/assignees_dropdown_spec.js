import { mount } from '@vue/test-utils';
import AssigneesDropdown from '~/vue_shared/components/sidebar/assignees_dropdown.vue';

describe('AssigneesDropdown Component', () => {
  let wrapper;

  const createComponent = options => {
    wrapper = mount(AssigneesDropdown, {
      ...options,
      slots: {
        items: '<p data-test-id="slot">Test</p>',
      },
    });
  };
  const findGlDropdown = () => wrapper.find('[data-test-id="dropdown"]');
  const findGlDropdownForm = () => wrapper.find('[data-test-id="dropdown-form"]');

  beforeEach(() => {
    createComponent({
      propsData: {
        text: '',
        headerText: '',
      },
    });
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('renders GlDropdown', () => {
    expect(findGlDropdown().exists()).toBe(true);
  });

  it('renders GlDropdownForm', () => {
    expect(findGlDropdownForm().exists()).toEqual(true);
  });

  it('renders items slot', () => {
    expect(wrapper.find('[data-test-id="slot"]').text()).toEqual('Test');
  });
});
