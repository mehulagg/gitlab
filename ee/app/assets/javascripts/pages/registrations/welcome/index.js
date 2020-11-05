import mountProgressBar from 'ee/registrations/welcome';

document.addEventListener('DOMContentLoaded', () => {
  mountProgressBar();

  const emailUpdatesForm = document.querySelector('.js-email-opt-in');
  const setupForCompany = document.querySelector('.js-setup-for-company');
  const setupForMe = document.querySelector('.js-setup-for-me');

  setupForCompany.addEventListener('change', () => {
    emailUpdatesForm.classList.add('hidden');
  });

  setupForMe.addEventListener('change', () => {
    emailUpdatesForm.classList.remove('hidden');
  });
});
