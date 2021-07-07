import BasePolicy from 'ee/threat_monitoring/components/policy_drawer/base_policy.vue';
import ScanExecutionPolicy from 'ee/threat_monitoring/components/policy_drawer/scan_execution_policy.vue';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import { mockScanExecutionPolicy } from '../../mocks/mock_data';

describe('ScanExecutionPolicy component', () => {
  let wrapper;

  const findDescription = () => wrapper.findByTestId('description');

  const factory = ({ propsData } = {}) => {
    wrapper = shallowMountExtended(ScanExecutionPolicy, {
      propsData,
      stubs: {
        BasePolicy,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('supported YAML', () => {
    beforeEach(() => {
      factory({ propsData: { policy: mockScanExecutionPolicy } });
    });

    it('does render the policy description', () => {
      expect(findDescription().exists()).toBe(true);
      expect(findDescription().text()).toBe(
        'This policy enforces pipeline configuration to have a job with DAST scan',
      );
    });
  });
});
