import { createLocalVue, shallowMount } from '@vue/test-utils';
import Vuex from 'vuex';
import GeoNodeCoreDetails from 'ee/geo_nodes_beta/components/details/geo_node_core_details.vue';
import GeoNodeDetails from 'ee/geo_nodes_beta/components/details/geo_node_details.vue';
import GeoNodePrimaryOtherInfo from 'ee/geo_nodes_beta/components/details/primary_node/geo_node_primary_other_info.vue';
import GeoNodeVerificationInfo from 'ee/geo_nodes_beta/components/details/primary_node/geo_node_verification_info.vue';
import GeoNodeReplicationSummary from 'ee/geo_nodes_beta/components/details/secondary_node/geo_node_replication_summary.vue';
import GeoNodeSecondaryOtherInfo from 'ee/geo_nodes_beta/components/details/secondary_node/geo_node_secondary_other_info.vue';
import {
  MOCK_PRIMARY_VERSION,
  MOCK_REPLICABLE_TYPES,
  MOCK_NODES,
} from 'ee_jest/geo_nodes_beta/mock_data';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('GeoNodeDetails', () => {
  let wrapper;

  const defaultProps = {
    node: MOCK_NODES[0],
  };

  const createComponent = (initialState, props) => {
    const store = new Vuex.Store({
      state: {
        primaryVersion: MOCK_PRIMARY_VERSION.version,
        primaryRevision: MOCK_PRIMARY_VERSION.revision,
        replicableTypes: MOCK_REPLICABLE_TYPES,
        ...initialState,
      },
    });

    wrapper = shallowMount(GeoNodeDetails, {
      localVue,
      store,
      propsData: {
        ...defaultProps,
        ...props,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  const findGeoNodeCoreDetails = () => wrapper.find(GeoNodeCoreDetails);
  const findGeoNodePrimaryOtherInfo = () => wrapper.find(GeoNodePrimaryOtherInfo);
  const findGeoNodeVerificationInfo = () => wrapper.find(GeoNodeVerificationInfo);
  const findGeoNodeSecondaryReplicationSummary = () => wrapper.find(GeoNodeReplicationSummary);
  const findGeoNodeSecondaryOtherInfo = () => wrapper.find(GeoNodeSecondaryOtherInfo);
  const findGeoNodeSecondaryReplicationDetails = () =>
    wrapper.find('[data-testid="secondaryReplicationDetails"]');

  describe('template', () => {
    describe('always', () => {
      beforeEach(() => {
        createComponent();
      });

      it('renders the Geo Nodes Core Details', () => {
        expect(findGeoNodeCoreDetails().exists()).toBe(true);
      });
    });

    describe.each`
      node             | showPrimaryComponent | showSecondaryComponent
      ${MOCK_NODES[0]} | ${true}              | ${false}
      ${MOCK_NODES[1]} | ${false}             | ${true}
    `(`conditionally`, ({ node, showPrimaryComponent, showSecondaryComponent }) => {
      beforeEach(() => {
        createComponent(null, { node });
      });

      describe(`when primary is ${node.primary}`, () => {
        it(`does ${!showPrimaryComponent ? 'not ' : ''}render GeoNodePrimaryOtherInfo`, () => {
          expect(findGeoNodePrimaryOtherInfo().exists()).toBe(showPrimaryComponent);
        });

        it(`does ${!showPrimaryComponent ? 'not ' : ''}render GeoNodeVerificationInfo`, () => {
          expect(findGeoNodeVerificationInfo().exists()).toBe(showPrimaryComponent);
        });

        it(`does ${
          !showSecondaryComponent ? 'not ' : ''
        }render GeoNodeSecondaryReplicationSummary`, () => {
          expect(findGeoNodeSecondaryReplicationSummary().exists()).toBe(showSecondaryComponent);
        });

        it(`does ${!showSecondaryComponent ? 'not ' : ''}render GeoNodeSecondaryOtherInfo`, () => {
          expect(findGeoNodeSecondaryOtherInfo().exists()).toBe(showSecondaryComponent);
        });

        it(`does ${
          !showSecondaryComponent ? 'not ' : ''
        }render GeoNodeSecondaryReplicationDetails`, () => {
          expect(findGeoNodeSecondaryReplicationDetails().exists()).toBe(showSecondaryComponent);
        });
      });
    });
  });
});
