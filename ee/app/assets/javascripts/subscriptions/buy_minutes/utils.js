import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';

export function parseData(dataset) {
  const { ciMinutesPlans } = dataset;

  return {
    ciMinutesPlans: convertObjectPropsToCamelCase(JSON.parse(ciMinutesPlans), {
      deep: true,
    }),
  };
}
