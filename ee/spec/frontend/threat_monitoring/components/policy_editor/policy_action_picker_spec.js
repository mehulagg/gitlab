import { shallowMount } from '@vue/test-utils';
import PolicyActionPicker from 'ee/threat_monitoring/components/policy_editor/policy_action_picker.vue';

describe('PolicyActionPicker component', () => {
  let wrapper;

  const factory = ({ propsData } = {}) => {
    wrapper = shallowMount(PolicyActionPicker, {
      propsData: {
        ...propsData,
      },
    });
  };

  beforeEach(() => {
    factory();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders policy action picker', () => {
    expect(wrapper.element).toMatchSnapshot();
  });
});
