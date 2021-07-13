import { s__ } from '~/locale';

export const i18n = Object.freeze({
  planName: s__('Billings|%{planName} plan'),
  extend: {
    buttonText: s__('Billings|Extend trial'),
    modalText: s__(
      'Billings|By extending your trial, you will receive an additional 30 days of %{planName}. Your trial can be only extended once.',
    ),
    flashText: s__('Billings|Your trial has been extended by an additional 30 days.'),
    trialActionError: s__('Billings|An error occurred while exending your trial.'),
  },
  reactivate: {
    buttonText: s__('Billings|Reactivate trial'),
    modalText: s__(
      'Billings|By reactivating your trial, you will receive an additional 30 days of %{planName}. Your trial can be only reactivated once.',
    ),
    flashText: s__('Billings|Your trial has been reactivated for an additional 30 days.'),
    trialActionError: s__('Billings|An error occurred while reactivating your trial.'),
  },
});
