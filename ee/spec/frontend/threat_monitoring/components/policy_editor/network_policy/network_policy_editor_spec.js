import { GlModal, GlToggle } from '@gitlab/ui';
import { EditorModeYAML } from 'ee/threat_monitoring/components/policy_editor/constants';
import {
  RuleDirectionInbound,
  PortMatchModeAny,
  RuleTypeEndpoint,
  EndpointMatchModeLabel,
  fromYaml,
  buildRule,
  toYaml,
} from 'ee/threat_monitoring/components/policy_editor/network_policy/lib';
import NetworkPolicyEditor from 'ee/threat_monitoring/components/policy_editor/network_policy/network_policy_editor.vue';
import PolicyRuleBuilder from 'ee/threat_monitoring/components/policy_editor/network_policy/policy_rule_builder.vue';
import PolicyAlertPicker from 'ee/threat_monitoring/components/policy_editor/policy_alert_picker.vue';
import PolicyPreview from 'ee/threat_monitoring/components/policy_editor/policy_preview.vue';
import createStore from 'ee/threat_monitoring/store';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import { redirectTo } from '~/lib/utils/url_utility';

jest.mock('~/lib/utils/url_utility');

describe('NetworkPolicyEditor component', () => {
  let store;
  let wrapper;
  const l7manifest = `apiVersion: cilium.io/v2
  kind: CiliumNetworkPolicy
metadata:
  name: limit-inbound-ip
spec:
  endpointSelector: {}
  ingress:
  - toPorts:
    - ports:
      - port: '80'
        protocol: TCP
      - port: '443'
        protocol: TCP
      rules:
        http:
        - headers:
          - 'X-Forwarded-For: 192.168.1.1'
    fromEntities:
    - cluster`;

  const factory = ({ propsData, provide = {}, state, data } = {}) => {
    store = createStore();
    Object.assign(store.state.threatMonitoring, {
      ...state,
    });
    Object.assign(store.state.networkPolicies, {
      ...state,
    });

    jest.spyOn(store, 'dispatch').mockImplementation(() => Promise.resolve());

    wrapper = shallowMountExtended(NetworkPolicyEditor, {
      propsData: {
        threatMonitoringPath: '/threat-monitoring',
        projectId: '21',
        ...propsData,
      },
      provide: {
        ...provide,
      },
      store,
      data,
      stubs: { PolicyYamlEditor: true },
    });
  };

  const findRuleEditor = () => wrapper.findByTestId('rule-editor');
  const findPreview = () => wrapper.findComponent(PolicyPreview);
  const findAddRuleButton = () => wrapper.findByTestId('add-rule');
  const findYAMLParsingAlert = () => wrapper.findByTestId('parsing-alert');
  const findPolicyYamlEditor = () => wrapper.findByTestId('policy-yaml-editor');
  const findPolicyAlertPicker = () => wrapper.findComponent(PolicyAlertPicker);
  const findPolicyDescription = () => wrapper.find("[id='policyDescription']");
  const findPolicyEnableContainer = () => wrapper.findByTestId('policy-enable');
  const findPolicyName = () => wrapper.find("[id='policyName']");
  const findPolicyRuleBuilder = () => wrapper.findComponent(PolicyRuleBuilder);
  const findSavePolicy = () => wrapper.findByTestId('save-policy');
  const findDeletePolicy = () => wrapper.findByTestId('delete-policy');
  const findEditorModeToggle = () => wrapper.findByTestId('editor-mode');

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
  });

  it('renders toggle with label', () => {
    const policyEnableToggle = findPolicyEnableContainer().findComponent(GlToggle);
    expect(policyEnableToggle.exists()).toBe(true);
    expect(policyEnableToggle.props('label')).toBe(NetworkPolicyEditor.i18n.toggleLabel);
  });

  it('renders a default rule with label', () => {
    expect(wrapper.findAllComponents(PolicyRuleBuilder)).toHaveLength(1);
    expect(findPolicyRuleBuilder().exists()).toBe(true);
    expect(findPolicyRuleBuilder().attributes()).toMatchObject({
      endpointlabels: '',
      endpointmatchmode: 'any',
    });
  });

  it.each`
    component                | status                | findComponent            | state
    ${'policy alert picker'} | ${'does display'}     | ${findPolicyAlertPicker} | ${true}
    ${'editor mode toggle'}  | ${'does display'}     | ${findEditorModeToggle}  | ${true}
    ${'policy name input'}   | ${'does display'}     | ${findPolicyName}        | ${true}
    ${'rule editor'}         | ${'does display'}     | ${findRuleEditor}        | ${true}
    ${'add rule button'}     | ${'does display'}     | ${findAddRuleButton}     | ${true}
    ${'policy preview'}      | ${'does display'}     | ${findPreview}           | ${true}
    ${'yaml editor'}         | ${'does not display'} | ${findPolicyYamlEditor}  | ${false}
    ${'parsing error alert'} | ${'does not display'} | ${findYAMLParsingAlert}  | ${false}
    ${'delete button'}       | ${'does not display'} | ${findDeletePolicy}      | ${false}
  `('$status the $component', async ({ findComponent, state }) => {
    expect(findComponent().exists()).toBe(state);
  });

  describe('given .yaml editor mode is enabled', () => {
    beforeEach(() => {
      factory({
        data: () => ({
          editorMode: EditorModeYAML,
        }),
      });
    });

    it.each`
      component               | status                | findComponent           | state
      ${'editor mode toggle'} | ${'does display'}     | ${findEditorModeToggle} | ${true}
      ${'rule editor'}        | ${'does not display'} | ${findRuleEditor}       | ${false}
      ${'yaml editor'}        | ${'does display'}     | ${findPolicyYamlEditor} | ${true}
    `('$status the $component', ({ findComponent, state }) => {
      expect(findComponent().exists()).toBe(state);
    });

    it('updates policy on yaml editor value change', async () => {
      const manifest = `apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
description: test description
metadata:
  name: test-policy
  labels:
    app.gitlab.com/proj: '21'
spec:
  endpointSelector:
    matchLabels:
      network-policy.gitlab.com/disabled_by: gitlab
      foo: bar
  ingress:
  - fromEndpoints:
    - matchLabels:
        foo: bar`;
      findPolicyYamlEditor().vm.$emit('input', manifest);

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
        labels: { 'app.gitlab.com/proj': '21' },
      });
    });

    it('saves L7 policies', async () => {
      factory({
        data: () => ({
          editorMode: EditorModeYAML,
          yamlEditorValue: l7manifest,
        }),
      });
      findSavePolicy().vm.$emit('click');

      await wrapper.vm.$nextTick();
      expect(store.dispatch).toHaveBeenCalledWith('networkPolicies/createPolicy', {
        environmentId: -1,
        policy: { manifest: l7manifest },
      });
      expect(redirectTo).toHaveBeenCalledWith('/threat-monitoring');
    });
  });

  it('given there is a name change, updates policy yaml preview', async () => {
    const initialValue = findPreview().props('policyYaml');
    findPolicyName().vm.$emit('input', 'new');
    await wrapper.vm.$nextTick();
    expect(findPreview().props('policyYaml')).not.toEqual(initialValue);
  });

  it('given there is a rule change, updates policy description preview', async () => {
    const initialValue = findPreview().props('policyDescription');
    findAddRuleButton().vm.$emit('click');
    await wrapper.vm.$nextTick();
    expect(findPreview().props('policyDescription')).not.toEqual(initialValue);
  });

  it('adds a new rule', async () => {
    expect(wrapper.findAllComponents(PolicyRuleBuilder)).toHaveLength(1);
    const button = findAddRuleButton();
    button.vm.$emit('click');
    button.vm.$emit('click');
    await wrapper.vm.$nextTick();
    const elements = wrapper.findAllComponents(PolicyRuleBuilder);
    expect(elements).toHaveLength(3);

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
    expect(wrapper.findAllComponents(PolicyRuleBuilder)).toHaveLength(2);

    findPolicyRuleBuilder().vm.$emit('remove');
    await wrapper.vm.$nextTick();
    expect(wrapper.findAllComponents(PolicyRuleBuilder)).toHaveLength(1);
  });

  it('updates yaml editor value on switch to yaml editor', async () => {
    findPolicyName().vm.$emit('input', 'test-policy');
    findEditorModeToggle().vm.$emit('input', EditorModeYAML);
    await wrapper.vm.$nextTick();

    const editor = findPolicyYamlEditor();
    expect(editor.exists()).toBe(true);
    expect(fromYaml(editor.attributes('value'))).toMatchObject({
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

    it('disables policy name field', () => {
      expect(findPolicyName().attributes().disabled).toBe('true');
    });

    it('disables policy description field', () => {
      expect(findPolicyDescription().attributes().disabled).toBe('true');
    });

    it('disables policy enable/disable toggle', () => {
      expect(findPolicyEnableContainer().attributes().disabled).toBe('true');
    });

    it('renders parsing error alert', () => {
      expect(findYAMLParsingAlert().exists()).toBe(true);
    });

    it('disables rule builder', () => {
      expect(wrapper.findByTestId('rule-builder-container').props().disabled).toBe(true);
    });

    it('disables action picker', () => {
      expect(wrapper.findByTestId('policy-action-container').props().disabled).toBe(true);
    });

    it('disables policy preview', () => {
      expect(wrapper.findByTestId('policy-preview-container').props().disabled).toBe(true);
    });

    it('does not update yaml editor value on switch to yaml editor', async () => {
      findPolicyName().vm.$emit('input', 'test-policy');
      findEditorModeToggle().vm.$emit('input', EditorModeYAML);
      await wrapper.vm.$nextTick();

      const editor = findPolicyYamlEditor();
      expect(editor.exists()).toBe(true);
      expect(editor.attributes('value')).toEqual('');
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
      expect(wrapper.findAllComponents(PolicyRuleBuilder)).toHaveLength(1);
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
      wrapper.findComponent(GlModal).vm.$emit('secondary');
      await wrapper.vm.$nextTick();

      expect(store.dispatch).toHaveBeenCalledWith('networkPolicies/deletePolicy', {
        environmentId: -1,
        policy: { name: 'policy', manifest: toYaml(wrapper.vm.policy) },
      });
      expect(redirectTo).toHaveBeenCalledWith('/threat-monitoring');
    });
  });

  describe('add alert picker', () => {
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
