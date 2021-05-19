import toYaml from 'ee/threat_monitoring/components/policy_editor/lib/to_yaml';
import PolicyDrawer from 'ee/threat_monitoring/components/policy_editor/policy_drawer.vue';
import PolicyPreview from 'ee/threat_monitoring/components/policy_editor/policy_preview.vue';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';

describe('PolicyDrawer component', () => {
  let wrapper;
  const policy = {
    name: 'test-policy',
    description: 'test description',
    endpointLabels: '',
    rules: [],
  };
  const unsupportedYaml = 'unsupportedPrimaryKey: test';

  const findPolicyPreview = () => wrapper.findComponent(PolicyPreview);
  const findDescription = () => wrapper.findByTestId('description');

  const factory = ({ propsData } = {}) => {
    wrapper = shallowMountExtended(PolicyDrawer, {
      propsData: {
        ...propsData,
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
      expect(findDescription().text()).toBe('test description');
    });

    it('does render the policy preview', () => {
      expect(findPolicyPreview().exists()).toBe(true);
      expect(findPolicyPreview().props()).toStrictEqual({
        initialTab: 0,
        policyDescription: 'Deny all traffic',
        policyYaml: toYaml(policy),
      });
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

    it('does render the policy preview', () => {
      expect(findPolicyPreview().exists()).toBe(true);
      expect(findPolicyPreview().props()).toStrictEqual({
        initialTab: 0,
        policyDescription: null,
        policyYaml: unsupportedYaml,
      });
    });
  });
});
