import { shallowMount } from '@vue/test-utils';
import Vue from 'vue';
import Vuex from 'vuex';
import GeoNodeReplicationCounts from 'ee/geo_nodes_beta/components/details/secondary_node/geo_node_replication_counts.vue';
import { REPOSITORY, BLOB } from 'ee/geo_nodes_beta/constants';
import {
  MOCK_NODES,
  MOCK_SECONDARY_SYNC_INFO,
  MOCK_PRIMARY_VERIFICATION_INFO,
} from 'ee_jest/geo_nodes_beta/mock_data';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';

Vue.use(Vuex);

describe('GeoNodeReplicationCounts', () => {
  let wrapper;

  const defaultProps = {
    node: MOCK_NODES[1],
  };

  const createComponent = (props, getters) => {
    const store = new Vuex.Store({
      getters: {
        syncInfo: () => () => MOCK_SECONDARY_SYNC_INFO,
        verificationInfo: () => () => MOCK_PRIMARY_VERIFICATION_INFO,
        ...getters,
      },
    });

    wrapper = extendedWrapper(
      shallowMount(GeoNodeReplicationCounts, {
        store,
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

  const findReplicationTypeSections = () => wrapper.findAllByTestId('replication-type');
  const findReplicationTypeSectionTitles = () =>
    findReplicationTypeSections().wrappers.map((w) =>
      extendedWrapper(w).findByTestId('replicable-title').text(),
    );
  const findReplicationTypeSyncData = () => wrapper.findAllByTestId('sync-data');
  const findReplicationTypeVerificationData = () => wrapper.findAllByTestId('verification-data');

  describe('template', () => {
    describe('always', () => {
      beforeEach(() => {
        createComponent();
      });

      it('renders a replication type section for Git and File', () => {
        expect(findReplicationTypeSections()).toHaveLength(2);
        expect(findReplicationTypeSectionTitles()).toStrictEqual(['Git', 'File']);
      });

      it('renders a sync section for Git and File', () => {
        expect(findReplicationTypeSyncData()).toHaveLength(2);
      });

      it('renders a verification section for Git and File', () => {
        expect(findReplicationTypeVerificationData()).toHaveLength(2);
      });
    });

    describe.each`
      description            | mockGetterData                                                                                                              | expectedUI
      ${'with no data'}      | ${[]}                                                                                                                       | ${{ GIT: { color: 'gl-bg-gray-200', text: 'N/A' }, FILE: { color: 'gl-bg-gray-200', text: 'N/A' } }}
      ${'with no File data'} | ${[{ dataType: REPOSITORY, values: { total: 100, success: 0 } }]}                                                           | ${{ GIT: { color: 'gl-bg-red-500', text: '0%' }, FILE: { color: 'gl-bg-gray-200', text: 'N/A' } }}
      ${'with no Git data'}  | ${[{ dataType: BLOB, values: { total: 100, success: 100 } }]}                                                               | ${{ GIT: { color: 'gl-bg-gray-200', text: 'N/A' }, FILE: { color: 'gl-bg-green-500', text: '100%' } }}
      ${'with all data'}     | ${[{ dataType: REPOSITORY, values: { total: 100, success: 0 } }, { dataType: BLOB, values: { total: 100, success: 100 } }]} | ${{ GIT: { color: 'gl-bg-red-500', text: '0%' }, FILE: { color: 'gl-bg-green-500', text: '100%' } }}
    `(`percentages`, ({ description, mockGetterData, expectedUI }) => {
      const gitReplicationSection = {};
      const fileReplicationSection = {};

      beforeEach(() => {
        createComponent(null, {
          syncInfo: () => () => mockGetterData,
          verificationInfo: () => () => mockGetterData,
        });

        gitReplicationSection.syncData = extendedWrapper(
          findReplicationTypeSections().at(0),
        ).findByTestId('sync-data');
        gitReplicationSection.verificationData = extendedWrapper(
          findReplicationTypeSections().at(0),
        ).findByTestId('verification-data');
        fileReplicationSection.syncData = extendedWrapper(
          findReplicationTypeSections().at(1),
        ).findByTestId('sync-data');
        fileReplicationSection.verificationData = extendedWrapper(
          findReplicationTypeSections().at(1),
        ).findByTestId('verification-data');
      });

      describe(`Git section ${description}`, () => {
        it('renders the correct sync data percentage color and text', () => {
          expect(
            gitReplicationSection.syncData.find('.gl-rounded-full').classes(expectedUI.GIT.color),
          ).toBe(true);
          expect(gitReplicationSection.syncData.find('span').text()).toBe(expectedUI.GIT.text);
        });

        it('renders the correct verification data percentage color and text', () => {
          expect(
            gitReplicationSection.verificationData
              .find('.gl-rounded-full')
              .classes(expectedUI.GIT.color),
          ).toBe(true);
          expect(gitReplicationSection.verificationData.find('span').text()).toBe(
            expectedUI.GIT.text,
          );
        });
      });

      describe(`File section ${description}`, () => {
        it('renders the correct sync data percentage color and text', () => {
          expect(
            fileReplicationSection.syncData.find('.gl-rounded-full').classes(expectedUI.FILE.color),
          ).toBe(true);
          expect(fileReplicationSection.syncData.find('span').text()).toBe(expectedUI.FILE.text);
        });

        it('renders the correct verification data percentage color and text', () => {
          expect(
            fileReplicationSection.verificationData
              .find('.gl-rounded-full')
              .classes(expectedUI.FILE.color),
          ).toBe(true);
          expect(fileReplicationSection.verificationData.find('span').text()).toBe(
            expectedUI.FILE.text,
          );
        });
      });
    });
  });
});
