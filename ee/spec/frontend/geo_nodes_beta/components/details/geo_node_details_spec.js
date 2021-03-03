import { shallowMount } from '@vue/test-utils';
import GeoNodeCoreDetails from 'ee/geo_nodes_beta/components/details/geo_node_core_details.vue';
import GeoNodeDetails from 'ee/geo_nodes_beta/components/details/geo_node_details.vue';
import GeoNodePrimaryOtherInfo from 'ee/geo_nodes_beta/components/details/primary_node/geo_node_primary_other_info.vue';
import GeoNodeVerificationInfo from 'ee/geo_nodes_beta/components/details/primary_node/geo_node_verification_info.vue';
import { MOCK_NODES } from 'ee_jest/geo_nodes_beta/mock_data';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';

describe('GeoNodeDetails', () => {
  let wrapper;

  const defaultProps = {
    node: MOCK_NODES[0],
  };

  const createComponent = (props) => {
    wrapper = extendedWrapper(
      shallowMount(GeoNodeDetails, {
        propsData: {
          ...defaultProps,
          ...props,
        },
      }),
    );
  };

  afterEach(() => {
    wrapper.destroy();
  });

  const findGeoNodeCoreDetails = () => wrapper.findComponent(GeoNodeCoreDetails);
  const findGeoNodePrimaryOtherInfo = () => wrapper.findComponent(GeoNodePrimaryOtherInfo);
  const findGeoNodeVerificationInfo = () => wrapper.findComponent(GeoNodeVerificationInfo);
  const findGeoNodeSecondaryDetails = () => wrapper.findByTestId('secondary-node-details');

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
          createComponent({ node });
        });

        describe(`when primary is ${node.primary}`, () => {
          it(`does ${showPrimaryOtherInfo ? '' : 'not '}render GeoNodePrimaryInfo`, () => {
            expect(findGeoNodePrimaryOtherInfo().exists()).toBe(showPrimaryOtherInfo);
          });

          it(`does ${
            showPrimaryVerificationInfo ? '' : 'not '
          }render GeoNodeVerificationInfo`, () => {
            expect(findGeoNodeVerificationInfo().exists()).toBe(showPrimaryVerificationInfo);
          });

          it(`does ${showSecondaryDetails ? '' : 'not '}render GeoNodeSecondaryDetails`, () => {
            expect(findGeoNodeSecondaryDetails().exists()).toBe(showSecondaryDetails);
          });
        });
      },
    );
  });
});
