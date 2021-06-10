import CiliumNetworkPolicy from 'ee/threat_monitoring/components/policy_drawer/cilium_network_policy.vue';
import NetworkPolicyDrawer from 'ee/threat_monitoring/components/policy_drawer/network_policy_drawer.vue';
import { mountExtended } from 'helpers/vue_test_utils_helper';
import { mockPoliciesResponse, mockCiliumPolicy } from '../../mocks/mock_data';

const [mockGenericPolicy] = mockPoliciesResponse;

describe('NetworkPolicyDrawer component', () => {
  let wrapper;

  const factory = ({ propsData } = {}) => {
    wrapper = mountExtended(NetworkPolicyDrawer, {
      propsData: {
        editPolicyPath: '/policies/policy/edit?environment_id=-1',
        open: true,
        ...propsData,
      },
      stubs: { PolicyYamlEditor: true },
    });
  };

  // Finders
  const findEditButton = () => wrapper.findByTestId('edit-button');
  const findPolicyEditor = () => wrapper.findByTestId('policy-yaml-editor');
  const findCiliumNetworkPolicy = () => wrapper.findComponent(CiliumNetworkPolicy);

  // Shared assertions
  const itRendersEditButton = () => {
    it('renders edit button', () => {
      const button = findEditButton();
      expect(button.exists()).toBe(true);
      expect(button.attributes().href).toBe('/policies/policy/edit?environment_id=-1');
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('by default', () => {
    beforeEach(() => {
      factory();
    });

    it('does not render edit button', () => {
      expect(findEditButton().exists()).toBe(false);
    });
  });

  describe('given a generic network policy', () => {
    beforeEach(() => {
      factory({
        propsData: {
          policy: mockGenericPolicy,
        },
      });
    });

    it('renders network policy editor with manifest', () => {
      const policyEditor = findPolicyEditor();
      expect(policyEditor.exists()).toBe(true);
      expect(policyEditor.attributes('value')).toBe(mockGenericPolicy.manifest);
    });

    itRendersEditButton();
  });

  describe('given a cilium policy', () => {
    beforeEach(() => {
      factory({
        propsData: {
          policy: mockCiliumPolicy,
        },
      });
    });

    it('renders the network policy component', () => {
      expect(findCiliumNetworkPolicy().exists()).toBe(true);
    });

    itRendersEditButton();
  });
});
