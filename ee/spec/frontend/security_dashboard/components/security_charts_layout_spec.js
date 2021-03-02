import { shallowMount } from '@vue/test-utils';
import SecurityChartsLayout from 'ee/security_dashboard/components/security_charts_layout.vue';

describe('Security Charts Layout component', () => {
  let wrapper;

  const DummyComponent = {
    name: 'dummy-component-1',
    template: '<p>dummy component 1</p>',
  };

  const findComponent = () => wrapper.find(DummyComponent);
  const findTitle = () => wrapper.find(`[data-testid="title"]`);

  const createWrapper = (slots) => {
    wrapper = shallowMount(SecurityChartsLayout, { slots });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('should render the default slot', () => {
    createWrapper({ default: DummyComponent });

    expect(findComponent().find(DummyComponent).exists()).toBe(true);
    expect(findTitle().exists()).toBe(true);
  });

  it('should render the empty-state slot', () => {
    createWrapper({ 'empty-state': DummyComponent });

    expect(findComponent().find(DummyComponent).exists()).toBe(true);
    expect(findTitle().exists()).toBe(false);
  });

  it('should render the loading slot', () => {
    createWrapper({ loading: DummyComponent });

    expect(findComponent().find(DummyComponent).exists()).toBe(true);
    expect(findTitle().exists()).toBe(false);
  });
});
