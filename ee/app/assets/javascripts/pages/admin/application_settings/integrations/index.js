import 'select2/select2';
import $ from 'jquery';
import { s__ } from '~/locale';
import PersistentUserCallout from '~/persistent_user_callout';

const onLimitCheckboxChange = (checked, $limitByNamespaces, $limitByProjects) => {
  $limitByNamespaces.find('.select2').select2('data', null);
  $limitByNamespaces.find('.select2').select2('data', null);
  $limitByNamespaces.toggleClass('hidden', !checked);
  $limitByProjects.toggleClass('hidden', !checked);
};

const getDropdownConfig = (placeholder, url) => ({
  placeholder,
  multiple: true,
  initSelection($el, callback) {
    callback($el.data('selected'));
  },
  ajax: {
    url,
    dataType: 'JSON',
    quietMillis: 250,
    data(search) {
      return {
        search,
      };
    },
    results(data) {
      return {
        results: data.map(entity => ({
          id: entity.source_id,
          text: entity.path,
        })),
      };
    },
  },
});

document.addEventListener('DOMContentLoaded', () => {
  const callout = document.querySelector('.js-admin-integrations-moved');
  PersistentUserCallout.factory(callout);

  // ElasticSearch
  const $container = $('#js-elasticsearch-settings');

  $container
    .find('.js-limit-checkbox')
    .on('change', e =>
      onLimitCheckboxChange(
        e.currentTarget.checked,
        $container.find('.js-limit-namespaces'),
        $container.find('.js-limit-projects'),
      ),
    );

  $container
    .find('.js-elasticsearch-namespaces')
    .select2(
      getDropdownConfig(
        s__('Elastic|None. Select namespaces to index.'),
        '/-/autocomplete/namespace_routes.json',
      ),
    );

  $container
    .find('.js-elasticsearch-projects')
    .select2(
      getDropdownConfig(
        s__('Elastic|None. Select projects to index.'),
        '/-/autocomplete/project_routes.json',
      ),
    );
});
