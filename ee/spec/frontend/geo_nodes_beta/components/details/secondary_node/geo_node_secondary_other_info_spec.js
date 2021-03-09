import { createLocalVue, shallowMount } from '@vue/test-utils';
import Vuex from 'vuex';
import GeoNodeSecondaryOtherInfo from 'ee/geo_nodes_beta/components/details/secondary_node/geo_node_secondary_other_info.vue';
import {
  MOCK_PRIMARY_VERSION,
  MOCK_REPLICABLE_TYPES,
  MOCK_NODES,
} from 'ee_jest/geo_nodes_beta/mock_data';
import timeagoMixin from '~/vue_shared/mixins/timeago';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('GeoNodeSecondaryOtherInfo', () => {
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

    wrapper = shallowMount(GeoNodeSecondaryOtherInfo, {
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

  const findDbReplicationLag = () => wrapper.find('[data-testid="replicationLag"]');
  const findLastEvent = () => wrapper.find('[data-testid="lastEvent"]');
  const findLastCursorEvent = () => wrapper.find('[data-testid="lastCursorEvent"]');
  const findStorageShards = () => wrapper.find('[data-testid="storageShards"]');

  describe('template', () => {
    describe('always', () => {
      beforeEach(() => {
        createComponent();
      });

      it('renders the db replication lag', () => {
        expect(findDbReplicationLag().exists()).toBe(true);
      });

      it('renders the last event correctly', () => {
        const lastEventText = `${MOCK_NODES[1].lastEventId} (${timeagoMixin.methods.timeFormatted(
          MOCK_NODES[1].lastEventTimestamp * 1000,
        )})`;

        expect(findLastEvent().exists()).toBe(true);
        expect(findLastEvent().text()).toBe(lastEventText);
      });

      it('renders the last cursor event correctly', () => {
        const lastCursorEventText = `${
          MOCK_NODES[1].cursorLastEventId
        } (${timeagoMixin.methods.timeFormatted(MOCK_NODES[1].cursorLastEventTimestamp * 1000)})`;

        expect(findLastCursorEvent().exists()).toBe(true);
        expect(findLastCursorEvent().text()).toBe(lastCursorEventText);
      });

      it('renders the storage shards', () => {
        expect(findStorageShards().exists()).toBe(true);
      });
    });

    describe('conditionally', () => {
      describe.each`
        dbReplicationLagSeconds | text
        ${60}                   | ${'1m'}
        ${null}                 | ${'Unknown'}
      `(`db replication lag`, ({ dbReplicationLagSeconds, text }) => {
        beforeEach(() => {
          createComponent(null, { node: { dbReplicationLagSeconds } });
        });

        it(`renders correctly when dbReplicationLagSeconds is ${dbReplicationLagSeconds}`, () => {
          expect(findDbReplicationLag().text()).toBe(text);
        });
      });

      describe.each`
        storageShardsMatch | text                                                  | hasErrorClass
        ${true}            | ${'OK'}                                               | ${false}
        ${false}           | ${'Does not match the primary storage configuration'} | ${true}
      `(`storage shards`, ({ storageShardsMatch, text, hasErrorClass }) => {
        beforeEach(() => {
          createComponent(null, { node: { storageShardsMatch } });
        });

        it(`renders correctly when storageShardsMatch is ${storageShardsMatch}`, () => {
          expect(findStorageShards().text()).toBe(text);
          expect(findStorageShards().classes('gl-text-red-500')).toBe(hasErrorClass);
        });
      });
    });
  });
});
