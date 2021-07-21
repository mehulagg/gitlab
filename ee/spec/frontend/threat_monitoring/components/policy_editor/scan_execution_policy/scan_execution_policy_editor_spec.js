import { shallowMount } from '@vue/test-utils';
import PolicyEditorLayout from 'ee/threat_monitoring/components/policy_editor/policy_editor_layout.vue';
import {
  DEFAULT_SCAN_EXECUTION_POLICY,
  modifyPolicy,
} from 'ee/threat_monitoring/components/policy_editor/scan_execution_policy/lib';
import ScanExecutionPolicyEditor from 'ee/threat_monitoring/components/policy_editor/scan_execution_policy/scan_execution_policy_editor.vue';
import { DEFAULT_ASSIGNED_POLICY_PROJECT } from 'ee/threat_monitoring/constants';
import { visitUrl } from '~/lib/utils/url_utility';

jest.mock('~/lib/utils/url_utility', () => ({
  joinPaths: jest.requireActual('~/lib/utils/url_utility').joinPaths,
  visitUrl: jest.fn().mockName('visitUrlMock'),
}));

jest.mock('ee/threat_monitoring/components/policy_editor/scan_execution_policy/lib', () => ({
  DEFAULT_SCAN_EXECUTION_POLICY: jest.requireActual(
    'ee/threat_monitoring/components/policy_editor/scan_execution_policy/lib',
  ).DEFAULT_SCAN_EXECUTION_POLICY,
  fromYaml: jest.requireActual(
    'ee/threat_monitoring/components/policy_editor/scan_execution_policy/lib',
  ).fromYaml,
  modifyPolicy: jest.fn().mockResolvedValue({
    mergeRequest: { id: '2' },
    policyProject: { fullPath: 'tests' },
  }),
}));

describe('ScanExecutionPolicyEditor', () => {
  let wrapper;
  const defaultProjectPath = 'path/to/project';

  const factory = ({ propsData = {} } = {}) => {
    wrapper = shallowMount(ScanExecutionPolicyEditor, {
      propsData: {
        assignedPolicyProject: DEFAULT_ASSIGNED_POLICY_PROJECT,
        ...propsData,
      },
      provide: {
        disableScanExecutionUpdate: false,
        projectId: 1,
        projectPath: defaultProjectPath,
      },
    });
  };

  const findPolicyEditorLayout = () => wrapper.findComponent(PolicyEditorLayout);

  beforeEach(() => {});

  afterEach(() => {
    wrapper.destroy();
  });

  it('updates the policy yaml when "update-yaml" is emitted', async () => {
    factory();
    await wrapper.vm.$nextTick();
    const newManifest = 'new yaml!';
    expect(findPolicyEditorLayout().attributes('yamleditorvalue')).toBe(
      DEFAULT_SCAN_EXECUTION_POLICY,
    );
    await findPolicyEditorLayout().vm.$emit('update-yaml', newManifest);
    expect(findPolicyEditorLayout().attributes('yamleditorvalue')).toBe(newManifest);
  });

  it.each`
    status                            | action       | emit               | factoryFn
    ${'to save a new policy'}         | ${'APPEND'}  | ${'save-policy'}   | ${factory}
    ${'to update an existing policy'} | ${'REPLACE'} | ${'save-policy'}   | ${() => factory({ propsData: { existingPolicy: { manifest: DEFAULT_SCAN_EXECUTION_POLICY } } })}
    ${'to delete an existing policy'} | ${'REMOVE'}  | ${'remove-policy'} | ${() => factory({ propsData: { existingPolicy: { manifest: DEFAULT_SCAN_EXECUTION_POLICY } } })}
  `(
    'navigates to the new merge request when "modifyPolicy" is emitted $status',
    async ({ action, emit, factoryFn }) => {
      factoryFn();
      await wrapper.vm.$nextTick();
      findPolicyEditorLayout().vm.$emit(emit);
      await wrapper.vm.$nextTick();
      expect(modifyPolicy).toHaveBeenCalledTimes(1);
      expect(modifyPolicy).toHaveBeenCalledWith({
        action,
        assignedPolicyProject: DEFAULT_ASSIGNED_POLICY_PROJECT,
        projectPath: defaultProjectPath,
        yamlEditorValue: DEFAULT_SCAN_EXECUTION_POLICY,
      });
      await wrapper.vm.$nextTick();
      expect(visitUrl).toHaveBeenCalled();
      expect(visitUrl).toHaveBeenCalledWith('/tests/-/merge_requests/2');
    },
  );
});
