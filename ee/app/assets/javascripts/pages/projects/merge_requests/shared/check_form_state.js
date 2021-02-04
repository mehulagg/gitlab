import { serializeForm } from '~/lib/utils/forms';

const findForm = () => document.querySelector('.merge-request-form');

export default () => {
  const oldFormData = serializeForm(findForm());

  window.addEventListener('beforeunload', (e) => {
    const newFormData = serializeForm(findForm());

    if (oldFormData !== newFormData) {
      e.preventDefault();
    }
  });
};
