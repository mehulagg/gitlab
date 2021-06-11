import { shallowMount } from '@vue/test-utils';
import PolicyYamlEditor from 'ee/threat_monitoring/components/policy_yaml_editor.vue';
import EditorLite from '~/vue_shared/components/editor_lite.vue';

describe('PolicyYamlEditor component', () => {
  let wrapper;

  const findEditor = () => wrapper.findComponent(EditorLite);

  const factory = ({ propsData } = {}) => {
    wrapper = shallowMount(PolicyYamlEditor, {
      propsData: {
        value: 'foo',
        ...propsData,
      },
      stubs: {
        EditorLite,
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
    expect(findEditor().exists()).toBe(true);
  });

  it('initializes monaco editor with yaml language and provided value', () => {
    const editorComponent = findEditor();
    expect(editorComponent.props('value')).toBe('foo');
    const editor = editorComponent.vm.getEditor();
    expect(editor.getModel().getModeId()).toBe('yaml');
  });

  it("emits input event on editor's input", async () => {
    const editor = findEditor();
    editor.vm.$emit('input');
    await wrapper.vm.$nextTick();
    expect(wrapper.emitted().input).toBeTruthy();
  });
});
