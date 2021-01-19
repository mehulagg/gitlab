const otherRoleGroup = document.querySelector('.js-other-role-group');

if (otherRoleGroup) {
  const role = document.querySelector('.js-user-role-dropdown');

  showOtherRoleGroup = () => {
    const enableOtherRole = role.value === 'other';
    otherRoleGroup.classList.toggle('hidden', !enableOtherRole);
  };

  role.addEventListener('change', showOtherRoleGroup);
  showOtherRoleGroup();
}
