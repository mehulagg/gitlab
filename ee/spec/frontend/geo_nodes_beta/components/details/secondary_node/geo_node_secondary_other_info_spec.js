import { shallowMount } from '@vue/test-utils';
import GeoNodeSecondaryOtherInfo from 'ee/geo_nodes_beta/components/details/secondary_node/geo_node_secondary_other_info.vue';
import { MOCK_NODES } from 'ee_jest/geo_nodes_beta/mock_data';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';

describe('GeoNodeSecondaryOtherInfo', () => {
  let wrapper;

  const defaultProps = {
    node: MOCK_NODES[1],
  };

  const createComponent = (props) => {
    wrapper = extendedWrapper(
      shallowMount(GeoNodeSecondaryOtherInfo, {
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

  const findDbReplicationLag = () => wrapper.findByTestId('replication-lag');
  const findLastEvent = () => wrapper.findByTestId('last-event');
  const findLastCursorEvent = () => wrapper.findByTestId('last-cursor-event');
  const findStorageShards = () => wrapper.findByTestId('storage-shards');

  describe('template', () => {
    describe('always', () => {
      beforeEach(() => {
        createComponent();
      });

      it('renders the db replication lag', () => {
        expect(findDbReplicationLag().exists()).toBe(true);
      });

      it('renders the last event correctly', () => {
        expect(findLastEvent().exists()).toBe(true);
        expect(findLastEvent().props('time')).toBe(
          new Date(MOCK_NODES[1].lastEventTimestamp * 1000).toString(),
        );
      });

      it('renders the last cursor event correctly', () => {
        expect(findLastCursorEvent().exists()).toBe(true);
        expect(findLastCursorEvent().props('time')).toBe(
          new Date(MOCK_NODES[1].cursorLastEventTimestamp * 1000).toString(),
        );
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
          createComponent({ node: { dbReplicationLagSeconds } });
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
          createComponent({ node: { storageShardsMatch } });
        });

        it(`renders correctly when storageShardsMatch is ${storageShardsMatch}`, () => {
          expect(findStorageShards().text()).toBe(text);
          expect(findStorageShards().classes('gl-text-red-500')).toBe(hasErrorClass);
        });
      });
    });
  });
});
