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

export const serializeRules = (rules) => {
  return rules.map((rule) => {
    const { elapsedTimeMinutes, ...ruleParams } = rule;

    return {
      ...ruleParams,
      elapsedTimeSeconds: rule.elapsedTimeMinutes * 60,
    };
  });
};

export const parsePolicy = (policy) => {
  return {
    ...policy,
    rules: policy.rules.map((rule) => {
      const { elapsedTimeSeconds, ...ruleParams } = rule;

      return {
        ...ruleParams,
        elapsedTimeMinutes: rule.elapsedTimeSeconds / 60,
      };
    }),
  };
};
