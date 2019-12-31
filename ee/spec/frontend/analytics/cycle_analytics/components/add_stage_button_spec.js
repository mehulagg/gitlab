import { shallowMount } from '@vue/test-utils';
import AddStageButton from 'ee/analytics/cycle_analytics/components/add_stage_button.vue';

describe('AddStageButton', () => {
  const active = false;

  function createComponent(props) {
    return shallowMount(AddStageButton, {
      propsData: {
        active,
        ...props,
      },
    });
  }

  let wrapper = null;

  afterEach(() => {
    wrapper.destroy();
  });

  describe('is not active', () => {
    beforeEach(() => {
      wrapper = createComponent();
    });
    it('emits the `showform` event when clicked', () => {
      wrapper = createComponent();
      expect(wrapper.emitted().showform).toBeUndefined();
      wrapper.trigger('click');
      return wrapper.vm.$nextTick().then(() => {
        expect(wrapper.emitted().showform.length).toBe(1);
      });
    });

    it('does not have the active class', () => {
      expect(wrapper.classes('active')).toBe(false);
    });
  });

  describe('is active', () => {
    it('has the active class when active=true', () => {
      wrapper = createComponent({ active: true });
      expect(wrapper.classes('active')).toBe(true);
    });
  });
});
