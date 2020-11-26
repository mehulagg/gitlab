import initLDAPGroupLinks from 'ee/groups/ldap_group_links';
import initLDAPGroupsSelect from 'ee/ldap_groups_select';
import { pipelineMinutes } from '../../users/pipeline_minutes';

initLDAPGroupsSelect();
initLDAPGroupLinks();
pipelineMinutes();
