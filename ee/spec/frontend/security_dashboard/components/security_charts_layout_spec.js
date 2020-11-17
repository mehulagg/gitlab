import { shallowMount } from '@vue/test-utils';
import SecurityChartsLayout from 'ee/security_dashboard/components/security_charts_layout.vue';

describe('Security Charts Layout component', () => {
  let wrapper;

  const DummyComponent1 = {
    name: 'dummy-component-1',
    template: '<p>dummy component 1</p>',
  };
  const DummyComponent2 = {
    name: 'dummy-component-2',
    template: '<p>dummy component 2</p>',
  };

  const findSlot = () => wrapper.find(`[data-testid="security-charts-layout"]`);

  const createWrapper = slots => {
    wrapper = shallowMount(SecurityChartsLayout, { slots });
  };

  beforeEach(() => {
    createWrapper({ default: DummyComponent1, 'empty-state': DummyComponent2 });
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('should render the default slot', () => {
    const slot = findSlot();
    expect(slot.find(DummyComponent1).exists()).toBe(true);
  });

  it('should render the empty-state slot', () => {
    const slot = findSlot();
    expect(slot.find(DummyComponent2).exists()).toBe(true);
  });
});
