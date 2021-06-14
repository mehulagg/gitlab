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
      isTimeValid: parseInt(rule.elapsedTimeSeconds, 10) >= 0,
      isScheduleValid: Boolean(rule.oncallScheduleIid),
    };
  });
};
