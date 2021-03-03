import { GlCard } from '@gitlab/ui';
import { createLocalVue, shallowMount } from '@vue/test-utils';
import Vuex from 'vuex';
import GeoNodeProgressBar from 'ee/geo_nodes_beta/components/details/geo_node_progress_bar.vue';
import GeoNodePrimaryOtherInfo from 'ee/geo_nodes_beta/components/details/primary_node/geo_node_primary_other_info.vue';
import {
  MOCK_PRIMARY_VERSION,
  MOCK_REPLICABLE_TYPES,
  MOCK_NODES,
} from 'ee_jest/geo_nodes_beta/mock_data';
import { numberToHumanSize } from '~/lib/utils/number_utils';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('GeoNodePrimaryOtherInfo', () => {
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

    wrapper = shallowMount(GeoNodePrimaryOtherInfo, {
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

  const findGlCard = () => wrapper.find(GlCard);
  const findGeoNodeProgressBar = () => wrapper.find(GeoNodeProgressBar);
  const findReplicationSlotWAL = () => wrapper.find('[data-testid="replicationSlotWAL"]');

  describe('template', () => {
    describe('always', () => {
      beforeEach(() => {
        createComponent();
      });

      it('renders the details card', () => {
        expect(findGlCard().exists()).toBe(true);
      });

      it('renders the replicationSlots progress bar', () => {
        expect(findGeoNodeProgressBar().exists()).toBe(true);
      });
    });

    describe.each`
      node             | showReplicationSlotWAL | replicationSlotWAL
      ${MOCK_NODES[0]} | ${true}                | ${numberToHumanSize(MOCK_NODES[0].replicationSlotsMaxRetainedWalBytes)}
      ${MOCK_NODES[1]} | ${false}               | ${null}
    `(`conditionally`, ({ node, showReplicationSlotWAL, replicationSlotWAL }) => {
      beforeEach(() => {
        createComponent(null, { node });
      });

      describe(`when replicationSlotWAL is ${node.replicationSlotsMaxRetainedWalBytes}`, () => {
        it(`does ${!showReplicationSlotWAL ? 'not ' : ''}render GeoNodePrimaryInfo`, () => {
          expect(findReplicationSlotWAL().exists()).toBe(showReplicationSlotWAL);
          if (showReplicationSlotWAL) {
            expect(findReplicationSlotWAL().text()).toBe(replicationSlotWAL);
          }
        });
      });
    });
  });
});
