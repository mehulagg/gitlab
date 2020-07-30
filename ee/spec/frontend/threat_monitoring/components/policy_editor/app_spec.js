import { shallowMount } from '@vue/test-utils';
import PolicyEditorApp from 'ee/threat_monitoring/components/policy_editor/app.vue';
import PolicyRuleBuilder from 'ee/threat_monitoring/components/policy_editor/policy_rule_builder.vue';
import createStore from 'ee/threat_monitoring/store';

describe('PolicyEditorApp component', () => {
  let store;
  let wrapper;

  const factory = ({ propsData, state, data } = {}) => {
    store = createStore();
    Object.assign(store.state.threatMonitoring, {
      ...state,
    });

    wrapper = shallowMount(PolicyEditorApp, {
      propsData: {
        ...propsData,
      },
      store,
      data,
    });
  };

  const findRuleEditor = () => wrapper.find('[data-testid="rule-editor"]');
  const findYamlEditor = () => wrapper.find('[data-testid="yaml-editor"]');
  const findPreview = () => wrapper.find('[data-testid="policy-preview"]');

  beforeEach(() => {
    factory({});
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('renders the policy editor layout', () => {
    expect(wrapper.find('section').element).toMatchSnapshot();
  });

  it('does not render yaml editor', () => {
    expect(findYamlEditor().exists()).toBe(false);
  });

  describe('given .yaml editor mode is enabled', () => {
    beforeEach(() => {
      factory({
        data: () => ({
          editorMode: 'yaml',
        }),
      });
    });

    it('does not render rule editor', () => {
      expect(findRuleEditor().exists()).toBe(false);
    });

    it('renders yaml editor', () => {
      const editor = findYamlEditor();
      expect(editor.exists()).toBe(true);
      expect(editor.element).toMatchSnapshot();
    });
  });

  describe('given there is a name change', () => {
    let initialValue;

    beforeEach(() => {
      initialValue = findPreview().props('policyYaml');
      wrapper.find("[id='policyName']").vm.$emit('input', 'new');
    });

    it('updates policy preview', () => {
      expect(findPreview().props('policyYaml')).not.toEqual(initialValue);
    });
  });

  describe('given there is a description change', () => {
    let initialValue;

    beforeEach(() => {
      initialValue = findPreview().props('policyYaml');
      wrapper.find("[id='policyDescription']").vm.$emit('input', 'new');
    });

    it('updates policy preview', () => {
      expect(findPreview().props('policyYaml')).not.toEqual(initialValue);
    });
  });

  describe('given there is an enforcement status change', () => {
    let initialValue;

    beforeEach(() => {
      initialValue = findPreview().props('policyYaml');
      wrapper.find("[id='policyStatus']").vm.$emit('change', true);
    });

    it('updates policy preview', () => {
      expect(findPreview().props('policyYaml')).not.toEqual(initialValue);
    });
  });

  it('adds a new rule', () => {
    expect(wrapper.findAll(PolicyRuleBuilder).length).toEqual(0);
    const button = wrapper.find("[data-testid='add-rule']");
    button.vm.$emit('click');
    button.vm.$emit('click');
    return wrapper.vm.$nextTick().then(() => {
      const elements = wrapper.findAll(PolicyRuleBuilder);
      expect(elements.length).toEqual(2);

      const builder1 = elements.at(0);
      expect(builder1.props().ruleIndex).toEqual(0);
      expect(builder1.props().endpointSelectorDisabled).toEqual(false);

      const builder2 = elements.at(1);
      expect(builder2.props().ruleIndex).toEqual(1);
      expect(builder2.props().endpointSelectorDisabled).toEqual(true);
    });
  });
});
