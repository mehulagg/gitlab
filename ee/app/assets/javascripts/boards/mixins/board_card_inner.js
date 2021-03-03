import { isNumber } from 'lodash';

export default {
  methods: {
    validIssueWeight(issue) {
      if (issue && isNumber(issue.weight)) {
        return issue.weight >= 0;
      }

      return false;
    },
    filterByWeight(weight) {
      if (!this.updateFilters) return;

      const issueWeight = encodeURIComponent(weight);
      /* eslint-disable-next-line @gitlab/require-i18n-strings */
      const filter = `weight=${issueWeight}`;

      this.applyFilter(filter);
    },
  },
};
