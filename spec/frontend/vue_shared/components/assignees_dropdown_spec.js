import { shallowMount } from '@vue/test-utils';
import AssigneesDropdown from '~/vue_shared/components/sidebar/assignees_dropdown.vue';

describe('AssigneesDropdown Component', () => {
  let wrapper;

  const createComponent = options => {
    wrapper = shallowMount(AssigneesDropdown, {
      ...options,
    });
  };
  const findGlDropdown = () => {};

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('renders GlDropdown', () => {
    createComponent({
      propsData: {
        text: '',
        headerText: '',
      },
    });

    expect(wrapper.element.tagName).toEqual('DIV');
  });
});
