import $ from 'jquery';
import axios from '~/lib/utils/axios_utils';
import { __ } from '~/locale';
import { deprecatedCreateFlash as Flash } from '~/flash';

const selectElement = document.getElementById('country_select');
const { countriesEndPoint, selectedOption } = selectElement.dataset;

axios
  .get(countriesEndPoint)
  .then(({ data }) => {
    // fill #country_select element with array of <option>s
    data.forEach(([name, code]) => {
      const option = document.createElement('option');
      option.value = code;
      option.text = name;

      selectElement.appendChild(option);
    });
    $(selectElement)
      .val(selectedOption)
      .trigger('change.select2');
  })
  .catch(() => new Flash(__('Error loading countries data.')));
