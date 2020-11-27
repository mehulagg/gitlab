import $ from 'jquery';

const role = $('#user_role');
const otherRoleGroup = $('#other_role_group');

role.on('change', () => {
  const enableOtherRole = role.val() === 'other';

  otherRoleGroup
    .toggleClass('hidden', !enableOtherRole)
    .find('input')
});

role.trigger('change');
