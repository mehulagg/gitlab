import BasePolicy from 'ee/threat_monitoring/components/policy_editor/base_policy.vue';
import toYaml from 'ee/threat_monitoring/components/policy_editor/lib/to_yaml';
import ScanExecutionPolicy from 'ee/threat_monitoring/components/policy_editor/scan_execution_policy.vue';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';

describe('ScanExecutionPolicy component', () => {
  let wrapper;
  const policy = {
    name: 'test-policy',
    description: 'test description',
    endpointLabels: '',
    rules: [],
  };
  const unsupportedYaml = 'unsupportedPrimaryKey: test';

  const findDescription = () => wrapper.findByTestId('description');

  const factory = ({ propsData } = {}) => {
    wrapper = shallowMountExtended(ScanExecutionPolicy, {
      propsData: {
        ...propsData,
      },
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
      factory({ propsData: { value: toYaml(policy) } });
    });

    it('renders policy preview tabs', () => {
      expect(wrapper.find('div').element).toMatchSnapshot();
    });

    it('does render the policy description', () => {
      expect(findDescription().exists()).toBe(true);
      expect(findDescription().text()).toContain('test description');
    });
  });

  describe('unsupported YAML', () => {
    beforeEach(() => {
      factory({ propsData: { value: unsupportedYaml } });
    });

    it('renders policy preview tabs', () => {
      expect(wrapper.find('div').element).toMatchSnapshot();
    });

    it('does not render the policy description', () => {
      expect(findDescription().exists()).toBe(false);
    });
  });
});
