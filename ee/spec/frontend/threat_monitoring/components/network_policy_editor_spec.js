import { shallowMount } from '@vue/test-utils';
import NetworkPolicyEditor from 'ee/threat_monitoring/components/network_policy_editor.vue';

describe('NetworkPolicyEditor component', () => {
  let wrapper;

  const factory = ({ propsData } = {}) => {
    wrapper = shallowMount(NetworkPolicyEditor, {
      propsData: {
        value: 'foo',
        ...propsData,
      },
    });
  };

  beforeEach(() => {
    factory();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('renders container element', () => {
    expect(wrapper.find({ ref: 'editor' }).exists()).toBe(true);
  });

  it('initializes monaco editor with yaml language and provided value', () => {
    const {
      vm: { editor },
    } = wrapper;
    expect(editor).not.toBe(null);
    expect(editor.getModel().getModeId()).toBe('yaml');
    expect(editor.getValue()).toBe('foo');
  });

  it('emits input event on file changes', () => {
    wrapper.vm.editor.setValue('bar');
    expect(wrapper.emitted().input).toBeTruthy();
    expect(wrapper.emitted().input.length).toBe(1);
    expect(wrapper.emitted().input[0]).toEqual(['bar']);
  });
});
