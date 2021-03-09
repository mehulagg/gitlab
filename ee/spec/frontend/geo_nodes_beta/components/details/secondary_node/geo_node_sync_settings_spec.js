import { shallowMount } from '@vue/test-utils';
import GeoNodeSyncSettings from 'ee/geo_nodes_beta/components/details/secondary_node/geo_node_sync_settings.vue';
import { MOCK_NODES } from 'ee_jest/geo_nodes_beta/mock_data';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';

describe('GeoNodeSyncSettings', () => {
  let wrapper;

  const defaultProps = {
    node: MOCK_NODES[1],
  };

  const createComponent = (props) => {
    wrapper = extendedWrapper(
      shallowMount(GeoNodeSyncSettings, {
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

  const findSyncType = () => wrapper.findByTestId('sync-type');
  const findSyncStatusEventInfo = () => wrapper.findByTestId('sync-status-event-info');

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
          createComponent({ node: { selectiveSyncType } });
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
          createComponent({ node: { ...eventData } });
        });

        describe(`when eventData ${shouldRender ? 'exists' : 'does not exist'}`, () => {
          it(`does ${shouldRender ? '' : 'not '}render event info`, () => {
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
