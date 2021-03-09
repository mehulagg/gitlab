import { GlPopover, GlLink } from '@gitlab/ui';
import { createLocalVue, shallowMount } from '@vue/test-utils';
import Vuex from 'vuex';
import GeoNodeReplicationStatus from 'ee/geo_nodes_beta/components/details/secondary_node/geo_node_replication_status.vue';
import { REPLICATION_STATUS_UI, REPLICATION_PAUSE_URL } from 'ee/geo_nodes_beta/constants';
import {
  MOCK_PRIMARY_VERSION,
  MOCK_REPLICABLE_TYPES,
  MOCK_NODES,
} from 'ee_jest/geo_nodes_beta/mock_data';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('GeoNodeReplicationStatus', () => {
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
    });

    wrapper = shallowMount(GeoNodeReplicationStatus, {
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

  const findReplicationStatusIcon = () => wrapper.find('[data-testid="replicationStatusIcon"]');
  const findReplicationStatusText = () => wrapper.find('[data-testid="replicationStatusText"]');
  const findQuestionIcon = () => wrapper.find({ ref: 'replicationStatus' });
  const findGlPopover = () => wrapper.find(GlPopover);
  const findGlPopoverLink = () => findGlPopover().find(GlLink);

  describe('template', () => {
    describe('always', () => {
      beforeEach(() => {
        createComponent();
      });

      it('renders the replication status icon', () => {
        expect(findReplicationStatusIcon().exists()).toBe(true);
      });

      it('renders the replication status text', () => {
        expect(findReplicationStatusText().exists()).toBe(true);
      });

      it('renders the question icon correctly', () => {
        expect(findQuestionIcon().exists()).toBe(true);
        expect(findQuestionIcon().attributes('name')).toBe('question');
      });

      it('renders the GlPopover always', () => {
        expect(findGlPopover().exists()).toBeTruthy();
      });

      it('renders the popover link correctly', () => {
        expect(findGlPopoverLink().exists()).toBeTruthy();
        expect(findGlPopoverLink().attributes('href')).toBe(REPLICATION_PAUSE_URL);
      });
    });

    describe.each`
      enabled  | uiData
      ${true}  | ${REPLICATION_STATUS_UI.enabled}
      ${false} | ${REPLICATION_STATUS_UI.disabled}
    `(`conditionally`, ({ enabled, uiData }) => {
      beforeEach(() => {
        createComponent(null, { node: { enabled } });
      });

      describe(`when enabled is ${enabled}`, () => {
        it(`renders the replication status icon correctly`, () => {
          expect(findReplicationStatusIcon().classes(uiData.color)).toBe(true);
          expect(findReplicationStatusIcon().attributes('name')).toBe(uiData.icon);
        });

        it(`renders the replication status text correctly`, () => {
          expect(findReplicationStatusText().classes(uiData.color)).toBe(true);
          expect(findReplicationStatusText().text()).toBe(uiData.text);
        });
      });
    });
  });
});
