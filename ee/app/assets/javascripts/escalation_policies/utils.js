/**
 * Returns `true` for non-empty string, otherwise returns `false`
 * @param {String} name
 *
 * @returns {Boolean}
 */
export const isNameFieldValid = (name) => {
  return Boolean(name?.length);
};

/**
 * Returns an array of booleans  - validation state for each rule
 * @param {Array} rules
 *
 * @returns {Array}
 */
export const getRulesValidationState = (rules) => {
  return rules.map((rule) => {
    return {
      isTimeValid: parseInt(rule.elapsedTimeMinutes, 10) >= 0,
      isScheduleValid: Boolean(rule.oncallScheduleIid),
    };
  });
};

/**
 * Serializes a rule by converting elapsed minutes to seconds
 * @param {Object} rule
 *
 * @returns {Object} rule
 */
export const serializeRule = ({ elapsedTimeMinutes, ...ruleParams }) => ({
  ...ruleParams,
  elapsedTimeSeconds: elapsedTimeMinutes * 60,
});

/**
 * Parses a policy by converting elapsed seconds to minutes
 * @param {Object} policy
 *
 * @returns {Object} policy
 */
export const parsePolicy = (policy) => ({
  ...policy,
  rules: policy.rules.map(({ elapsedTimeSeconds, ...ruleParams }) => ({
    ...ruleParams,
    elapsedTimeMinutes: elapsedTimeSeconds / 60,
  })),
});
