import initLDAPGroupLinks from 'ee/groups/ldap_group_links';
import initLDAPGroupsSelect from 'ee/ldap_groups_select';

document.addEventListener('DOMContentLoaded', () => {
  initLDAPGroupsSelect();
  initLDAPGroupLinks();
});
