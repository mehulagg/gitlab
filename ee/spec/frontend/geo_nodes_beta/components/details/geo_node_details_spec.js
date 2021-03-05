import { createLocalVue, shallowMount } from '@vue/test-utils';
import Vuex from 'vuex';
import GeoNodeCoreDetails from 'ee/geo_nodes_beta/components/details/geo_node_core_details.vue';
import GeoNodeDetails from 'ee/geo_nodes_beta/components/details/geo_node_details.vue';
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
  });

  const findGeoNodeCoreDetails = () => wrapper.find(GeoNodeCoreDetails);
  const findGeoNodePrimaryDetails = () => wrapper.find('[data-testid="primary-node-details"]');
  const findGeoNodeSecondaryDetails = () => wrapper.find('[data-testid="secondary-node-details"]');

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
      node             | showPrimaryDetails | showSecondaryDetails
      ${MOCK_NODES[0]} | ${true}            | ${false}
      ${MOCK_NODES[1]} | ${false}           | ${true}
    `(`conditionally`, ({ node, showPrimaryDetails, showSecondaryDetails }) => {
      beforeEach(() => {
        createComponent(null, { node });
      });

      describe(`when primary is ${node.primary}`, () => {
        it(`does ${!showPrimaryDetails ? 'not ' : ''}render GeoNodePrimaryDetails`, () => {
          expect(findGeoNodePrimaryDetails().exists()).toBe(showPrimaryDetails);
        });

        it(`does ${!showSecondaryDetails ? 'not ' : ''}render GeoNodeSecondaryDetails`, () => {
          expect(findGeoNodeSecondaryDetails().exists()).toBe(showSecondaryDetails);
        });
      });
    });
  });
});
