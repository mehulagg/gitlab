import { mount, createLocalVue } from '@vue/test-utils';
import VueRouter from 'vue-router';
import App from 'ee/design_management/components/app.vue';
import Designs from 'ee/design_management/pages/index.vue';
import DesignDetail from 'ee/design_management/pages/design/index.vue';
import createRouter from 'ee/design_management/router';
import '~/commons/bootstrap';

jest.mock('mousetrap', () => ({
  bind: jest.fn(),
  unbind: jest.fn(),
}));

describe('Design management router', () => {
  let vm;
  let router;

  function factory() {
    const localVue = createLocalVue();

    localVue.use(VueRouter);

    window.gon = { sprite_icons: '' };

    router = createRouter('/');

    vm = mount(App, {
      sync: false,
      localVue,
      router,

      mocks: {
        $apollo: {
          queries: {
            designs: { loading: true },
            design: { loading: true },
            permissions: { loading: true },
          },
        },
      },
    });
  }

  beforeEach(() => {
    factory();
  });

  afterEach(() => {
    vm.destroy();

    router.app.$destroy();
    window.location.hash = '';
  });

  describe('root', () => {
    it('pushes home component', () => {
      router.push('/');

      expect(vm.find(Designs).exists()).toBe(true);
    });
  });

  describe('designs', () => {
    it('pushes designs root component', () => {
      router.push('/designs');

      expect(vm.find(Designs).exists()).toBe(true);
    });
  });

  describe('designs detail', () => {
    it('pushes designs detail component', () => {
      router.push('/designs/1');

      return vm.vm.$nextTick().then(() => {
        const detail = vm.find(DesignDetail);
        expect(detail.exists()).toBe(true);
        expect(detail.props('id')).toEqual('1');
      });
    });
  });
});
