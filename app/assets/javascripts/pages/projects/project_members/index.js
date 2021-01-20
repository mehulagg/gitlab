import Vue from 'vue';
import Members from '~/members';
import memberExpirationDate from '~/member_expiration_date';
import UsersSelect from '~/users_select';
import groupsSelect from '~/groups_select';
import RemoveMemberModal from '~/vue_shared/components/remove_member_modal.vue';
import initInviteMembersModal from '~/invite_members/init_invite_members_modal';
import initInviteMembersTrigger from '~/invite_members/init_invite_members_trigger';
import { initMembersApp } from '~/members/index';
import { groupLinkRequestFormatter } from '~/members/utils';
import { projectMemberRequestFormatter } from '~/projects/members/utils';
import { s__ } from '~/locale';

function mountRemoveMemberModal() {
  const el = document.querySelector('.js-remove-member-modal');
  if (!el) {
    return false;
  }

  return new Vue({
    el,
    render(createComponent) {
      return createComponent(RemoveMemberModal);
    },
  });
}

document.addEventListener('DOMContentLoaded', () => {
  groupsSelect();
  memberExpirationDate();
  memberExpirationDate('.js-access-expiration-date-groups');
  mountRemoveMemberModal();
  initInviteMembersModal();
  initInviteMembersTrigger();

  new Members(); // eslint-disable-line no-new
  new UsersSelect(); // eslint-disable-line no-new
});

const SHARED_FIELDS = ['account', 'expires', 'maxRole', 'expiration', 'actions'];

initMembersApp(document.querySelector('.js-project-members-list'), {
  tableFields: SHARED_FIELDS.concat(['source', 'granted']),
  tableAttrs: { tr: { 'data-qa-selector': 'member_row' } },
  tableSortableFields: ['account', 'granted', 'maxRole', 'lastSignIn'],
  requestFormatter: projectMemberRequestFormatter,
  filteredSearchBar: {
    show: true,
    tokens: ['two_factor', 'with_inherited_permissions'],
    searchParam: 'search',
    placeholder: s__('Members|Filter members'),
    recentSearchesStorageKey: 'project_members',
  },
});

initMembersApp(document.querySelector('.js-project-group-links-list'), {
  tableFields: SHARED_FIELDS.concat('granted'),
  tableAttrs: {
    table: { 'data-qa-selector': 'groups_list' },
    tr: { 'data-qa-selector': 'group_row' },
  },
  requestFormatter: groupLinkRequestFormatter,
  filteredSearchBar: {
    show: true,
    tokens: [],
    searchParam: 'search_groups',
    placeholder: s__('Members|Search groups'),
    recentSearchesStorageKey: 'project_group_links',
  },
});

initMembersApp(document.querySelector('.js-project-invited-members-list'), {
  tableFields: SHARED_FIELDS.concat('invited'),
  requestFormatter: projectMemberRequestFormatter,
});

initMembersApp(document.querySelector('.js-project-access-requests-list'), {
  tableFields: SHARED_FIELDS.concat('requested'),
  requestFormatter: projectMemberRequestFormatter,
});
