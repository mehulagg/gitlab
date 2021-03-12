import { shallowMount } from '@vue/test-utils';
import GeoNodeProgressBar from 'ee/geo_nodes_beta/components/details/geo_node_progress_bar.vue';
import GeoNodeReplicationDetailsMobile from 'ee/geo_nodes_beta/components/details/secondary_node/geo_node_replication_details_mobile.vue';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';

describe('GeoNodeReplicationDetailsMobile', () => {
  let wrapper;

  const defaultProps = {
    replicationItems: [],
  };

  const createComponent = (props) => {
    wrapper = extendedWrapper(
      shallowMount(GeoNodeReplicationDetailsMobile, {
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

  const findReplicationDetailsHeader = () => wrapper.findByTestId('replication-details-header');
  const findReplicationDetailsHeaderItems = () => findReplicationDetailsHeader().findAll('span');
  const findReplicationDetailsItems = () => wrapper.findAllByTestId('replication-details-item');
  const findFirstReplicationDetailsItemSyncStatus = () =>
    extendedWrapper(findReplicationDetailsItems().at(0)).findByTestId('sync-status');
  const findFirstReplicationDetailsItemVerifStatus = () =>
    extendedWrapper(findReplicationDetailsItems().at(0)).findByTestId('verification-status');

  describe('template', () => {
    describe('always', () => {
      beforeEach(() => {
        createComponent();
      });

      it('renders the replication details header', () => {
        expect(findReplicationDetailsHeader().exists()).toBe(true);
      });

      it('renders the replication details header items correctly', () => {
        expect(findReplicationDetailsHeaderItems()).toHaveLength(2);
        expect(findReplicationDetailsHeaderItems().wrappers.map((w) => w.text())).toStrictEqual([
          'Component',
          'Status',
        ]);
      });
    });

    describe('replication details', () => {
      describe('when null', () => {
        beforeEach(() => {
          createComponent({ replicationItems: null });
        });

        it('does not render any replicable items', () => {
          expect(findReplicationDetailsItems()).toHaveLength(0);
        });
      });
    });

    describe.each`
      description                    | replicationItems                                                                                                                                          | renderSyncProgress | renderVerifProgress
      ${'with no data'}              | ${[{ dataTypeTitle: 'Test Title', component: 'Test Component', syncValues: null, verificationValues: null }]}                                             | ${false}           | ${false}
      ${'with no verification data'} | ${[{ dataTypeTitle: 'Test Title', component: 'Test Component', syncValues: { total: 100, success: 0 }, verificationValues: null }]}                       | ${true}            | ${false}
      ${'with no sync data'}         | ${[{ dataTypeTitle: 'Test Title', component: 'Test Component', syncValues: null, verificationValues: { total: 50, success: 50 } }]}                       | ${false}           | ${true}
      ${'with all data'}             | ${[{ dataTypeTitle: 'Test Title', component: 'Test Component', syncValues: { total: 100, success: 0 }, verificationValues: { total: 50, success: 50 } }]} | ${true}            | ${true}
    `('$description', ({ replicationItems, renderSyncProgress, renderVerifProgress }) => {
      beforeEach(() => {
        createComponent({ replicationItems });
      });

      it('renders sync progress correctly', () => {
        expect(findFirstReplicationDetailsItemSyncStatus().find(GeoNodeProgressBar).exists()).toBe(
          renderSyncProgress,
        );
        expect(findFirstReplicationDetailsItemSyncStatus().find('.gl-text-gray-400').exists()).toBe(
          !renderSyncProgress,
        );
      });

      it('renders verification progress correctly', () => {
        expect(findFirstReplicationDetailsItemVerifStatus().find(GeoNodeProgressBar).exists()).toBe(
          renderVerifProgress,
        );
        expect(
          findFirstReplicationDetailsItemVerifStatus().find('.gl-text-gray-400').exists(),
        ).toBe(!renderVerifProgress);
      });
    });
  });
});
