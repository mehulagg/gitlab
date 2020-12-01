import { shallowMount } from '@vue/test-utils';
import DimDisableContainer from 'ee/threat_monitoring/components/policy_editor/dim_disable_container.vue';

describe('DimDisableContainer component', () => {
  let wrapper;

  const factory = ({ propsData } = {}) => {
    wrapper = shallowMount(DimDisableContainer, {
      propsData: {
        ...propsData,
      },
      slots: {
        default: '<main>Item</main>',
        title: '<h1>Title</h1>',
        disabled: '<span>Disabled</span>',
      },
    });
  };

  beforeEach(() => {
    factory();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders title slot component', () => {
    expect(wrapper.contains('h1')).toBe(true);
  });

  it('renders default slot component', () => {
    expect(wrapper.contains('main')).toBe(true);
  });

  it('does not render disabled slot component', () => {
    expect(wrapper.contains('span')).toBe(false);
  });

  it('does not render dim overlay', () => {
    expect(wrapper.contains("[data-testid='overlay']")).toBe(false);
  });

  describe('give disabled is true', () => {
    beforeEach(() => {
      factory({
        propsData: {
          disabled: true,
        },
      });
    });

    it('renders title slot component', () => {
      expect(wrapper.contains('h1')).toBe(true);
    });

    it('does not render default slot component', () => {
      expect(wrapper.contains('main')).toBe(false);
    });

    it('renders disabled slot component', () => {
      expect(wrapper.contains('span')).toBe(true);
    });

    it('renders dim overlay', () => {
      expect(wrapper.contains("[data-testid='overlay']")).toBe(true);
    });
  });
});
