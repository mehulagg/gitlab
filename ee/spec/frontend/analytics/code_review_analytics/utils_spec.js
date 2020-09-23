import transformFilters from 'ee/analytics/code_review_analytics/utils';

describe('CodeReviewAnalytics utils', () => {
  describe('transformFilters', () => {
    describe('when milestone_title and label_name filters are present', () => {
      it('creates a selectedMilestone object and a selectedLabels array', () => {
        const filters = {
          milestone_title: 'my-milestone',
          label_name: ['my-label', 'another label'],
        };
        expect(transformFilters(filters)).toEqual({
          selectedMilestone: { value: 'my-milestone', operator: '=' },
          selectedLabels: [
            { value: 'my-label', operator: '=' },
            { value: 'another label', operator: '=' },
          ],
        });
      });
    });

    describe('when "not[label_name]" filter is present', () => {
      describe('and "label_name" filter is present', () => {
        it('applies the "!=" operator to the selectedLabels array', () => {
          const filters = {
            milestone_title: 'my-milestone',
            label_name: ['my-label'],
            'not[label_name]': ['another label'],
          };
          expect(transformFilters(filters)).toEqual({
            selectedMilestone: { value: 'my-milestone', operator: '=' },
            selectedLabels: [
              { value: 'my-label', operator: '=' },
              { value: 'another label', operator: '!=' },
            ],
          });
        });
      });

      describe('and "label_name" filter is missing', () => {
        it('applies the "!=" operator to the selectedLabels array', () => {
          const filters = {
            'not[label_name]': ['another label'],
          };
          expect(transformFilters(filters)).toEqual({
            selectedLabels: [{ value: 'another label', operator: '!=' }],
            selectedMilestone: null,
          });
        });
      });
    });

    describe('when "not[milestone_title]" filter is present', () => {
      it('applies the "!=" operator to the selectedMilestone object', () => {
        const filters = {
          'not[milestone_title]': 'my-milestone',
          label_name: ['my-label'],
        };
        expect(transformFilters(filters)).toEqual({
          selectedMilestone: { value: 'my-milestone', operator: '!=' },
          selectedLabels: [{ value: 'my-label', operator: '=' }],
        });
      });
    });
  });
});
