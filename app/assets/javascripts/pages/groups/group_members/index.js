import Vue from 'vue';
import Members from 'ee_else_ce/members';
import memberExpirationDate from '~/member_expiration_date';
import UsersSelect from '~/users_select';
import groupsSelect from '~/groups_select';
import RemoveMemberModal from '~/vue_shared/components/remove_member_modal.vue';
import { initGroupMembersApp } from '~/groups/members';
import { memberRequestFormatter, groupLinkRequestFormatter } from '~/groups/members/utils';

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

  const SHARED_FIELDS = ['account', 'expires', 'maxRole', 'expiration', 'actions'];
  const GROUP_MEMBERS_LIST_SELECTOR = '.js-group-members-list';
  const GROUP_LINKED_LIST_SELECTOR = '.js-group-linked-list';
  const GROUP_INVITED_MEMBERS_LIST_SELECTOR = '.js-group-invited-members-list';
  const GROUP_ACCESS_REQUESTS_LIST_SELECTOR = '.js-group-access-requests-list';

  initGroupMembersApp(
    document.querySelector(GROUP_MEMBERS_LIST_SELECTOR),
    document.querySelector(`${GROUP_MEMBERS_LIST_SELECTOR}-loading`),
    SHARED_FIELDS.concat(['source', 'granted']),
    memberRequestFormatter,
  );
  initGroupMembersApp(
    document.querySelector(GROUP_LINKED_LIST_SELECTOR),
    document.querySelector(`${GROUP_LINKED_LIST_SELECTOR}-loading`),
    SHARED_FIELDS.concat('granted'),
    groupLinkRequestFormatter,
  );
  initGroupMembersApp(
    document.querySelector(GROUP_INVITED_MEMBERS_LIST_SELECTOR),
    document.querySelector(`${GROUP_INVITED_MEMBERS_LIST_SELECTOR}-loading`),
    SHARED_FIELDS.concat('invited'),
    memberRequestFormatter,
  );
  initGroupMembersApp(
    document.querySelector(GROUP_ACCESS_REQUESTS_LIST_SELECTOR),
    document.querySelector(`${GROUP_ACCESS_REQUESTS_LIST_SELECTOR}-loading`),
    SHARED_FIELDS.concat('requested'),
    memberRequestFormatter,
  );

  new Members(); // eslint-disable-line no-new
  new UsersSelect(); // eslint-disable-line no-new
});
