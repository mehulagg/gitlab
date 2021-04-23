import $ from 'jquery';
import initIntegrationsList from '~/integrations/index';
import { loadCSSFile } from '~/lib/utils/css_utils';
import { select2AxiosTransport } from '~/lib/utils/select2_utils';
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
        results: data.results.map((entity) => ({
          id: entity.source_id,
          text: entity.path,
        })),
      };
    },
    transport: select2AxiosTransport,
  },
});

const callout = document.querySelector('.js-admin-integrations-moved');
PersistentUserCallout.factory(callout);

initIntegrationsList();

// ElasticSearch
const $container = $('#js-elasticsearch-settings');

$container
  .find('.js-limit-checkbox')
  .on('change', (e) =>
    onLimitCheckboxChange(
      e.currentTarget.checked,
      $container.find('.js-limit-namespaces'),
      $container.find('.js-limit-projects'),
    ),
  );

import(/* webpackChunkName: 'select2' */ 'select2/select2')
  .then(() => {
    // eslint-disable-next-line promise/no-nesting
    loadCSSFile(gon.select2_css_path)
      .then(() => {
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
      })
      .catch(() => {});
  })
  .catch(() => {});
