import { createWrapper } from '@vue/test-utils';

import initBuyMinutesApp from 'ee/subscriptions/buy_minutes';
import StepOrderApp from 'ee/vue_shared/purchase_flow/components/step_order_app.vue';

describe('initBuyMinutesApp', () => {
  let vm;
  let wrapper;

  function createComponent() {
    const el = document.createElement('div');
    Object.assign(el.dataset, { groupData: '[]' });
    vm = initBuyMinutesApp(el).$mount();
    wrapper = createWrapper(vm);
  }

  afterEach(() => {
    if (vm) {
      vm.$destroy();
    }
    wrapper.destroy();
    vm = null;
  });

  it('displays the StepOrderApp', () => {
    createComponent();
    expect(wrapper.find(StepOrderApp).exists()).toBe(true);
  });
});
