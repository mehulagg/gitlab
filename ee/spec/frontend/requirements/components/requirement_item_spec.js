import { shallowMount } from '@vue/test-utils';

import { GlLink, GlDeprecatedButton, GlIcon } from '@gitlab/ui';
import RequirementItem from 'ee/requirements/components/requirement_item.vue';

import { requirement1, mockUserPermissions } from '../mock_data';

const createComponent = (requirement = requirement1) =>
  shallowMount(RequirementItem, {
    propsData: {
      requirement,
    },
  });

describe('RequirementItem', () => {
  let wrapper;

  beforeEach(() => {
    wrapper = createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
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

    describe('author', () => {
      it('returns value of `requirement.author`', () => {
        expect(wrapper.vm.author).toBe(requirement1.author);
      });
    });
  });

  describe('template', () => {
    it('renders component container element containing class `requirement`', () => {
      expect(wrapper.classes()).toContain('requirement');
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

    it('renders element containing requirement `Edit` button when `requirement.userPermissions.updateRequirement` is true', () => {
      const editButtonEl = wrapper.find('.controls .requirement-edit').find(GlDeprecatedButton);

      expect(editButtonEl.exists()).toBe(true);
      expect(editButtonEl.attributes('title')).toBe('Edit');
      expect(editButtonEl.find(GlIcon).exists()).toBe(true);
      expect(editButtonEl.find(GlIcon).props('name')).toBe('pencil');
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
      const archiveButtonEl = wrapper
        .find('.controls .requirement-archive')
        .find(GlDeprecatedButton);

      expect(archiveButtonEl.exists()).toBe(true);
      expect(archiveButtonEl.attributes('title')).toBe('Archive');
      expect(archiveButtonEl.find(GlIcon).exists()).toBe(true);
      expect(archiveButtonEl.find(GlIcon).props('name')).toBe('archive');
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

    it('renders element containing requirement updated at', () => {
      const updatedAtEl = wrapper.find('.issuable-meta .issuable-updated-at > span');

      expect(updatedAtEl.text()).toContain('updated');
      expect(updatedAtEl.text()).toContain('ago');
      expect(updatedAtEl.attributes('title')).toBe('Mar 20, 2020 8:09am GMT+0000');
    });
  });
});
