import { s__ } from '~/locale';

const isURLTypeMismatch = el => el.type === 'url' && el.validity.typeMismatch;

const getFeedback = el => {
  return isURLTypeMismatch(el)
    ? s__('DastProfiles|Please enter a valid URL format, ex: http://www.example.com/home')
    : el.validationMessage;
};

const createValidator = (el, context) => () => {
  const { form } = context;
  const { name, form: formEl } = el;
  if (formEl) {
    form.state = formEl.checkValidity();
  }
  form[name].state = el.checkValidity();
  form[name].feedback = getFeedback(el);
};

export default {
  bind(el, binding, { context }) {
    const {
      modifiers,
      value: { showValidation },
    } = binding;

    const validate = createValidator(el, context);

    if (showValidation) {
      validate();
    }
    el.addEventListener(modifiers.blur ? 'blur' : 'input', validate);
  },
  update(el, binding, { context }) {
    const {
      value: { showValidation },
    } = binding;

    if (showValidation) {
      createValidator(el, context)();
    }
  },
};
