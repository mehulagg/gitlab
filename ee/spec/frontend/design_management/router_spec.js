import { mount, createLocalVue } from '@vue/test-utils';
import VueRouter from 'vue-router';
import App from 'ee/design_management/components/app.vue';
import Designs from 'ee/design_management/pages/index.vue';
import DesignDetail from 'ee/design_management/pages/design/index.vue';
import router from 'ee/design_management/router';
import '~/commons/bootstrap';

describe('Design management router', () => {
  let vm;

  function factory() {
    const localVue = createLocalVue();

    localVue.use(VueRouter);

    vm = mount(App, {
      localVue,
      router,
      mocks: {
        $apollo: {
          queries: { designs: { loading: true } },
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
    it('pushes empty component', () => {
      router.push('/');

      expect(vm.isEmpty()).toBe(true);
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

      const detail = vm.find(DesignDetail);

      expect(detail.exists()).toBe(true);
      expect(detail.props('id')).toEqual(1);
    });
  });
});
