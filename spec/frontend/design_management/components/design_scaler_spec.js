import { shallowMount, mount } from '@vue/test-utils';
import { GlButton } from '@gitlab/ui';
import DesignScaler from '~/design_management/components/design_scaler.vue';

describe('Design management design scaler component', () => {
  let wrapper;

  const getButtons = () => wrapper.findAll(GlButton);
  const getDecreaseScaleButton = () => getButtons().at(0);
  const getResetScaleButton = () => getButtons().at(1);
  const getIncreaseScaleButton = () => getButtons().at(2);

  const setScale = scale => wrapper.vm.setScale(scale);

  function createComponent({ propsData, mountFn = shallowMount } = {}) {
    wrapper = mountFn(DesignScaler, {
      propsData,
    });
  }

  const mountComponent = (args = {}) => createComponent({ ...args, mountFn: mount });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('when `scale` value is greater than 1', () => {
    beforeEach(async () => {
      mountComponent();

      setScale(1.6);
      await wrapper.vm.$nextTick();
    });

    it('emits @scale event when "reset" button clicked', () => {
      getResetScaleButton().trigger('click');
      expect(wrapper.emitted('scale')[1]).toEqual([1]);
    });

    it('emits @scale event when "decrement" button clicked', async () => {
      getDecreaseScaleButton().trigger('click');
      expect(wrapper.emitted('scale')[1]).toEqual([1.4]);
    });

    it('"reset" button is enabled', () => {
      const resetButton = getResetScaleButton();

      expect(resetButton.exists()).toBe(true);
      expect(resetButton.props('disabled')).toBe(false);
    });

    it('"decrement" button is enabled', () => {
      const decrementButton = getDecreaseScaleButton();

      expect(decrementButton.exists()).toBe(true);
      expect(decrementButton.props('disabled')).toBe(false);
    });
  });

  it('emits @scale event when "plus" button clicked', () => {
    mountComponent();

    getIncreaseScaleButton().trigger('click');
    expect(wrapper.emitted('scale')).toEqual([[1.2]]);
  });

  describe('when `scale` value is 1', () => {
    beforeEach(() => {
      createComponent();
    });

    it('"reset" button is disabled', () => {
      const resetButton = getResetScaleButton();

      expect(resetButton.exists()).toBe(true);
      expect(resetButton.props('disabled')).toBe(true);
    });

    it('"decrement" button is disabled', () => {
      const decrementButton = getDecreaseScaleButton();

      expect(decrementButton.exists()).toBe(true);
      expect(decrementButton.props('disabled')).toBe(true);
    });
  });

  describe('when `scale` value is 2 (maximum)', () => {
    beforeEach(async () => {
      mountComponent();

      setScale(2);
      await wrapper.vm.$nextTick();
    });

    it('"increment" button is disabled', () => {
      const incrementButton = getIncreaseScaleButton();

      expect(incrementButton.exists()).toBe(true);
      expect(incrementButton.props('disabled')).toBe(true);
    });
  });
});
