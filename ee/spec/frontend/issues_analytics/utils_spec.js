import { transformFilters } from 'ee/issues_analytics/utils';

const originalFilters = {
  label_name: ['one', 'two'],
  milestone_title: 'title',
  author_username: 'root',
};
const tranformedFilters = { labels: ['one', 'two'], milestone: 'title', author_username: 'root' };

describe('issue analytics utils', () => {
  describe('transformFilters', () => {
    it('transforms the object keys as expected', () => {
      const filters = transformFilters(originalFilters);

      expect(filters).toStrictEqual(tranformedFilters);
    });
  });
});
