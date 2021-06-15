import { GlFormSelect } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import EnvironmentPicker from 'ee/threat_monitoring/components/environment_picker.vue';
import { POLICY_TYPES } from 'ee/threat_monitoring/components/policy_editor/constants';
import NetworkPolicyEditor from 'ee/threat_monitoring/components/policy_editor/network_policy/network_policy_editor.vue';
import PolicyEditor from 'ee/threat_monitoring/components/policy_editor/policy_editor.vue';
import createStore from 'ee/threat_monitoring/store';

describe('PolicyEditor component', () => {
  let store;
  let wrapper;

  const findEnvironmentPicker = () => wrapper.findComponent(EnvironmentPicker);
  const findFormSelect = () => wrapper.findComponent(GlFormSelect);
  const findNeworkPolicyEditor = () => wrapper.findComponent(NetworkPolicyEditor);

  const factory = ({ propsData = {}, provide = {} } = {}) => {
    store = createStore();

    jest.spyOn(store, 'dispatch').mockImplementation(() => Promise.resolve());

    wrapper = shallowMount(PolicyEditor, {
      propsData: {
        threatMonitoringPath: '/threat-monitoring',
        projectId: '21',
        ...propsData,
      },
      provide,
      store,
      stubs: { GlFormSelect },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('default', () => {
    beforeEach(factory);

    it('renders the environment picker', () => {
      expect(findEnvironmentPicker().exists()).toBe(true);
    });

    it('renders the form select', () => {
      const formSelect = findFormSelect();
      expect(formSelect.exists()).toBe(true);
      expect(formSelect.attributes('value')).toBe(POLICY_TYPES.networkPolicy.value);
      expect(formSelect.attributes('disabled')).toBe('true');
    });

    it('renders the "NetworkPolicyEditor" component', () => {
      expect(findNeworkPolicyEditor().exists()).toBe(true);
    });
  });

  describe('with "scanExecutionPolicyUi" feature flag enabled', () => {
    beforeEach(() => {
      factory({ provide: { glFeatures: { scanExecutionPolicyUi: true } } });
    });

    it('renders the form select', () => {
      const formSelect = findFormSelect();
      expect(formSelect.exists()).toBe(true);
      expect(formSelect.attributes('disabled')).toBe(undefined);
    });
  });
});
