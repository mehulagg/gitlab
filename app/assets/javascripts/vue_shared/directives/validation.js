import { s__ } from '~/locale';

const isURLTypeMismatch = el => el.type === 'url' && el.validity.typeMismatch;

const getFeedback = el => {
  return isURLTypeMismatch(el)
    ? s__('DastProfiles|Please enter a valid URL format, ex: http://www.example.com/home')
    : el.validationMessage;
};

export default {
  bind(el, binding, vnode) {
    const { modifiers } = binding;
    const { context } = vnode;

    const handler = () => {
      const { name, form: formEl } = el;
      if (formEl) {
        context.form.isValid = formEl.checkValidity();
      }
      context.form[name].state = el.checkValidity();
      context.form[name].feedback = getFeedback(el);
    };

    context.$watch(
      'form.showValidation',
      showValidation => {
        if (showValidation) {
          handler();
        }
      },
      { immediate: true },
    );
    el.addEventListener(modifiers.blur ? 'blur' : 'input', handler);
  },
};
