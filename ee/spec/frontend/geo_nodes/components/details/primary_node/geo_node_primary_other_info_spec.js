import { GlCard } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import GeoNodeProgressBar from 'ee/geo_nodes/components/details/geo_node_progress_bar.vue';
import GeoNodePrimaryOtherInfo from 'ee/geo_nodes/components/details/primary_node/geo_node_primary_other_info.vue';
import { MOCK_NODES } from 'ee_jest/geo_nodes/mock_data';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import { numberToHumanSize } from '~/lib/utils/number_utils';

describe('GeoNodePrimaryOtherInfo', () => {
  let wrapper;

  const defaultProps = {
    node: MOCK_NODES[0],
  };

  const createComponent = (props) => {
    wrapper = extendedWrapper(
      shallowMount(GeoNodePrimaryOtherInfo, {
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

  const findGlCard = () => wrapper.findComponent(GlCard);
  const findGeoNodeProgressBar = () => wrapper.findComponent(GeoNodeProgressBar);
  const findReplicationSlotWAL = () => wrapper.findByTestId('replication-slot-wal');

  describe('template', () => {
    describe('always', () => {
      beforeEach(() => {
        createComponent();
      });

      it('renders the details card', () => {
        expect(findGlCard().exists()).toBe(true);
      });

      it('renders the replication slot WAL section', () => {
        expect(findReplicationSlotWAL().exists()).toBe(true);
      });

      it('renders the replicationSlots progress bar', () => {
        expect(findGeoNodeProgressBar().exists()).toBe(true);
      });
    });

    describe('when replicationSlotWAL exists', () => {
      beforeEach(() => {
        createComponent({ node: MOCK_NODES[0] });
      });

      it('renders the replicationSlotWAL section correctly', () => {
        expect(findReplicationSlotWAL().text()).toBe(
          numberToHumanSize(MOCK_NODES[0].replicationSlotsMaxRetainedWalBytes),
        );
      });
    });

    describe('when replicationSlotWAL is null', () => {
      beforeEach(() => {
        createComponent({ node: MOCK_NODES[1] });
      });

      it('renders Unknown', () => {
        expect(findReplicationSlotWAL().text()).toBe('Unknown');
      });
    });
  });
});
