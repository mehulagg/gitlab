import { createLocalVue, shallowMount } from '@vue/test-utils';
import Vuex from 'vuex';
import GeoNodeSyncSettings from 'ee/geo_nodes_beta/components/details/secondary_node/geo_node_sync_settings.vue';
import {
  MOCK_PRIMARY_VERSION,
  MOCK_REPLICABLE_TYPES,
  MOCK_NODES,
} from 'ee_jest/geo_nodes_beta/mock_data';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('GeoNodeSyncSettings', () => {
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

    wrapper = shallowMount(GeoNodeSyncSettings, {
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

  const findSyncType = () => wrapper.find('[data-testid="syncType"]');
  const findSyncStatusEventInfo = () => wrapper.find('[data-testid="syncStatusEventInfo"]');

  describe('template', () => {
    describe('always', () => {
      beforeEach(() => {
        createComponent();
      });

      it('renders the sync type', () => {
        expect(findSyncType().exists()).toBe(true);
      });
    });

    describe('conditionally', () => {
      describe.each`
        selectiveSyncType | text
        ${null}           | ${'Full'}
        ${'namespaces'}   | ${'Selective (groups)'}
        ${'shards'}       | ${'Selective (shards)'}
      `(`sync type`, ({ selectiveSyncType, text }) => {
        beforeEach(() => {
          createComponent(null, { node: { selectiveSyncType } });
        });

        it(`renders correctly when selectiveSyncType is ${selectiveSyncType}`, () => {
          expect(findSyncType().text()).toBe(text);
        });
      });

      describe.each`
        eventData                                                                                                          | shouldRender | text
        ${{ lastEventTimestamp: null, cursorLastEventTimestamp: null }}                                                    | ${false}     | ${null}
        ${{ lastEventTimestamp: 1511255300, lastEventId: 10, cursorLastEventTimestamp: 1511255200, cursorLastEventId: 9 }} | ${true}      | ${'20 seconds (1 events)'}
      `(`sync status event info`, ({ eventData, shouldRender, text }) => {
        beforeEach(() => {
          createComponent(null, { node: { ...eventData } });
        });

        describe(`when eventData ${shouldRender ? 'exists' : 'does not exist'}`, () => {
          it(`does ${!shouldRender ? 'not ' : ''}render event info`, () => {
            expect(findSyncStatusEventInfo().exists()).toBe(shouldRender);

            if (shouldRender) {
              expect(findSyncStatusEventInfo().text()).toBe(text);
            }
          });
        });
      });
    });
  });
});
