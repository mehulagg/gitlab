import Vue from 'vue';
import ExpiresAtField from './components/expires_at_field.vue';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';

const initExpiresAtField = () => {
  // eslint-disable-next-line no-new
  const el = document.querySelector('.js-access-tokens-expires-at');

  if (!el) {
    return null;
  }

  const props = convertObjectPropsToCamelCase(JSON.parse(el.dataset.options));

  return new Vue({
    el,
    render(h) {
      return h(ExpiresAtField, {
        props,
      });
    },
  });
};

export default initExpiresAtField;
