import createFlash from '~/flash';
import { __ } from '~/locale';
import SCIMTokenService from './scim_token_service';

export default class SCIMTokenToggleArea {
  constructor(generateSelector, formSelector, groupPath) {
    this.generateContainer = document.querySelector(generateSelector);
    this.formContainer = document.querySelector(formSelector);
    this.scimLoadingSpinner = document.querySelector('.js-scim-loading-container');

    this.generateButton = this.generateContainer.querySelector('.js-generate-scim-token');
    this.resetButton = this.formContainer.querySelector('.js-reset-scim-token');
    this.scimTokenInput = this.formContainer.querySelector('#scim_token');
    this.scimEndpointUrl = this.formContainer.querySelector('#scim_endpoint_url');

    this.generateButton.addEventListener('click', () => this.generateSCIMToken());
    this.resetButton.addEventListener('click', () => this.resetSCIMToken());

    this.service = new SCIMTokenService(groupPath);
  }

  setSCIMTokenValue(value) {
    this.scimTokenInput.value = value;
  }

  setSCIMEndpointURL(value) {
    this.scimEndpointUrl.value = value;
  }

  toggleSCIMTokenHelperText() {
    this.formContainer.querySelector('.input-group-append').classList.toggle('d-none');
    this.formContainer
      .querySelector('.js-scim-token-helper-text span:first-of-type')
      .classList.toggle('d-none');
    this.formContainer
      .querySelector('.js-scim-token-helper-text span:last-of-type')
      .classList.toggle('d-none');
  }

  // eslint-disable-next-line class-methods-use-this
  toggleFormVisibility(form) {
    form.classList.toggle('d-none');
  }

  setSCIMTokenFormTitle(title) {
    this.formContainer.querySelector('label:first-of-type').innerHTML = title;
  }

  toggleLoading() {
    this.scimLoadingSpinner.classList.toggle('d-none');
  }

  setTokenAndToggleSCIMForm(data) {
    this.setSCIMTokenValue(data.scim_token);
    this.setSCIMEndpointURL(data.scim_api_url);
    this.setSCIMTokenFormTitle(__('Your new SCIM token'));
    this.toggleSCIMTokenHelperText();
    this.toggleLoading();
    this.toggleFormVisibility(this.formContainer);
  }

  fetchNewToken() {
    return this.service.generateNewSCIMToken();
  }

  handleTokenGeneration(container) {
    this.toggleFormVisibility(container);
    this.toggleLoading();

    return this.fetchNewToken()
      .then((response) => {
        this.setTokenAndToggleSCIMForm(response.data);
      })
      .catch((error) => {
        createFlash({
          message: error,
        });
        this.toggleLoading();
        this.toggleFormVisibility(container);

        throw error;
      });
  }

  generateSCIMToken() {
    return this.handleTokenGeneration(this.generateContainer);
  }

  resetSCIMToken() {
    if (
      // eslint-disable-next-line no-alert
      window.confirm(
        __(
          'Are you sure you want to reset the SCIM token? SCIM provisioning will stop working until the new token is updated.',
        ),
      )
    ) {
      return this.handleTokenGeneration(this.formContainer);
    }
    return Promise.resolve();
  }
}
