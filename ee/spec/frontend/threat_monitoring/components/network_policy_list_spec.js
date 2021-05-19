import { GlTable } from '@gitlab/ui';
import { mount } from '@vue/test-utils';
import NetworkPolicyList from 'ee/threat_monitoring/components/network_policy_list.vue';
import PolicyDrawer from 'ee/threat_monitoring/components/policy_editor/policy_drawer.vue';
import createStore from 'ee/threat_monitoring/store';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';
import { mockPoliciesResponse } from '../mocks/mock_data';

const mockData = mockPoliciesResponse.map((policy) => convertObjectPropsToCamelCase(policy));

describe('NetworkPolicyList component', () => {
  let store;
  let wrapper;

  const factory = ({ propsData, state, data, provide } = {}) => {
    store = createStore();
    Object.assign(store.state.networkPolicies, {
      isLoadingPolicies: false,
      policies: mockData,
      ...state,
    });

    jest.spyOn(store, 'dispatch').mockImplementation(() => Promise.resolve());

    wrapper = mount(NetworkPolicyList, {
      propsData: {
        documentationPath: 'documentation_path',
        newPolicyPath: '/policies/new',
        ...propsData,
      },
      data,
      store,
      provide,
      stubs: { NetworkPolicyEditor: true },
    });
  };

  const findEnvironmentsPicker = () => wrapper.find({ ref: 'environmentsPicker' });
  const findPoliciesTable = () => wrapper.find(GlTable);
  const findTableEmptyState = () => wrapper.find({ ref: 'tableEmptyState' });
  const findEditorDrawer = () => wrapper.find({ ref: 'editorDrawer' });
  const findPolicyEditor = () => wrapper.find({ ref: 'policyEditor' });
  const findAutodevopsAlert = () => wrapper.find('[data-testid="autodevopsAlert"]');

  beforeEach(() => {
    factory({});
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('renders EnvironmentPicker', () => {
    expect(findEnvironmentsPicker().exists()).toBe(true);
  });

  it('renders the new policy button', () => {
    const button = wrapper.find('[data-testid="new-policy"]');
    expect(button.exists()).toBe(true);
  });

  it('does not render the new policy drawer', () => {
    expect(wrapper.find(PolicyDrawer).exists()).toBe(false);
  });

  it('fetches policies', () => {
    expect(store.dispatch).toHaveBeenCalledWith('networkPolicies/fetchPolicies', -1);
  });

  it('fetches policies on environment change', async () => {
    store.dispatch.mockReset();
    await store.commit('threatMonitoring/SET_CURRENT_ENVIRONMENT_ID', 2);

    expect(store.dispatch).toHaveBeenCalledWith('networkPolicies/fetchPolicies', 2);
  });

  it('does not render edit button', () => {
    expect(wrapper.find('[data-testid="edit-button"]').exists()).toBe(false);
  });

  describe('given selected policy is a cilium policy', () => {
    const manifest = `apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: policy
spec:
  endpointSelector: {}`;

    beforeEach(() => {
      factory({
        data: () => ({ selectedPolicyName: 'policy' }),
        state: {
          policies: [
            {
              name: 'policy',
              creationTimestamp: new Date(),
              manifest,
            },
          ],
        },
      });
    });

    it('renders the new policy drawer', () => {
      expect(wrapper.find(PolicyDrawer).exists()).toBe(true);
    });

    it('renders edit button', () => {
      const button = wrapper.find('[data-testid="edit-button"]');
      expect(button.exists()).toBe(true);
      expect(button.attributes().href).toBe('/policies/policy/edit?environment_id=-1');
    });
  });

  it('renders policies table', () => {
    expect(findPoliciesTable().element).toMatchSnapshot();
  });

  describe('with allEnvironments enabled', () => {
    beforeEach(() => {
      wrapper.vm.$store.state.threatMonitoring.allEnvironments = true;
    });

    it('renders policies table', () => {
      const namespaceHeader = findPoliciesTable().findAll('[role="columnheader"]').at(1);
      expect(namespaceHeader.text()).toBe('Namespace');
    });
  });

  it('renders closed editor drawer', () => {
    const editorDrawer = findEditorDrawer();
    expect(editorDrawer.exists()).toBe(true);
    expect(editorDrawer.props('open')).toBe(false);
  });

  it('renders opened editor drawer on row selection', () => {
    findPoliciesTable().find('td').trigger('click');

    return wrapper.vm.$nextTick().then(() => {
      const editorDrawer = findEditorDrawer();
      expect(editorDrawer.exists()).toBe(true);
      expect(editorDrawer.props('open')).toBe(true);
    });
  });

  it('does not render autodevops alert', () => {
    expect(findAutodevopsAlert().exists()).toBe(false);
  });

  describe('given there is a selected policy', () => {
    beforeEach(() => {
      factory({
        data: () => ({
          selectedPolicyName: 'policy',
          initialManifest: mockData[0].manifest,
          initialEnforcementStatus: mockData[0].isEnabled,
        }),
      });
    });

    it('renders opened editor drawer', () => {
      const editorDrawer = findEditorDrawer();
      expect(editorDrawer.exists()).toBe(true);
      expect(editorDrawer.props('open')).toBe(true);
    });

    it('renders network policy editor with manifest', () => {
      const policyEditor = findPolicyEditor();
      expect(policyEditor.exists()).toBe(true);
      expect(policyEditor.attributes('value')).toBe(mockData[0].manifest);
    });
  });

  describe('given there is a default environment with no data to display', () => {
    beforeEach(() => {
      factory({
        state: {
          policies: [],
        },
      });
    });

    it('shows the table empty state', () => {
      expect(findTableEmptyState().element).toMatchSnapshot();
    });
  });

  describe('given autodevops selected policy', () => {
    beforeEach(() => {
      const policies = mockPoliciesResponse;
      policies[0].isAutodevops = true;
      factory({
        state: { policies },
        data: () => ({ selectedPolicyName: 'policy' }),
      });
    });

    it('renders autodevops alert', () => {
      expect(findAutodevopsAlert().exists()).toBe(true);
    });
  });
});
