const role = document.querySelector('.js-user-role-dropdown');
const otherRoleGroup = document.querySelector('.js-other-role-group');

role.addEventListener('change', () => {
  const enableOtherRole = role.value === 'other';

  otherRoleGroup.classList.toggle('hidden', !enableOtherRole);
});

role.dispatchEvent(new Event('change'));
