/**
 * Creates an array of objects matching the shape of a GraphQl
 * SastCiConfigurationEntity.
 *
 * @param {number} count - The number of entities to create.
 * @param {Object} [changes] - Object representing changes to apply to the
 *     generated entities.
 * @returns {Object[]}
 */
export const makeEntities = (count, changes) =>
  [...Array(count).keys()].map((i) => ({
    defaultValue: `defaultValue${i}`,
    description: `description${i}`,
    field: `field${i}`,
    label: `label${i}`,
    type: 'string',
    value: `value${i}`,
    size: `MEDIUM`,
    ...changes,
  }));

/**
 * Creates an array of objects matching the shape of a GraphQl
 * SastCiConfigurationAnalyzersEntity.
 *
 * @param {number} count - The number of entities to create.
 * @param {Object} [changes] - Object representing changes to apply to the
 *     generated entities.
 * @returns {Object[]}
 */
export const makeAnalyzerEntities = (count, changes, isEnabled = true) =>
  [...Array(count).keys()].map((i) => ({
    name: `nameValue${i}`,
    label: `label${i}`,
    description: `description${i}`,
    enabled: isEnabled,
    ...changes,
  }));

/**
 * Creates a mock SastCiConfiguration GraphQL object instance.
 *
 * @param {number} totalEntities - The total number of entities to create.
 * @returns {SastCiConfiguration}
 */
export const makeSastCiConfiguration = (analyzerEnabled = true) => {
  // Call makeEntities just once to ensure unique fields
  const entities = makeEntities(3);

  return {
    global: {
      nodes: [entities.shift()],
    },
    pipeline: {
      nodes: [entities.shift()],
    },
    analyzers: {
      nodes: makeAnalyzerEntities(
        1,
        {
          variables: {
            nodes: [entities.shift()],
          },
        },
        analyzerEnabled,
      ),
    },
  };
};
