import { createLocalVue, shallowMount } from '@vue/test-utils';
import Vuex from 'vuex';
import GeoNodeReplicationCounts from 'ee/geo_nodes_beta/components/details/secondary_node/geo_node_replication_counts.vue';
import { REPOSITORY, BLOB } from 'ee/geo_nodes_beta/constants';
import {
  MOCK_PRIMARY_VERSION,
  MOCK_REPLICABLE_TYPES,
  MOCK_NODES,
  MOCK_SECONDARY_SYNC_INFO,
  MOCK_PRIMARY_VERIFICATION_INFO,
} from 'ee_jest/geo_nodes_beta/mock_data';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('GeoNodeReplicationCounts', () => {
  let wrapper;

  const defaultProps = {
    node: MOCK_NODES[1],
  };

  const createComponent = (initialState, props, getters) => {
    const store = new Vuex.Store({
      state: {
        primaryVersion: MOCK_PRIMARY_VERSION.version,
        primaryRevision: MOCK_PRIMARY_VERSION.revision,
        replicableTypes: MOCK_REPLICABLE_TYPES,
        ...initialState,
      },
      getters: {
        syncInfo: () => () => MOCK_SECONDARY_SYNC_INFO,
        verificationInfo: () => () => MOCK_PRIMARY_VERIFICATION_INFO,
        ...getters,
      },
    });

    wrapper = shallowMount(GeoNodeReplicationCounts, {
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

  const findReplicationTypeSections = () => wrapper.findAll('[data-testid="replicationType"]');
  const findReplicationTypeSectionTitles = () =>
    findReplicationTypeSections().wrappers.map((w) =>
      w.find('[data-testid="replicableTitle"]').text(),
    );
  const findReplicationTypeSyncData = () => wrapper.findAll('[data-testid="syncData"]');
  const findReplicationTypeVerificationData = () =>
    wrapper.findAll('[data-testid="verificationData"]');

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
      let gitReplicationSection;
      let fileReplicationSection;

      beforeEach(() => {
        createComponent(null, null, {
          syncInfo: () => () => mockGetterData,
          verificationInfo: () => () => mockGetterData,
        });

        gitReplicationSection = findReplicationTypeSections().at(0);
        fileReplicationSection = findReplicationTypeSections().at(1);
      });

      describe(`Git section ${description}`, () => {
        it('renders the correct sync data percentage color and text', () => {
          expect(
            gitReplicationSection
              .find('[data-testid="syncData"] > div')
              .classes(expectedUI.GIT.color),
          ).toBe(true);
          expect(gitReplicationSection.find('[data-testid="syncData"] > span').text()).toBe(
            expectedUI.GIT.text,
          );
        });

        it('renders the correct verification data percentage color and text', () => {
          expect(
            gitReplicationSection
              .find('[data-testid="verificationData"] > div')
              .classes(expectedUI.GIT.color),
          ).toBe(true);
          expect(gitReplicationSection.find('[data-testid="verificationData"] > span').text()).toBe(
            expectedUI.GIT.text,
          );
        });
      });

      describe(`File section ${description}`, () => {
        it('renders the correct sync data percentage color and text', () => {
          expect(
            fileReplicationSection
              .find('[data-testid="syncData"] > div')
              .classes(expectedUI.FILE.color),
          ).toBe(true);
          expect(fileReplicationSection.find('[data-testid="syncData"] > span').text()).toBe(
            expectedUI.FILE.text,
          );
        });

        it('renders the correct verification data percentage color and text', () => {
          expect(
            fileReplicationSection
              .find('[data-testid="verificationData"] > div')
              .classes(expectedUI.FILE.color),
          ).toBe(true);
          expect(
            fileReplicationSection.find('[data-testid="verificationData"] > span').text(),
          ).toBe(expectedUI.FILE.text);
        });
      });
    });
  });
});
