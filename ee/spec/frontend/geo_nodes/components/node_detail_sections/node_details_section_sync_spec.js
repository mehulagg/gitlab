import { shallowMount } from '@vue/test-utils';

import NodeDetailsSectionSyncComponent from 'ee/geo_nodes/components/node_detail_sections/node_details_section_sync.vue';
import SectionRevealButton from 'ee/geo_nodes/components/node_detail_sections/section_reveal_button.vue';

import { mockNode, mockNodeDetails } from '../../mock_data';

describe('NodeDetailsSectionSync', () => {
  let wrapper;

  const propsData = {
    node: mockNode,
    nodeDetails: mockNodeDetails,
  };

  const createComponent = () => {
    wrapper = shallowMount(NodeDetailsSectionSyncComponent, {
      stubs: {
        geoNodeSyncProgress: true,
      },
      propsData,
    });
  };

  beforeEach(() => {
    gon.features = gon.features || {};
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('data', () => {
    it('returns default data props', () => {
      expect(wrapper.vm.showSectionItems).toBe(false);
      expect(Array.isArray(wrapper.vm.nodeDetailItems)).toBe(true);
      expect(wrapper.vm.nodeDetailItems.length).toBeGreaterThan(0);
    });
  });

  describe('methods', () => {
    describe('syncSettings', () => {
      it('returns sync settings object', () => {
        wrapper.vm.nodeDetails.syncStatusUnavailable = true;
        return wrapper.vm.$nextTick(() => {
          const syncSettings = wrapper.vm.syncSettings();
          expect(syncSettings.syncStatusUnavailable).toBe(true);
          expect(syncSettings.lastEvent).toBe(mockNodeDetails.lastEvent);
          expect(syncSettings.cursorLastEvent).toBe(mockNodeDetails.cursorLastEvent);
        });
      });
    });

    describe('dbReplicationLag', () => {
      it('returns DB replication lag time duration', () => {
        expect(wrapper.vm.dbReplicationLag()).toBe('0m');
      });

      it('returns `Unknown` when `dbReplicationLag` is null', () => {
        wrapper.vm.nodeDetails.dbReplicationLag = null;
        return wrapper.vm.$nextTick(() => {
          expect(wrapper.vm.dbReplicationLag()).toBe('Unknown');
        });
      });
    });

    describe('lastEventStatus', () => {
      it('returns event status object', () => {
        expect(wrapper.vm.lastEventStatus().eventId).toBe(mockNodeDetails.lastEvent.id);
        expect(wrapper.vm.lastEventStatus().eventTimeStamp).toBe(
          mockNodeDetails.lastEvent.timeStamp,
        );
      });
    });

    describe('cursorLastEventStatus', () => {
      it('returns event status object', () => {
        expect(wrapper.vm.cursorLastEventStatus().eventId).toBe(mockNodeDetails.cursorLastEvent.id);
        expect(wrapper.vm.cursorLastEventStatus().eventTimeStamp).toBe(
          mockNodeDetails.cursorLastEvent.timeStamp,
        );
      });
    });

    describe.each`
      nodeDetailItem                                        | path
      ${{ secondaryView: false, itemName: '' }}             | ${''}
      ${{ secondaryView: true, itemName: 'repositories' }}  | ${`${mockNode.url}admin/geo/replication/projects`}
      ${{ secondaryView: true, itemName: 'attachments' }}   | ${`${mockNode.url}admin/geo/replication/uploads`}
      ${{ secondaryView: true, itemName: 'package_files' }} | ${`${mockNode.url}admin/geo/replication/package_files`}
    `(`detailsPath`, ({ nodeDetailItem, path }) => {
      describe(`when detail item is ${nodeDetailItem.itemName}`, () => {
        let detailPath = '';

        beforeEach(() => {
          detailPath = wrapper.vm.detailsPath(nodeDetailItem);
        });

        it(`returns the correct path`, () => {
          expect(detailPath).toBe(path);
        });
      });
    });
  });

  describe('template', () => {
    it('renders component container element', () => {
      expect(wrapper.vm.$el.classList.contains('sync-section')).toBe(true);
    });

    it('renders show section button element', () => {
      expect(wrapper.find(SectionRevealButton).exists()).toBeTruthy();
      expect(wrapper.find(SectionRevealButton).attributes('buttontitle')).toBe('Sync information');
    });

    it('renders section items container element', () => {
      wrapper.vm.showSectionItems = true;
      return wrapper.vm.$nextTick(() => {
        expect(wrapper.vm.$el.querySelector('.section-items-container')).not.toBeNull();
      });
    });
  });
});
