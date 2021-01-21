import { GlModal } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import NetworkPolicyEditor from 'ee/threat_monitoring/components/network_policy_editor.vue';
import {
  RuleDirectionInbound,
  PortMatchModeAny,
  RuleTypeEndpoint,
  EditorModeYAML,
  EndpointMatchModeLabel,
} from 'ee/threat_monitoring/components/policy_editor/constants';
import fromYaml from 'ee/threat_monitoring/components/policy_editor/lib/from_yaml';
import { buildRule } from 'ee/threat_monitoring/components/policy_editor/lib/rules';
import toYaml from 'ee/threat_monitoring/components/policy_editor/lib/to_yaml';
import PolicyEditorApp from 'ee/threat_monitoring/components/policy_editor/policy_editor.vue';
import PolicyPreview from 'ee/threat_monitoring/components/policy_editor/policy_preview.vue';
import PolicyRuleBuilder from 'ee/threat_monitoring/components/policy_editor/policy_rule_builder.vue';
import PolicyAlertPicker from 'ee/threat_monitoring/components/policy_editor/policy_alert_picker.vue';
import createStore from 'ee/threat_monitoring/store';
import { redirectTo } from '~/lib/utils/url_utility';

jest.mock('~/lib/utils/url_utility');

describe('PolicyEditorApp component', () => {
  let store;
  let wrapper;

  const factory = ({ propsData, provide = {}, state, data } = {}) => {
    store = createStore();
    Object.assign(store.state.threatMonitoring, {
      ...state,
    });
    Object.assign(store.state.networkPolicies, {
      ...state,
    });

    jest.spyOn(store, 'dispatch').mockImplementation(() => Promise.resolve());

    wrapper = shallowMount(PolicyEditorApp, {
      propsData: {
        threatMonitoringPath: '/threat-monitoring',
        ...propsData,
      },
      provide: {
        glFeatures: { threatMonitoringAlerts: false },
        ...provide,
      },
      store,
      data,
    });
  };

  const findRuleEditor = () => wrapper.find('[data-testid="rule-editor"]');
  const findYamlEditor = () => wrapper.find('[data-testid="yaml-editor"]');
  const findPreview = () => wrapper.find(PolicyPreview);
  const findAddRuleButton = () => wrapper.find('[data-testid="add-rule"]');
  const findYAMLParsingAlert = () => wrapper.find('[data-testid="parsing-alert"]');
  const findNetworkPolicyEditor = () => wrapper.find(NetworkPolicyEditor);
  const findPolicyAlertPicker = () => wrapper.find(PolicyAlertPicker);
  const findPolicyName = () => wrapper.find("[id='policyName']");
  const findSavePolicy = () => wrapper.find("[data-testid='save-policy']");
  const findDeletePolicy = () => wrapper.find("[data-testid='delete-policy']");
  const findEditorModeToggle = () => wrapper.find("[data-testid='editor-mode']");

  const modifyPolicyAlert = async ({ isAlertEnabled }) => {
    const policyAlertPicker = findPolicyAlertPicker();
    policyAlertPicker.vm.$emit('update-alert', isAlertEnabled);
    await wrapper.vm.$nextTick();
    expect(policyAlertPicker.props('policyAlert')).toBe(isAlertEnabled);
    findSavePolicy().vm.$emit('click');
    await wrapper.vm.$nextTick();
  };

  beforeEach(() => {
    factory();
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

  it('does not render parsing error alert', () => {
    expect(findYAMLParsingAlert().exists()).toBe(false);
  });

  it('does not render delete button', () => {
    expect(findDeletePolicy().exists()).toBe(false);
  });

  it('does not render the policy alert picker', () => {
    expect(findPolicyAlertPicker().exists()).toBe(false);
  });

  describe('given .yaml editor mode is enabled', () => {
    beforeEach(() => {
      factory({
        data: () => ({
          editorMode: EditorModeYAML,
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

    it('updates policy on yaml editor value change', async () => {
      const manifest = `apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
description: test description
metadata:
  name: test-policy
spec:
  endpointSelector:
    matchLabels:
      network-policy.gitlab.com/disabled_by: gitlab
      foo: bar
  ingress:
  - fromEndpoints:
    - matchLabels:
        foo: bar`;
      findNetworkPolicyEditor().vm.$emit('input', manifest);

      expect(wrapper.vm.policy).toMatchObject({
        name: 'test-policy',
        description: 'test description',
        isEnabled: false,
        endpointMatchMode: EndpointMatchModeLabel,
        endpointLabels: 'foo:bar',
        rules: [
          {
            ruleType: RuleTypeEndpoint,
            matchLabels: 'foo:bar',
          },
        ],
      });
    });
  });

  describe('given there is a name change', () => {
    let initialValue;

    beforeEach(() => {
      initialValue = findPreview().props('policyYaml');
      findPolicyName().vm.$emit('input', 'new');
    });

    it('updates policy yaml preview', () => {
      expect(findPreview().props('policyYaml')).not.toEqual(initialValue);
    });
  });

  describe('given there is a rule change', () => {
    let initialValue;

    beforeEach(() => {
      initialValue = findPreview().props('policyDescription');
      wrapper.find("[data-testid='add-rule']").vm.$emit('click');
    });

    it('updates policy description preview', () => {
      expect(findPreview().props('policyDescription')).not.toEqual(initialValue);
    });
  });

  it('adds a new rule', async () => {
    expect(wrapper.findAll(PolicyRuleBuilder).length).toEqual(0);
    const button = findAddRuleButton();
    button.vm.$emit('click');
    button.vm.$emit('click');
    await wrapper.vm.$nextTick();
    const elements = wrapper.findAll(PolicyRuleBuilder);
    expect(elements.length).toEqual(2);

    elements.wrappers.forEach((builder, idx) => {
      expect(builder.props().rule).toMatchObject({
        ruleType: RuleTypeEndpoint,
        direction: RuleDirectionInbound,
        matchLabels: '',
        portMatchMode: PortMatchModeAny,
        ports: '',
      });
      expect(builder.props().endpointSelectorDisabled).toEqual(idx !== 0);
    });
  });

  it('removes a new rule', async () => {
    findAddRuleButton().vm.$emit('click');
    await wrapper.vm.$nextTick();
    expect(wrapper.findAll(PolicyRuleBuilder).length).toEqual(1);

    wrapper.find(PolicyRuleBuilder).vm.$emit('remove');
    await wrapper.vm.$nextTick();
    expect(wrapper.findAll(PolicyRuleBuilder).length).toEqual(0);
  });

  it('updates yaml editor value on switch to yaml editor', async () => {
    findPolicyName().vm.$emit('input', 'test-policy');
    findEditorModeToggle().vm.$emit('input', EditorModeYAML);
    await wrapper.vm.$nextTick();

    const editor = findNetworkPolicyEditor();
    expect(editor.exists()).toBe(true);
    expect(fromYaml(editor.props('value'))).toMatchObject({
      name: 'test-policy',
    });
  });

  describe('given there is a yaml parsing error', () => {
    beforeEach(() => {
      factory({
        data: () => ({
          yamlEditorError: {},
        }),
      });
    });

    it('renders parsing error alert', () => {
      expect(findYAMLParsingAlert().exists()).toBe(true);
    });

    it('disables rule builder', () => {
      expect(wrapper.find("[data-testid='rule-builder-container']").props().disabled).toBe(true);
    });

    it('disables action picker', () => {
      expect(wrapper.find("[data-testid='policy-action-container']").props().disabled).toBe(true);
    });

    it('disables policy preview', () => {
      expect(wrapper.find("[data-testid='policy-preview-container']").props().disabled).toBe(true);
    });

    it('does not update yaml editor value on switch to yaml editor', async () => {
      findPolicyName().vm.$emit('input', 'test-policy');
      findEditorModeToggle().vm.$emit('input', EditorModeYAML);
      await wrapper.vm.$nextTick();

      const editor = findNetworkPolicyEditor();
      expect(editor.exists()).toBe(true);
      expect(editor.props('value')).toEqual('');
    });
  });

  it('creates policy and redirects to a threat monitoring path', async () => {
    findSavePolicy().vm.$emit('click');

    await wrapper.vm.$nextTick();
    expect(store.dispatch).toHaveBeenCalledWith('networkPolicies/createPolicy', {
      environmentId: -1,
      policy: { manifest: toYaml(wrapper.vm.policy) },
    });
    expect(redirectTo).toHaveBeenCalledWith('/threat-monitoring');
  });

  describe('given there is a createPolicy error', () => {
    beforeEach(() => {
      factory({
        state: {
          errorUpdatingPolicy: true,
        },
      });
    });

    it('it does not redirect', async () => {
      findSavePolicy().vm.$emit('click');

      await wrapper.vm.$nextTick();
      expect(redirectTo).not.toHaveBeenCalledWith('/threat-monitoring');
    });
  });

  describe('given existingPolicy property was provided', () => {
    const manifest = toYaml({
      name: 'policy',
      endpointLabels: '',
      rules: [buildRule()],
    });

    beforeEach(() => {
      factory({
        propsData: {
          existingPolicy: { name: 'policy', manifest },
        },
      });
    });

    it('presents existing policy', () => {
      expect(findPolicyName().attributes().value).toEqual('policy');
      expect(wrapper.findAll(PolicyRuleBuilder).length).toEqual(1);
    });

    it('updates existing policy and redirects to a threat monitoring path', async () => {
      const saveButton = findSavePolicy();
      expect(saveButton.text()).toEqual('Save changes');
      saveButton.vm.$emit('click');

      await wrapper.vm.$nextTick();
      expect(store.dispatch).toHaveBeenCalledWith('networkPolicies/updatePolicy', {
        environmentId: -1,
        policy: { name: 'policy', manifest: toYaml(wrapper.vm.policy) },
      });
      expect(redirectTo).toHaveBeenCalledWith('/threat-monitoring');
    });

    describe('given there is a updatePolicy error', () => {
      beforeEach(() => {
        factory({
          propsData: {
            existingPolicy: { name: 'policy', manifest },
          },
          state: {
            errorUpdatingPolicy: true,
          },
        });
      });

      it('it does not redirect', async () => {
        findSavePolicy().vm.$emit('click');

        await wrapper.vm.$nextTick();
        expect(redirectTo).not.toHaveBeenCalledWith('/threat-monitoring');
      });
    });

    it('renders delete button', () => {
      expect(findDeletePolicy().exists()).toBe(true);
    });

    it('it does not trigger deletePolicy on delete button click', async () => {
      findDeletePolicy().vm.$emit('click');
      await wrapper.vm.$nextTick();

      expect(store.dispatch).not.toHaveBeenCalledWith('networkPolicies/deletePolicy');
    });

    it('removes policy and redirects to a threat monitoring path on secondary modal button click', async () => {
      wrapper.find(GlModal).vm.$emit('secondary');
      await wrapper.vm.$nextTick();

      expect(store.dispatch).toHaveBeenCalledWith('networkPolicies/deletePolicy', {
        environmentId: -1,
        policy: { name: 'policy', manifest: toYaml(wrapper.vm.policy) },
      });
      expect(redirectTo).toHaveBeenCalledWith('/threat-monitoring');
    });
  });

  describe('add alert picker', () => {
    beforeEach(() => {
      factory({ provide: { glFeatures: { threatMonitoringAlerts: true } } });
    });

    it('does render the policy alert picker', () => {
      expect(findPolicyAlertPicker().exists()).toBe(true);
    });

    it('adds a policy annotation on alert addition', async () => {
      await modifyPolicyAlert({ isAlertEnabled: true });
      expect(store.dispatch).toHaveBeenLastCalledWith('networkPolicies/createPolicy', {
        environmentId: -1,
        policy: {
          manifest: expect.stringContaining("app.gitlab.com/alert: 'true'"),
        },
      });
    });

    it('removes a policy annotation on alert removal', async () => {
      await modifyPolicyAlert({ isAlertEnabled: false });
      expect(store.dispatch).toHaveBeenLastCalledWith('networkPolicies/createPolicy', {
        environmentId: -1,
        policy: {
          manifest: expect.not.stringContaining("app.gitlab.com/alert: 'true'"),
        },
      });
    });
  });
});
