import { GlTable, GlDrawer } from '@gitlab/ui';
import { createLocalVue } from '@vue/test-utils';
import { merge, cloneDeep } from 'lodash';
import VueApollo from 'vue-apollo';
import PolicyList from 'ee/threat_monitoring/components/policy_list.vue';
import networkPoliciesQuery from 'ee/threat_monitoring/graphql/queries/network_policies.query.graphql';
import scanExecutionPoliciesQuery from 'ee/threat_monitoring/graphql/queries/scan_execution_policies.query.graphql';
import createStore from 'ee/threat_monitoring/store';
import createMockApolloProvider from 'helpers/mock_apollo_helper';
import { stubComponent } from 'helpers/stub_component';
import { mountExtended, shallowMountExtended } from 'helpers/vue_test_utils_helper';
import { networkPolicies, scanExecutionPolicies } from '../mocks/mock_apollo';
import { mockPoliciesResponse, mockScanExecutionPolicy } from '../mocks/mock_data';

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
  scanExecutionPolicies: scanExecutionPolicies([mockScanExecutionPolicy]),
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
  const findPolicyStatusCells = () => wrapper.findAllByTestId('policy-status-cell');
  const findPolicyDrawer = () => wrapper.findByTestId('policyDrawer');
  const findAutodevopsAlert = () => wrapper.findByTestId('autodevopsAlert');

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
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
      const button = wrapper.find('[data-testid="new-policy"]');
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

    it('fetches network policies on environment change', async () => {
      store.dispatch.mockReset();
      await store.commit('threatMonitoring/SET_CURRENT_ENVIRONMENT_ID', 2);
      expect(requestHandlers.networkPolicies).toHaveBeenCalledTimes(2);
      expect(requestHandlers.networkPolicies.mock.calls[1][0]).toEqual({
        fullPath: 'project/path',
        environmentId: environments[0].global_id,
      });
    });

    it("sets table's loading state", () => {
      expect(findPoliciesTable().attributes('busy')).toBe('true');
    });
  });

  describe('given policies have been fetched', () => {
    beforeEach(() => {
      mountShallowWrapper({
        stubs: {
          GlTable: stubComponent(GlTable, {
            template: '<table data-testid="table" />',
            props: ['items'],
          }),
        },
      });
    });

    it('passes all policies to the table', () => {
      expect(cloneDeep(wrapper.findByTestId('table').props('items'))).toEqual([
        expect.objectContaining({
          name: mockPoliciesResponse[0].name,
        }),
        expect.objectContaining({
          name: 'drop-outbound',
        }),
        expect.objectContaining({
          name: 'allow-inbound-http',
        }),
        expect.objectContaining({
          name: mockScanExecutionPolicy.name,
        }),
      ]);
    });
  });

  describe('status column', () => {
    beforeEach(() => {
      mountWrapper();
    });

    it('renders a checkmark icon for enabled policies', () => {
      const icon = findPolicyStatusCells().at(0).find('svg');

      expect(icon.exists()).toBe(true);
      expect(icon.props('name')).toBe('check-circle-filled');
      expect(icon.props('ariaLabel')).toBe('Enabled');
    });

    it('renders a "Disabled" label for screen readers for disabled policies', () => {
      const span = findPolicyStatusCells().at(1).find('span');

      expect(span.exists()).toBe(true);
      expect(span.attributes('class')).toBe('gl-sr-only');
      expect(span.text()).toBe('Disabled');
    });
  });

  describe('with allEnvironments enabled', () => {
    beforeEach(() => {
      mountWrapper();
      wrapper.vm.$store.state.threatMonitoring.allEnvironments = true;
    });

    it('renders namespace column', () => {
      const namespaceHeader = findPoliciesTable().findAll('[role="columnheader"]').at(2);
      expect(namespaceHeader.text()).toBe('Namespace');
    });
  });

  describe('given there is a selected policy', () => {
    beforeEach(() => {
      mountShallowWrapper();
      findPoliciesTable().vm.$emit('row-selected', [mockPoliciesResponse[0]]);
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
        ...mockPoliciesResponse[0],
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
