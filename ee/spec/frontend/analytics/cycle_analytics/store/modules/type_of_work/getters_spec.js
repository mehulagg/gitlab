import { tasksByTypeChartData } from 'ee/analytics/cycle_analytics/store/modules/type_of_work/getters';
import {
  rawTasksByTypeData,
  transformedTasksByTypeData,
  createdAfter,
  createdBefore,
} from '../../../mock_data';

describe('Type of work getters', () => {
  describe('tasksByTypeChartData', () => {
    const rootState = { createdAfter, createdBefore };
    describe('with data', () => {
      it('correctly transforms the raw task by type data', () => {
        expect(tasksByTypeChartData(rawTasksByTypeData, null, rootState)).toEqual(
          transformedTasksByTypeData,
        );
      });
    });

    describe('with no data', () => {
      it('returns all required properties', () => {
        expect(tasksByTypeChartData()).toEqual({ groupBy: [], data: [] });
      });
    });
  });
});
