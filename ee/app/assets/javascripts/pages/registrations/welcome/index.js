import mountProgressBar from 'ee/registrations/welcome';

mountProgressBar();

const emailUpdatesForm = document.querySelector('.js-email-opt-in');
const setupForCompany = document.querySelector('.js-setup-for-company');
const setupForCompanyDetails = document.querySelector('.js-setup_for_company_details');
const setupForMe = document.querySelector('.js-setup-for-me');

setupForCompany.addEventListener('change', () => {
  emailUpdatesForm.classList.add('hidden');
  setupForCompanyDetails.classList.remove('hidden');
});

setupForMe.addEventListener('change', () => {
  emailUpdatesForm.classList.remove('hidden');
  setupForCompanyDetails.classList.add('hidden');
});
