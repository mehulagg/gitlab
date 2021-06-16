import {
  DEFAULT_SCAN_EXECUTION_POLICY,
  fromYaml,
} from 'ee/threat_monitoring/components/policy_editor/scan_execution_policy/lib';

describe('fromYaml', () => {
  it('returns policy object', () => {
    expect(fromYaml(DEFAULT_SCAN_EXECUTION_POLICY)).toMatchObject({
      name: '',
      description: '',
      enabled: false,
      actions: [{ scan: 'dast', site_profile: '', scanner_profile: '' }],
      rules: [{ branches: ['main'], type: 'pipeline' }],
    });
  });
});
