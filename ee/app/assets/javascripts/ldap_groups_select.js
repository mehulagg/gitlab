/* eslint-disable consistent-return, func-names */

import $ from 'jquery';
import Api from 'ee/api';
import { __ } from '~/locale';
import { loadCSSFile } from '~/lib/utils/css_utils';

export default function initLDAPGroupsSelect() {
  const ldapGroupResult = function(group) {
    return group.cn;
  };
  const groupFormatSelection = function(group) {
    return group.cn;
  };
  import(/* webpackChunkName: 'select2' */ 'select2/select2')
    .then(() => {
      // eslint-disable-next-line promise/no-nesting
      loadCSSFile(gon.select2_css_path)
        .then(() => {
          $('.ajax-ldap-groups-select').each((i, select) => {
            $(select).select2({
              id(group) {
                return group.cn;
              },
              placeholder: __('Search for a LDAP group'),
              minimumInputLength: 1,
              query(query) {
                const provider = $('#ldap_group_link_provider').val();
                return Api.ldapGroups(query.term, provider, groups => {
                  const data = {
                    results: groups,
                  };
                  return query.callback(data);
                });
              },
              initSelection(element, callback) {
                const id = $(element).val();
                if (id !== '') {
                  return callback({
                    cn: id,
                  });
                }
              },
              formatResult: ldapGroupResult,
              formatSelection: groupFormatSelection,
              dropdownCssClass: 'ajax-groups-dropdown',
              formatNoMatches() {
                return __('Match not found; try refining your search query.');
              },
            });
          });
        })
        .catch(() => {});
    })
    .catch(() => {});

  $('#ldap_group_link_provider').on('change', () => {
    $('.ajax-ldap-groups-select').select2('data', null);
  });
}
