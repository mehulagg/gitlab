import Vue from 'vue';
import FormErrors from '~/form_errors/components/form_errors.vue';

const mountFormErrors = ({ el }) => {
  const errors = JSON.parse(el.dataset.errors);

  return new Vue({
    el,
    name: 'FormErrorsApp',
    render(h) {
      return h(FormErrors, {
        props: {
          errors,
        },
      });
    },
  });
};

export default mountFormErrors;
