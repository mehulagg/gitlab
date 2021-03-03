const isString = (value) => typeof value === 'string';
const isBoolean = (value) => typeof value === 'boolean';

export const isValidConfigurationEntity = (object) => {
  if (object == null) {
    return false;
  }

  const { field, type, description, label, value } = object;

  return (
    isString(field) &&
    isString(type) &&
    isString(description) &&
    isString(label) &&
    value !== undefined
  );
};

export const isValidAnalyzerEntity = (object) => {
  if (object == null) {
    return false;
  }

  const { name, label, enabled } = object;

  return isString(name) && isString(label) && isBoolean(enabled);
};
