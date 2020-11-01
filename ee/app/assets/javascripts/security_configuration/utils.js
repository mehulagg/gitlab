export const initFormField = ({ initialValue, isRequired = true, skipValidation = false }) => ({
  value: initialValue,
  isRequired,
  state: skipValidation ? true : null,
  feedback: null,
});
