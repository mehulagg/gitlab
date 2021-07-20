import { shallowMount } from '@vue/test-utils';
import PolicyEditorLayout from 'ee/threat_monitoring/components/policy_editor/policy_editor_layout.vue';
import { DEFAULT_SCAN_EXECUTION_POLICY } from 'ee/threat_monitoring/components/policy_editor/scan_execution_policy/lib';
import ScanExecutionPolicyEditor from 'ee/threat_monitoring/components/policy_editor/scan_execution_policy/scan_execution_policy_editor.vue';

describe('ScanExecutionPolicyEditor', () => {
  let wrapper;

  const factory = ({ propsData = {} } = {}) => {
    wrapper = shallowMount(ScanExecutionPolicyEditor, {
      propsData,
      provide: {
        threatMonitoringPath: '',
        projectId: 1,
      },
    });
  };

  const findPolicyEditorLayout = () => wrapper.findComponent(PolicyEditorLayout);

  beforeEach(() => {
    factory();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('updates the policy yaml when "update-yaml" is emitted', async () => {
    const newManifest = 'new yaml!';
    expect(findPolicyEditorLayout().attributes('yamleditorvalue')).toBe(
      DEFAULT_SCAN_EXECUTION_POLICY,
    );
    await findPolicyEditorLayout().vm.$emit('update-yaml', newManifest);
    expect(findPolicyEditorLayout().attributes('yamleditorvalue')).toBe(newManifest);
  });
});
