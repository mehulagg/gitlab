import { GlFormTextarea } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import fromYaml from 'ee/threat_monitoring/components/policy_editor/lib/from_yaml';
import toYaml from 'ee/threat_monitoring/components/policy_editor/lib/to_yaml';
import PolicyDrawer from 'ee/threat_monitoring/components/policy_editor/policy_drawer.vue';
import PolicyPreview from 'ee/threat_monitoring/components/policy_editor/policy_preview.vue';

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
  const findTextForm = () => wrapper.findComponent(GlFormTextarea);

  const factory = ({ propsData } = {}) => {
    wrapper = shallowMount(PolicyDrawer, {
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
      expect(findTextForm().exists()).toBe(true);
      expect(findTextForm().props()).toMatchObject({ value: 'test description' });
    });

    it('does render the policy preview', () => {
      expect(findPolicyPreview().exists()).toBe(true);
      expect(findPolicyPreview().props()).toStrictEqual({
        initialTab: 1,
        policyDescription: 'Deny all traffic',
        policyYaml: toYaml(policy),
      });
    });

    it('emits input event on description change', () => {
      wrapper.find(GlFormTextarea).vm.$emit('input', 'new description');

      expect(wrapper.emitted().input.length).toEqual(1);
      const updatedPolicy = fromYaml(wrapper.emitted().input[0][0]);
      expect(updatedPolicy.description).toEqual('new description');
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
      expect(findTextForm().exists()).toBe(false);
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
