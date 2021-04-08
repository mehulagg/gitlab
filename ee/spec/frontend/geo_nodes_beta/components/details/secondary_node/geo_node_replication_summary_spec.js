import { GlButton, GlCard } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import GeoNodeReplicationStatus from 'ee/geo_nodes_beta/components/details/secondary_node/geo_node_replication_status.vue';
import GeoNodeReplicationSummary from 'ee/geo_nodes_beta/components/details/secondary_node/geo_node_replication_summary.vue';
import GeoNodeSyncSettings from 'ee/geo_nodes_beta/components/details/secondary_node/geo_node_sync_settings.vue';
import { MOCK_NODES } from 'ee_jest/geo_nodes_beta/mock_data';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';

describe('GeoNodeReplicationSummary', () => {
  let wrapper;

  const defaultProps = {
    node: MOCK_NODES[1],
  };

  const createComponent = (props) => {
    wrapper = extendedWrapper(
      shallowMount(GeoNodeReplicationSummary, {
        propsData: {
          ...defaultProps,
          ...props,
        },
        stubs: { GlCard },
      }),
    );
  };

  afterEach(() => {
    wrapper.destroy();
  });

  const findGlButton = () => wrapper.findComponent(GlButton);
  const findGeoNodeReplicationStatus = () => wrapper.findComponent(GeoNodeReplicationStatus);
  const findGeoNodeReplicationCounts = () => wrapper.findByTestId('replication-counts');
  const findGeoNodeSyncSettings = () => wrapper.findComponent(GeoNodeSyncSettings);

  describe('template', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders the GlButton as a link', () => {
      expect(findGlButton().exists()).toBe(true);
      expect(findGlButton().attributes('href')).toBe(MOCK_NODES[1].webGeoProjectsUrl);
    });

    it('renders the geo node replication status', () => {
      expect(findGeoNodeReplicationStatus().exists()).toBe(true);
    });

    it('renders the geo node replication counts', () => {
      expect(findGeoNodeReplicationCounts().exists()).toBe(true);
    });

    it('renders the geo node sync settings', () => {
      expect(findGeoNodeSyncSettings().exists()).toBe(true);
    });
  });
});
