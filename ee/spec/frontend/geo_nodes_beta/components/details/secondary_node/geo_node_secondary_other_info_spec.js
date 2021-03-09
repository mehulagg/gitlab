import { shallowMount } from '@vue/test-utils';
import GeoNodeSecondaryOtherInfo from 'ee/geo_nodes_beta/components/details/secondary_node/geo_node_secondary_other_info.vue';
import { MOCK_NODES } from 'ee_jest/geo_nodes_beta/mock_data';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import timeagoMixin from '~/vue_shared/mixins/timeago';

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
