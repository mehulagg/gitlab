import initLDAPGroupsSelect from 'ee/ldap_groups_select';
import initLDAPGroupLinks from 'ee/groups/ldap_group_links';
import { pipelineMinutes } from '../../users/pipeline_minutes';

initLDAPGroupsSelect();
initLDAPGroupLinks();
pipelineMinutes();
