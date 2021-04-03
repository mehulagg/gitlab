import { GlButton } from '@gitlab/ui';
import { mount } from '@vue/test-utils';
import GeoNodeReplicationSummary from 'ee/geo_nodes_beta/components/details/secondary_node/geo_node_replication_summary.vue';
import { MOCK_NODES } from 'ee_jest/geo_nodes_beta/mock_data';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';

describe('GeoNodeReplicationSummary', () => {
  let wrapper;

  const defaultProps = {
    node: MOCK_NODES[1],
  };

  const createComponent = (initialState, props) => {
    wrapper = extendedWrapper(
      mount(GeoNodeReplicationSummary, {
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

  const findGlButton = () => wrapper.findComponent(GlButton);
  const findGeoNodeReplicationStatus = () => wrapper.findByTestId('replication-status');
  const findGeoNodeReplicationCounts = () => wrapper.findByTestId('replication-counts');
  const findGeoNodeSyncSettings = () => wrapper.findByTestId('sync-settings');

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
