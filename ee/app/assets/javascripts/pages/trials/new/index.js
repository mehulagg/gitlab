import axios from 'axios';
import { __ } from '~/locale';
import Flash from '~/flash';

document.addEventListener('DOMContentLoaded', () => {
  const selectElement = document.querySelector('#country_select');

  axios
    .get('/-/countries')
    .then(({ data }) => {
      // fill #country_select element with array of <option>s
      data.forEach(([name, code]) => {
        const option = document.createElement('option');
        option.value = code;
        option.text = name;

        selectElement.appendChild(option);
      });
    })
    .catch(() => new Flash(__('Error loading countries data.')));
});
