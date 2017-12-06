/* global Flash */
import {
  s__,
} from '../locale';
import '../flash';
import Api from '../api';

const onPrimaryCheckboxChange = function onPrimaryCheckboxChange(e, $namespaces) {
  const $namespacesSelect = $('.select2', $namespaces);

  $namespacesSelect.select2('data', null);
  $namespaces.toggleClass('hidden', e.currentTarget.checked);
};

export default function geoNodeForm($container) {
  const $namespaces = $('.js-hide-if-geo-primary', $container);
  const $primaryCheckbox = $('input[type="checkbox"]', $container);
  const $select2Dropdown = $('.js-geo-node-namespaces', $container);

  $primaryCheckbox.on('change', e =>
    onPrimaryCheckboxChange(e, $namespaces));

  $select2Dropdown.select2({
    placeholder: s__('Geo|Select groups to replicate.'),
    multiple: true,
    initSelection($el, callback) {
      callback($el.data('selected'));
    },
    ajax: {
      url: Api.buildUrl(Api.groupsPath),
      dataType: 'JSON',
      quietMillis: 250,
      data(search) {
        return {
          search,
        };
      },
      results(data) {
        return {
          results: data.map(group => ({
            id: group.id,
            text: group.full_name,
          })),
        };
      },
    },
  });
}
