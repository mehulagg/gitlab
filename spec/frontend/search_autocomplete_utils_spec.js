import {
  isInGroupsPage,
  isInProjectPage,
  getGroupSlug,
  getProjectSlug,
} from '~/search_autocomplete_utils';

describe('search_autocomplete_utils', () => {
  let originalBody;

  beforeEach(() => {
    originalBody = document.body;
    document.body = document.createElement('body');
  });

  afterEach(() => {
    document.body = originalBody;
  });

  describe('isInGroupsPage', () => {
    it('returns true in a groups list page', () => {
      document.body.dataset.page = 'groups:index';

      expect(isInGroupsPage()).toBe(true);
    });

    it('returns true in a groups details page', () => {
      document.body.dataset.page = 'groups:show';

      expect(isInGroupsPage()).toBe(true);
    });

    it('returns false for non-groups page', () => {
      document.body.dataset.page = 'projects:show';

      expect(isInGroupsPage()).toBe(false);
    });
  });

  describe('isInProjectPage', () => {
    it('returns true in a groups list page', () => {
      document.body.dataset.page = 'projects:index';

      expect(isInProjectPage()).toBe(true);
    });

    it('returns true in a groups details page', () => {
      document.body.dataset.page = 'projects:show';

      expect(isInProjectPage()).toBe(true);
    });

    it('returns false for groups details page', () => {
      document.body.dataset.page = 'groups:show';

      expect(isInProjectPage()).toBe(false);
    });
  });

  describe('getProjectSlug', () => {
    it('returns null when no project is present or on project page', () => {
      expect(getProjectSlug()).toBe(null);
    });

    it('returns null when not on project page', () => {
      document.body.dataset.project = 'gitlab';

      expect(getProjectSlug()).toBe(null);
    });

    it('returns null when project is missing', () => {
      document.body.dataset.page = 'projects';

      expect(getProjectSlug()).toBe(undefined);
    });

    it('returns project', () => {
      document.body.dataset.page = 'projects';
      document.body.dataset.project = 'gitlab';

      expect(getProjectSlug()).toBe('gitlab');
    });

    it('returns project in edit page', () => {
      document.body.dataset.page = 'projects:edit';
      document.body.dataset.project = 'gitlab';

      expect(getProjectSlug()).toBe('gitlab');
    });
  });

  describe('getGroupSlug', () => {
    it('returns null when no group is present or on group page', () => {
      expect(getGroupSlug()).toBe(null);
    });

    it('returns null when not on group page', () => {
      document.body.dataset.group = 'gitlab-org';

      expect(getGroupSlug()).toBe(null);
    });

    it('returns null when group is missing', () => {
      document.body.dataset.page = 'groups';

      expect(getGroupSlug()).toBe(undefined);
    });

    it('returns null when project is missing', () => {
      document.body.dataset.page = 'project';

      expect(getGroupSlug()).toBe(null);
    });

    it('returns group in group page', () => {
      document.body.dataset.page = 'groups';
      document.body.dataset.group = 'gitlab-org';

      expect(getGroupSlug()).toBe('gitlab-org');
    });

    it('returns group in group edit page', () => {
      document.body.dataset.page = 'groups:edit';
      document.body.dataset.group = 'gitlab-org';

      expect(getGroupSlug()).toBe('gitlab-org');
    });

    it('returns group in project page', () => {
      document.body.dataset.page = 'projects';
      document.body.dataset.group = 'gitlab-org';

      expect(getGroupSlug()).toBe('gitlab-org');
    });

    it('returns group in project edit page', () => {
      document.body.dataset.page = 'projects:edit';
      document.body.dataset.group = 'gitlab-org';

      expect(getGroupSlug()).toBe('gitlab-org');
    });
  });
});
