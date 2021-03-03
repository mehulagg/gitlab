/**
 * Given a SastCiConfigurationEntity, returns a SastCiConfigurationEntityInput
 * suitable for use in the configureSast GraphQL mutation.
 * @param {SastCiConfigurationEntity}
 * @returns {SastCiConfigurationEntityInput}
 */
export const toSastCiConfigurationEntityInput = ({ field, defaultValue, value }) => ({
  field,
  defaultValue,
  value,
});

/**
 * Given a SastCiConfigurationAnalyzersEntity, returns
 * a SastCiConfigurationAnalyzerEntityInput suitable for use in the
 * configureSast GraphQL mutation.
 * @param {SastCiConfigurationAnalyzersEntity}
 * @returns {SastCiConfigurationAnalyzerEntityInput}
 */
export const toSastCiConfigurationAnalyzerEntityInput = ({ name, enabled, variables }) => {
  const entity = { name, enabled };

  if (enabled && variables) {
    entity.variables = variables.nodes.map(toSastCiConfigurationEntityInput);
  }

  return entity;
};
