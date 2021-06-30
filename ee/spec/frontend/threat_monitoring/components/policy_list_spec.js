import { GlTable, GlDrawer } from '@gitlab/ui';
import { createLocalVue } from '@vue/test-utils';
import { merge } from 'lodash';
import VueApollo from 'vue-apollo';
import PolicyList from 'ee/threat_monitoring/components/policy_list.vue';
import networkPoliciesQuery from 'ee/threat_monitoring/graphql/queries/network_policies.query.graphql';
import scanExecutionPoliciesQuery from 'ee/threat_monitoring/graphql/queries/scan_execution_policies.query.graphql';
import createStore from 'ee/threat_monitoring/store';
import createMockApolloProvider from 'helpers/mock_apollo_helper';
import { mountExtended, shallowMountExtended } from 'helpers/vue_test_utils_helper';
import waitForPromises from 'helpers/wait_for_promises';
import { networkPolicies, scanExecutionPolicies } from '../mocks/mock_apollo';
import { mockNetworkPoliciesResponse, mockScanExecutionPoliciesResponse } from '../mocks/mock_data';

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
  networkPolicies: networkPolicies(mockNetworkPoliciesResponse),
  scanExecutionPolicies: scanExecutionPolicies(mockScanExecutionPoliciesResponse),
};
const pendingHandler = jest.fn(() => new Promise(() => {}));

describe('PolicyList component', () => {
  let store;
  let wrapper;
  let requestHandlers;

  const factory = (mountFn = mountExtended) => (options = {}) => {
    store = createStore();
    const { state, handlers, ...wrapperOptions } = options;
    Object.assign(store.state.networkPolicies, {
      ...state,
    });
    store.state.threatMonitoring.environments = environments;
    requestHandlers = {
      ...defaultRequestHandlers,
      ...handlers,
    };

    jest.spyOn(store, 'dispatch').mockImplementation(() => Promise.resolve());

    wrapper = mountFn(
      PolicyList,
      merge(
        {
          propsData: {
            documentationPath: 'documentation_path',
            newPolicyPath: '/policies/new',
          },
          store,
          provide: {
            projectPath: fullPath,
          },
          apolloProvider: createMockApolloProvider([
            [networkPoliciesQuery, requestHandlers.networkPolicies],
            [scanExecutionPoliciesQuery, requestHandlers.scanExecutionPolicies],
          ]),
          stubs: {
            PolicyDrawer: GlDrawer,
          },
          localVue,
        },
        wrapperOptions,
      ),
    );
  };
  const mountShallowWrapper = factory(shallowMountExtended);
  const mountWrapper = factory();

  const findEnvironmentsPicker = () => wrapper.find({ ref: 'environmentsPicker' });
  const findPoliciesTable = () => wrapper.findComponent(GlTable);
  const findPolicyDrawer = () => wrapper.findByTestId('policyDrawer');
  const findAutodevopsAlert = () => wrapper.findByTestId('autodevopsAlert');

  afterEach(() => {
    wrapper.destroy();
  });

  describe('initial state', () => {
    beforeEach(() => {
      mountShallowWrapper({
        handlers: {
          networkPolicies: pendingHandler,
        },
      });
    });

    it('renders EnvironmentPicker', () => {
      expect(findEnvironmentsPicker().exists()).toBe(true);
    });

    it('renders the new policy button', () => {
      const button = wrapper.findByTestId('new-policy');
      expect(button.exists()).toBe(true);
    });

    it('renders closed editor drawer', () => {
      const editorDrawer = findPolicyDrawer();
      expect(editorDrawer.exists()).toBe(true);
      expect(editorDrawer.props('open')).toBe(false);
    });

    it('does not render autodevops alert', () => {
      expect(findAutodevopsAlert().exists()).toBe(false);
    });

    it('fetches policies', () => {
      expect(requestHandlers.networkPolicies).toHaveBeenCalledWith({
        fullPath,
      });
      expect(requestHandlers.scanExecutionPolicies).toHaveBeenCalledWith({
        fullPath,
      });
    });

    it("sets table's loading state", () => {
      expect(findPoliciesTable().attributes('busy')).toBe('true');
    });

    it('fetches network policies on environment change', async () => {
      store.dispatch.mockReset();
      await store.commit('threatMonitoring/SET_CURRENT_ENVIRONMENT_ID', 2);
      expect(requestHandlers.networkPolicies).toHaveBeenCalledTimes(2);
      expect(requestHandlers.networkPolicies.mock.calls[1][0]).toEqual({
        fullPath: 'project/path',
        environmentId: environments[0].global_id,
      });
    });
  });

  describe('given policies have been fetched', () => {
    let rows;

    beforeEach(async () => {
      mountWrapper();
      await waitForPromises();
      rows = wrapper.findAll('tr');
    });

    it.each`
      rowIndex | expectedPolicyName
      ${1}     | ${mockNetworkPoliciesResponse[0].name}
      ${2}     | ${'drop-outbound'}
      ${3}     | ${'allow-inbound-http'}
      ${4}     | ${mockScanExecutionPoliciesResponse[0].name}
    `(
      'renders "$expectedPolicyName" policy in row #$rowIndex',
      ({ expectedPolicyName, rowIndex }) => {
        expect(rows.at(rowIndex).text()).toContain(expectedPolicyName);
      },
    );
  });

  describe('with allEnvironments enabled', () => {
    beforeEach(() => {
      mountWrapper();
      wrapper.vm.$store.state.threatMonitoring.allEnvironments = true;
    });

    it('renders policies table', () => {
      const namespaceHeader = findPoliciesTable().findAll('[role="columnheader"]').at(1);
      expect(namespaceHeader.text()).toBe('Namespace');
    });
  });

  describe('given there is a selected policy', () => {
    beforeEach(() => {
      mountShallowWrapper();
      findPoliciesTable().vm.$emit('row-selected', [mockNetworkPoliciesResponse[0]]);
    });

    it('renders opened editor drawer', () => {
      const editorDrawer = findPolicyDrawer();
      expect(editorDrawer.exists()).toBe(true);
      expect(editorDrawer.props('open')).toBe(true);
    });
  });

  describe('given an autodevops policy', () => {
    beforeEach(() => {
      const autoDevOpsPolicy = {
        ...mockNetworkPoliciesResponse[0],
        name: 'auto-devops',
        fromAutoDevops: true,
      };
      mountShallowWrapper({
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
