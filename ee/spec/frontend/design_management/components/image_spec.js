import { shallowMount } from '@vue/test-utils';
import DesignImage from 'ee/design_management/components/image.vue';

describe('Design management large image component', () => {
  let wrapper;

  function createComponent(propsData, data = {}) {
    wrapper = shallowMount(DesignImage, {
      propsData,
    });
    wrapper.setData(data);
  }

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders loading state', () => {
    createComponent({
      isLoading: true,
    });

    expect(wrapper.element).toMatchSnapshot();
  });

  it('renders image', () => {
    createComponent({
      isLoading: false,
      image: 'test.jpg',
      name: 'test',
    });

    expect(wrapper.element).toMatchSnapshot();
  });

  it('sets correct classes and styles if imageStyle is set', () => {
    createComponent(
      {
        isLoading: false,
        image: 'test.jpg',
        name: 'test',
      },
      {
        imageStyle: {
          width: '100px',
          height: '100px',
        },
      },
    );
    return wrapper.vm.$nextTick().then(() => {
      expect(wrapper.element).toMatchSnapshot();
    });
  });

  describe('zoom', () => {
    beforeEach(() => {
      createComponent(
        {
          isLoading: false,
          image: 'test.jpg',
          name: 'test',
        },
        {
          imageStyle: {
            width: '100px',
            height: '100px',
          },
          baseImageSize: {
            width: 100,
            height: 100,
          },
        },
      );
    });

    it('emits @resize event on zoom', () => {
      wrapper.vm.zoom(2);

      return wrapper.vm.$nextTick().then(() => {
        expect(wrapper.emitted('resize')).toEqual([[{ width: 200, height: 200 }]]);
      });
    });

    it('emits @resize event with base image size when scale=1', () => {
      wrapper.vm.zoom(1);

      return wrapper.vm.$nextTick().then(() => {
        expect(wrapper.emitted('resize')).toEqual([[{ width: 100, height: 100 }]]);
      });
    });

    it('sets image style when zoomed', () => {
      wrapper.vm.zoom(2);
      expect(wrapper.vm.imageStyle).toEqual({ width: '200px', height: '200px' });
      return wrapper.vm.$nextTick().then(() => {
        expect(wrapper.element).toMatchSnapshot();
      });
    });
  });
});
