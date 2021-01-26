import { GlFormTextarea } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import fromYaml from 'ee/threat_monitoring/components/policy_editor/lib/from_yaml';
import toYaml from 'ee/threat_monitoring/components/policy_editor/lib/to_yaml';
import PolicyDrawer from 'ee/threat_monitoring/components/policy_editor/policy_drawer.vue';

describe('PolicyDrawer component', () => {
  let wrapper;
  const policy = {
    name: 'test-policy',
    description: 'test description',
    endpointLabels: '',
    rules: [],
  };

  const factory = ({ propsData } = {}) => {
    wrapper = shallowMount(PolicyDrawer, {
      propsData: {
        ...propsData,
      },
    });
  };

  beforeEach(() => {
    factory({
      propsData: {
        value: toYaml(policy),
      },
    });
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders policy preview tabs', () => {
    expect(wrapper.find('div').element).toMatchSnapshot();
  });

  it('emits input event on description change', () => {
    wrapper.find(GlFormTextarea).vm.$emit('input', 'new description');

    expect(wrapper.emitted().input.length).toEqual(1);
    const updatedPolicy = fromYaml(wrapper.emitted().input[0][0]);
    expect(updatedPolicy.description).toEqual('new description');
  });
});
