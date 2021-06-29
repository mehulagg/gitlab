import { GlTable, GlDrawer } from '@gitlab/ui';
import { createLocalVue } from '@vue/test-utils';
import VueApollo from 'vue-apollo';
import NetworkPolicyList from 'ee/threat_monitoring/components/network_policy_list.vue';
import networkPoliciesQuery from 'ee/threat_monitoring/graphql/queries/network_policies.query.graphql';
import createStore from 'ee/threat_monitoring/store';
import createMockApolloProvider from 'helpers/mock_apollo_helper';
import { mountExtended, shallowMountExtended } from 'helpers/vue_test_utils_helper';
import { networkPolicies } from '../mocks/mock_apollo';
import { mockPoliciesResponse, mockCiliumPolicy } from '../mocks/mock_data';

const localVue = createLocalVue();
localVue.use(VueApollo);

const fullPath = 'project/path';
const environments = [
  {
    id: 2,
    global_id: 'gid://gitlab/Environment/2',
  },
];
const defaultRequestHandlers = {
  networkPolicies: networkPolicies(mockPoliciesResponse),
};
const pendingHandler = jest.fn(() => new Promise(() => {}));

describe('NetworkPolicyList component', () => {
  let store;
  let wrapper;
  let requestHandlers;

  const factory = ({ mountFn = mountExtended, propsData, state, data, handlers } = {}) => {
    store = createStore();
    Object.assign(store.state.networkPolicies, {
      ...state,
    });
    store.state.threatMonitoring.environments = environments;
    requestHandlers = {
      ...defaultRequestHandlers,
      ...handlers,
    };

    jest.spyOn(store, 'dispatch').mockImplementation(() => Promise.resolve());

    wrapper = mountFn(NetworkPolicyList, {
      propsData: {
        documentationPath: 'documentation_path',
        newPolicyPath: '/policies/new',
        ...propsData,
      },
      data,
      store,
      provide: {
        projectPath: fullPath,
      },
      apolloProvider: createMockApolloProvider([
        [networkPoliciesQuery, requestHandlers.networkPolicies],
      ]),
      stubs: { PolicyDrawer: GlDrawer },
      localVue,
    });
  };

  const findEnvironmentsPicker = () => wrapper.find({ ref: 'environmentsPicker' });
  const findPoliciesTable = () => wrapper.find(GlTable);
  const findTableEmptyState = () => wrapper.find({ ref: 'tableEmptyState' });
  const findPolicyDrawer = () => wrapper.findByTestId('policyDrawer');
  const findAutodevopsAlert = () => wrapper.findByTestId('autodevopsAlert');

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

  describe('initial state', () => {
    beforeEach(() => {
      factory({
        mountFn: shallowMountExtended,
        handlers: {
          networkPolicies: pendingHandler,
        },
      });
    });

    it('fetches policies', () => {
      expect(requestHandlers.networkPolicies).toHaveBeenCalledWith({
        fullPath,
      });
    });

    it("sets table's loading state", () => {
      expect(findPoliciesTable().attributes('busy')).toBe('true');
    });
  });

  it('fetches policies on environment change', async () => {
    store.dispatch.mockReset();
    await store.commit('threatMonitoring/SET_CURRENT_ENVIRONMENT_ID', 2);
    expect(requestHandlers.networkPolicies).toHaveBeenCalledTimes(2);
    expect(requestHandlers.networkPolicies.mock.calls[1][0]).toEqual({
      fullPath: 'project/path',
      environmentId: environments[0].global_id,
    });
  });

  describe('given selected policy is a cilium policy', () => {
    beforeEach(() => {
      findPoliciesTable().vm.$emit('row-selected', [mockCiliumPolicy]);
    });

    it('renders the new policy drawer', () => {
      expect(findPolicyDrawer().exists()).toBe(true);
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
    const editorDrawer = findPolicyDrawer();
    expect(editorDrawer.exists()).toBe(true);
    expect(editorDrawer.props('open')).toBe(false);
  });

  it('renders opened editor drawer on row selection', () => {
    findPoliciesTable().find('td').trigger('click');

    return wrapper.vm.$nextTick().then(() => {
      const editorDrawer = findPolicyDrawer();
      expect(editorDrawer.exists()).toBe(true);
      expect(editorDrawer.props('open')).toBe(true);
    });
  });

  it('does not render autodevops alert', () => {
    expect(findAutodevopsAlert().exists()).toBe(false);
  });

  describe('given there is a selected policy', () => {
    beforeEach(() => {
      findPoliciesTable().vm.$emit('row-selected', [mockPoliciesResponse[0]]);
    });

    it('renders opened editor drawer', () => {
      const editorDrawer = findPolicyDrawer();
      expect(editorDrawer.exists()).toBe(true);
      expect(editorDrawer.props('open')).toBe(true);
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
      const autoDevOpsPolicy = {
        ...mockPoliciesResponse[0],
        name: 'auto-devops',
        fromAutoDevops: true,
      };
      factory({
        handlers: {
          networkPolicies: networkPolicies([autoDevOpsPolicy]),
        },
      });
    });

    it('renders autodevops alert', () => {
      expect(findAutodevopsAlert().exists()).toBe(true);
    });
  });
});
