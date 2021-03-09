import { GlButton } from '@gitlab/ui';
import { createLocalVue, mount } from '@vue/test-utils';
import Vuex from 'vuex';
import GeoNodeReplicationSummary from 'ee/geo_nodes_beta/components/details/secondary_node/geo_node_replication_summary.vue';
import {
  MOCK_PRIMARY_VERSION,
  MOCK_REPLICABLE_TYPES,
  MOCK_NODES,
} from 'ee_jest/geo_nodes_beta/mock_data';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('GeoNodeReplicationSummary', () => {
  let wrapper;

  const defaultProps = {
    node: MOCK_NODES[1],
  };

  const createComponent = (initialState, props) => {
    const store = new Vuex.Store({
      state: {
        primaryVersion: MOCK_PRIMARY_VERSION.version,
        primaryRevision: MOCK_PRIMARY_VERSION.revision,
        replicableTypes: MOCK_REPLICABLE_TYPES,
        ...initialState,
      },
      getters: {
        syncInfo: () => () => [],
        verificationInfo: () => () => [],
      },
    });

    wrapper = mount(GeoNodeReplicationSummary, {
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

  const findGlButton = () => wrapper.find(GlButton);
  const findGeoNodeReplicationStatus = () => wrapper.find('[data-testid="replication-status"]');
  const findGeoNodeReplicationCounts = () => wrapper.find('[data-testid="replication-counts"]');
  const findGeoNodeSyncSettings = () => wrapper.find('[data-testid="sync-settings"]');

  describe('template', () => {
    describe('always', () => {
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
});
