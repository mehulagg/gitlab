import { createLocalVue, shallowMount } from '@vue/test-utils';
import Vuex from 'vuex';
import GeoNodeCoreDetails from 'ee/geo_nodes_beta/components/details/geo_node_core_details.vue';
import GeoNodeDetails from 'ee/geo_nodes_beta/components/details/geo_node_details.vue';
import GeoNodePrimaryOtherInfo from 'ee/geo_nodes_beta/components/details/primary_node/geo_node_primary_other_info.vue';
import GeoNodeVerificationInfo from 'ee/geo_nodes_beta/components/details/primary_node/geo_node_verification_info.vue';
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
  const findGeoNodeSecondaryDetails = () => wrapper.find('[data-testid="secondaryNodeDetails"]');

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
      node             | showPrimaryOtherInfo | showPrimaryVerificationInfo | showSecondaryDetails
      ${MOCK_NODES[0]} | ${true}              | ${true}                     | ${false}
      ${MOCK_NODES[1]} | ${false}             | ${false}                    | ${true}
    `(
      `conditionally`,
      ({ node, showPrimaryOtherInfo, showPrimaryVerificationInfo, showSecondaryDetails }) => {
        beforeEach(() => {
          createComponent(null, { node });
        });

        describe(`when primary is ${node.primary}`, () => {
          it(`does ${!showPrimaryOtherInfo ? 'not ' : ''}render GeoNodePrimaryInfo`, () => {
            expect(findGeoNodePrimaryOtherInfo().exists()).toBe(showPrimaryOtherInfo);
          });

          it(`does ${
            !showPrimaryVerificationInfo ? 'not ' : ''
          }render GeoNodeVerificationInfo`, () => {
            expect(findGeoNodeVerificationInfo().exists()).toBe(showPrimaryVerificationInfo);
          });

          it(`does ${!showSecondaryDetails ? 'not ' : ''}render GeoNodeSecondaryDetails`, () => {
            expect(findGeoNodeSecondaryDetails().exists()).toBe(showSecondaryDetails);
          });
        });
      },
    );
  });
});
