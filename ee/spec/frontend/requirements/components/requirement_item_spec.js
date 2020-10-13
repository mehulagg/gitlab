import { shallowMount } from '@vue/test-utils';

import { GlLink, GlButton } from '@gitlab/ui';
import RequirementItem from 'ee/requirements/components/requirement_item.vue';
import RequirementStatusBadge from 'ee/requirements/components/requirement_status_badge.vue';

import {
  requirement1,
  requirementArchived,
  mockUserPermissions,
  mockTestReport,
} from '../mock_data';

const createComponent = (requirement = requirement1) =>
  shallowMount(RequirementItem, {
    propsData: {
      requirement,
    },
  });

describe('RequirementItem', () => {
  let wrapper;
  let wrapperArchived;

  beforeEach(() => {
    wrapper = createComponent();
    wrapperArchived = createComponent(requirementArchived);
  });

  afterEach(() => {
    wrapper.destroy();
    wrapperArchived.destroy();
  });

  describe('computed', () => {
    describe('reference', () => {
      it('returns string containing `requirement.iid` prefixed with "REQ-"', () => {
        expect(wrapper.vm.reference).toBe(`REQ-${requirement1.iid}`);
      });
    });

    describe('canUpdate', () => {
      it('returns value of `requirement.userPermissions.updateRequirement`', () => {
        expect(wrapper.vm.canUpdate).toBe(requirement1.userPermissions.updateRequirement);
      });
    });

    describe('canArchive', () => {
      it('returns value of `requirement.userPermissions.updateRequirement`', () => {
        expect(wrapper.vm.canArchive).toBe(requirement1.userPermissions.adminRequirement);
      });
    });

    describe('createdAt', () => {
      it('returns timeago-style string representing `requirement.createdAt`', () => {
        // We don't have to be accurate here as it is already covered in rspecs
        expect(wrapper.vm.createdAt).toContain('created');
        expect(wrapper.vm.createdAt).toContain('ago');
      });
    });

    describe('updatedAt', () => {
      it('returns timeago-style string representing `requirement.updatedAt`', () => {
        // We don't have to be accurate here as it is already covered in rspecs
        expect(wrapper.vm.updatedAt).toContain('updated');
        expect(wrapper.vm.updatedAt).toContain('ago');
      });
    });

    describe('isArchived', () => {
      it('returns `true` when current requirement is archived', () => {
        expect(wrapperArchived.vm.isArchived).toBe(true);
      });

      it('returns `false` when current requirement is archived', () => {
        expect(wrapper.vm.isArchived).toBe(false);
      });
    });

    describe('author', () => {
      it('returns value of `requirement.author`', () => {
        expect(wrapper.vm.author).toBe(requirement1.author);
      });
    });

    describe('testReport', () => {
      it('returns testReport object from reports array within `requirement`', () => {
        expect(wrapper.vm.testReport).toBe(mockTestReport);
      });
    });
  });

  describe('methods', () => {
    describe('handleArchiveClick', () => {
      it('emits `archiveClick` event on component with object containing `requirement.iid` & `state` as "ARCHIVED" as param', () => {
        wrapper.vm.handleArchiveClick();

        return wrapper.vm.$nextTick(() => {
          expect(wrapper.emitted('archiveClick')).toBeTruthy();
          expect(wrapper.emitted('archiveClick')[0]).toEqual([
            {
              iid: requirement1.iid,
              state: 'ARCHIVED',
            },
          ]);
        });
      });
    });

    describe('handleReopenClick', () => {
      it('emits `reopenClick` event on component with object containing `requirement.iid` & `state` as "OPENED" as param', () => {
        wrapperArchived.vm.handleReopenClick();

        return wrapperArchived.vm.$nextTick(() => {
          expect(wrapperArchived.emitted('reopenClick')).toBeTruthy();
          expect(wrapperArchived.emitted('reopenClick')[0]).toEqual([
            {
              iid: requirementArchived.iid,
              state: 'OPENED',
            },
          ]);
        });
      });
    });
  });

  describe('template', () => {
    it('renders component container element containing class `requirement`', () => {
      expect(wrapper.classes()).toContain('requirement');
    });

    it('renders component container element with class `disabled-content` when `stateChangeRequestActive` prop is true', () => {
      wrapper.setProps({
        stateChangeRequestActive: true,
      });

      return wrapper.vm.$nextTick(() => {
        expect(wrapper.classes()).toContain('disabled-content');
      });
    });

    it('renders element containing requirement reference', () => {
      expect(wrapper.find('.issuable-reference').text()).toBe(`REQ-${requirement1.iid}`);
    });

    it('renders element containing requirement title', () => {
      expect(wrapper.find('.issue-title-text').text()).toBe(requirement1.title);
    });

    it('renders element containing requirement created at', () => {
      const createdAtEl = wrapper.find('.issuable-info .issuable-authored > span');

      expect(createdAtEl.text()).toContain('created');
      expect(createdAtEl.text()).toContain('ago');
      expect(createdAtEl.attributes('title')).toBe('Mar 19, 2020 8:09am GMT+0000');
    });

    it('renders element containing requirement author information', () => {
      const authorEl = wrapper.find(GlLink);

      expect(authorEl.attributes('href')).toBe(requirement1.author.webUrl);
      expect(authorEl.find('.author').text()).toBe(requirement1.author.name);
    });

    it('renders element containing requirement updated at', () => {
      const updatedAtEl = wrapper.find('.issuable-info .issuable-updated-at');

      expect(updatedAtEl.text()).toContain('updated');
      expect(updatedAtEl.text()).toContain('ago');
      expect(updatedAtEl.attributes('title')).toBe('Mar 20, 2020 8:09am GMT+0000');
    });

    it('renders requirement-status-badge component', () => {
      const statusBadgeElSm = wrapper.find('.issuable-main-info').find(RequirementStatusBadge);
      const statusBadgeElMd = wrapper.find('.controls').find(RequirementStatusBadge);

      expect(statusBadgeElSm.exists()).toBe(true);
      expect(statusBadgeElMd.exists()).toBe(true);
      expect(statusBadgeElSm.props('testReport')).toBe(mockTestReport);
      expect(statusBadgeElMd.props('testReport')).toBe(mockTestReport);
      expect(statusBadgeElMd.props('elementType')).toBe('li');
    });

    it('renders element containing requirement `Edit` button when `requirement.userPermissions.updateRequirement` is true', () => {
      const editButtonEl = wrapper.find('.controls .requirement-edit').find(GlButton);

      expect(editButtonEl.exists()).toBe(true);
      expect(editButtonEl.attributes('title')).toBe('Edit');
    });

    it('does not render element containing requirement `Edit` button when `requirement.userPermissions.updateRequirement` is false', () => {
      const wrapperNoEdit = createComponent({
        ...requirement1,
        userPermissions: {
          ...mockUserPermissions,
          updateRequirement: false,
        },
      });

      expect(wrapperNoEdit.find('.controls .requirement-edit').exists()).toBe(false);

      wrapperNoEdit.destroy();
    });

    it('renders element containing requirement `Archive` button when `requirement.userPermissions.adminRequirement` is true', () => {
      const archiveButtonEl = wrapper.find('.controls .requirement-archive').find(GlButton);

      expect(archiveButtonEl.exists()).toBe(true);
      expect(archiveButtonEl.attributes('title')).toBe('Archive');
    });

    it('does not render element containing requirement `Archive` button when `requirement.userPermissions.adminRequirement` is false', () => {
      const wrapperNoArchive = createComponent({
        ...requirement1,
        userPermissions: {
          ...mockUserPermissions,
          adminRequirement: false,
        },
      });

      expect(wrapperNoArchive.find('.controls .requirement-archive').exists()).toBe(false);

      wrapperNoArchive.destroy();
    });

    it('renders `Reopen` button when current requirement is archived and `requirement.userPermissions.adminRequirement` is true', () => {
      const reopenButton = wrapperArchived.find('.requirement-reopen').find(GlButton);

      expect(reopenButton.exists()).toBe(true);
      expect(reopenButton.props('loading')).toBe(false);
      expect(reopenButton.text()).toBe('Reopen');
    });

    it('does not render `Reopen` button when current requirement is archived and `requirement.userPermissions.adminRequirement` is false', () => {
      wrapperArchived.setProps({
        requirement: {
          ...requirementArchived,
          userPermissions: {
            ...mockUserPermissions,
            adminRequirement: false,
          },
        },
      });

      return wrapperArchived.vm.$nextTick(() => {
        expect(wrapperArchived.find('.controls .requirement-reopen').exists()).toBe(false);
      });
    });
  });
});
