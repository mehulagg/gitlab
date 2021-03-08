import '~/pages/admin/application_settings/index';
import $ from 'jquery';
import Api from '~/api';
import groupsSelect from '~/groups_select';
import axios from '~/lib/utils/axios_utils';
import { normalizeHeaders } from '~/lib/utils/common_utils';
import { loadCSSFile } from '~/lib/utils/css_utils';
import { s__ } from '~/locale';

const onLimitCheckboxChange = (checked, $limitByNamespaces, $limitByProjects) => {
  $limitByNamespaces.find('.select2').select2('data', null);
  $limitByNamespaces.find('.select2').select2('data', null);
  $limitByNamespaces.toggleClass('hidden', !checked);
  $limitByProjects.toggleClass('hidden', !checked);
};

const getDropdownConfig = (placeholder, apiPath, textProp) => ({
  placeholder,
  multiple: true,
  initSelection($el, callback) {
    callback($el.data('selected'));
  },
  ajax: {
    url: Api.buildUrl(apiPath),
    dataType: 'JSON',
    quietMillis: 250,
    data(search) {
      return {
        search,
      };
    },
    results(data) {
      return {
        results: data.map((entity) => ({
          id: entity.id,
          text: entity[textProp],
        })),
      };
    },
    transport(params, success, failure) {
      // eslint-disable-next-line promise/no-nesting
      return axios[params.type.toLowerCase()](params.url, {
        params: params.data,
      })
      .then((res) => {
        const results = res.data || [];
        const headers = normalizeHeaders(res.headers);
        const currentPage = parseInt(headers['X-PAGE'], 10) || 0;
        const totalPages = parseInt(headers['X-TOTAL-PAGES'], 10) || 0;
        const more = currentPage < totalPages;

        success({
          results,
          pagination: {
            more,
          },
        });
      })
      .catch(failure);
    },
  },
});

groupsSelect();

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
              Api.namespacesPath,
              'full_path',
            ),
          );

        $container
          .find('.js-elasticsearch-projects')
          .select2(
            getDropdownConfig(
              s__('Elastic|None. Select projects to index.'),
              Api.projectsPath,
              'name_with_namespace',
            ),
          );
      })
      .catch(() => {});
  })
  .catch(() => {});
