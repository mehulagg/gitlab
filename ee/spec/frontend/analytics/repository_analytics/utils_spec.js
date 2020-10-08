import { getProjectIdQueryParams } from 'ee/analytics/repository_analytics/utils';

describe('group repository analytics util functions', () => {
  describe('getProjectIdQueryParams', () => {
    it('returns query param string project ids', () => {
      const projects = [{ id: 1 }, { id: 2 }];
      const expectedString = 'project_ids=1,2';

      expect(getProjectIdQueryParams(projects)).toBe(expectedString);
    });
  });
});
