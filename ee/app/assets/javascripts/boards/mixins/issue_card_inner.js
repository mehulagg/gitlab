import { isNumber } from 'lodash';

export default {
  computed: {
    validIssueWeight() {
      if (this.issue && isNumber(this.issue.weight)) {
        return this.issue.weight >= 0;
      }

      return false;
    },
  },
  methods: {
    filterByWeight(weight) {
      if (!this.updateFilters) return;

      const issueWeight = encodeURIComponent(weight);
      /* eslint-disable-next-line @gitlab/require-i18n-strings */
      const filter = `weight=${issueWeight}`;

      this.applyFilter(filter);
    },
  },
};
