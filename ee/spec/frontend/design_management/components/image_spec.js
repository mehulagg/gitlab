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
    wrapper.vm.$nextTick(() => {
      expect(wrapper.element).toMatchSnapshot();
    });
  });

  describe('resetImageSize', () => {
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

    it('sets correct classes and styles', () => {
      wrapper.vm.resetImageSize();
      wrapper.vm.$nextTick(() => {
        expect(wrapper.element).toMatchSnapshot();
      });
    });

    it('emits @resize event with correct payload', () => {
      jest.spyOn(wrapper.vm.$refs.contentImg, 'offsetWidth', 'get').mockReturnValue(200);
      jest.spyOn(wrapper.vm.$refs.contentImg, 'offsetHeight', 'get').mockReturnValue(200);

      wrapper.vm.resetImageSize();

      expect(wrapper.vm.imageStyle).toBeNull();
      wrapper.vm.$nextTick(() => {
        expect(wrapper.vm.baseImageSize).toEqual({ width: 200, height: 200 });
        expect(wrapper.emitted('resize')).toEqual([[{ width: 200, height: 200 }]]);
      });
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

      wrapper.vm.$nextTick(() => {
        expect(wrapper.emitted('resize')).toEqual([[{ width: 200, height: 200 }]]);
      });
    });
  });
});
