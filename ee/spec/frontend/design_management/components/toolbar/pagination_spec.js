import { shallowMount } from '@vue/test-utils';
import Pagination from 'ee/design_management/components/toolbar/pagination.vue';

describe('Design management pagination component', () => {
  let wrapper;

  function createComponent() {
    wrapper = shallowMount(Pagination, {
      propsData: {
        id: '2',
      },
    });
  }

  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('hides components when designs are empty', () => {
    expect(wrapper.element).toMatchSnapshot();
  });

  it('renders pagination buttons', () => {
    wrapper.setData({
      designs: [{ id: '1' }, { id: '2' }],
    });

    return wrapper.vm.$nextTick().then(() => {
      expect(wrapper.element).toMatchSnapshot();
    });
  });
});
