import MockAdapter from 'axios-mock-adapter';
import Api from 'ee/api';
import * as constants from 'ee/subscriptions/new/constants';
import defaultClient from 'ee/subscriptions/new/graphql';
import * as actions from 'ee/subscriptions/new/store/actions';
import activateNextStepMutation from 'ee/vue_shared/purchase_flow/graphql/mutations/activate_next_step.mutation.graphql';
import { useMockLocationHelper } from 'helpers/mock_window_location_helper';
import testAction from 'helpers/vuex_action_helper';
import createFlash from '~/flash';
import axios from '~/lib/utils/axios_utils';

const {
  countriesPath,
  countryStatesPath,
  paymentFormPath,
  paymentMethodPath,
  confirmOrderPath,
} = Api;

jest.mock('~/flash');

describe('Subscriptions Actions', () => {
  let mock;

  beforeEach(() => {
    mock = new MockAdapter(axios);
    defaultClient.mutate = jest.fn();
  });

  afterEach(() => {
    mock.restore();
    defaultClient.mutate.mockClear();
  });

  describe('updateSelectedPlan', () => {
    it('updates the selected plan', (done) => {
      testAction(
        actions.updateSelectedPlan,
        'planId',
        {},
        [{ type: 'UPDATE_SELECTED_PLAN', payload: 'planId' }],
        [],
        done,
      );
    });
  });

  describe('updateSelectedGroup', () => {
    it('updates the selected group, resets the organization name and updates the number of users', (done) => {
      testAction(
        actions.updateSelectedGroup,
        'groupId',
        { selectedGroupUsers: 3 },
        [
          { type: 'UPDATE_SELECTED_GROUP', payload: 'groupId' },
          { type: 'UPDATE_ORGANIZATION_NAME', payload: null },
          { type: 'UPDATE_NUMBER_OF_USERS', payload: 3 },
        ],
        [],
        done,
      );
    });
  });

  describe('toggleIsSetupForCompany', () => {
    it('toggles the isSetupForCompany value', (done) => {
      testAction(
        actions.toggleIsSetupForCompany,
        {},
        { isSetupForCompany: true },
        [{ type: 'UPDATE_IS_SETUP_FOR_COMPANY', payload: false }],
        [],
        done,
      );
    });
  });

  describe('updateNumberOfUsers', () => {
    it('updates numberOfUsers to 0 when no value is provided', (done) => {
      testAction(
        actions.updateNumberOfUsers,
        null,
        {},
        [{ type: 'UPDATE_NUMBER_OF_USERS', payload: 0 }],
        [],
        done,
      );
    });

    it('updates numberOfUsers when a value is provided', (done) => {
      testAction(
        actions.updateNumberOfUsers,
        2,
        {},
        [{ type: 'UPDATE_NUMBER_OF_USERS', payload: 2 }],
        [],
        done,
      );
    });
  });

  describe('updateOrganizationName', () => {
    it('updates organizationName to the provided value', (done) => {
      testAction(
        actions.updateOrganizationName,
        'name',
        {},
        [{ type: 'UPDATE_ORGANIZATION_NAME', payload: 'name' }],
        [],
        done,
      );
    });
  });

  describe('fetchCountries', () => {
    it('calls fetchCountriesSuccess with the returned data on success', (done) => {
      mock.onGet(countriesPath).replyOnce(200, ['Netherlands', 'NL']);

      testAction(
        actions.fetchCountries,
        null,
        {},
        [],
        [{ type: 'fetchCountriesSuccess', payload: ['Netherlands', 'NL'] }],
        done,
      );
    });

    it('calls fetchCountriesError on error', (done) => {
      mock.onGet(countriesPath).replyOnce(500);

      testAction(actions.fetchCountries, null, {}, [], [{ type: 'fetchCountriesError' }], done);
    });
  });

  describe('fetchCountriesSuccess', () => {
    it('transforms and adds fetched countryOptions', (done) => {
      testAction(
        actions.fetchCountriesSuccess,
        [['Netherlands', 'NL']],
        {},
        [{ type: 'UPDATE_COUNTRY_OPTIONS', payload: [{ text: 'Netherlands', value: 'NL' }] }],
        [],
        done,
      );
    });

    it('adds an empty array when no data provided', (done) => {
      testAction(
        actions.fetchCountriesSuccess,
        undefined,
        {},
        [{ type: 'UPDATE_COUNTRY_OPTIONS', payload: [] }],
        [],
        done,
      );
    });
  });

  describe('fetchCountriesError', () => {
    it('creates a flash', (done) => {
      testAction(actions.fetchCountriesError, null, {}, [], [], () => {
        expect(createFlash).toHaveBeenCalledWith({
          message: 'Failed to load countries. Please try again.',
        });
        done();
      });
    });
  });

  describe('fetchStates', () => {
    it('calls resetStates and fetchStatesSuccess with the returned data on success', (done) => {
      mock
        .onGet(countryStatesPath, { params: { country: 'NL' } })
        .replyOnce(200, { utrecht: 'UT' });

      testAction(
        actions.fetchStates,
        null,
        { country: 'NL' },
        [],
        [{ type: 'resetStates' }, { type: 'fetchStatesSuccess', payload: { utrecht: 'UT' } }],
        done,
      );
    });

    it('only calls resetStates when no country selected', (done) => {
      mock.onGet(countryStatesPath).replyOnce(500);

      testAction(actions.fetchStates, null, { country: null }, [], [{ type: 'resetStates' }], done);
    });

    it('calls resetStates and fetchStatesError on error', (done) => {
      mock.onGet(countryStatesPath).replyOnce(500);

      testAction(
        actions.fetchStates,
        null,
        { country: 'NL' },
        [],
        [{ type: 'resetStates' }, { type: 'fetchStatesError' }],
        done,
      );
    });
  });

  describe('fetchStatesSuccess', () => {
    it('transforms and adds received stateOptions', (done) => {
      testAction(
        actions.fetchStatesSuccess,
        { Utrecht: 'UT' },
        {},
        [{ type: 'UPDATE_STATE_OPTIONS', payload: [{ text: 'Utrecht', value: 'UT' }] }],
        [],
        done,
      );
    });

    it('adds an empty array when no data provided', (done) => {
      testAction(
        actions.fetchStatesSuccess,
        undefined,
        {},
        [{ type: 'UPDATE_STATE_OPTIONS', payload: [] }],
        [],
        done,
      );
    });
  });

  describe('fetchStatesError', () => {
    it('creates a flash', (done) => {
      testAction(actions.fetchStatesError, null, {}, [], [], () => {
        expect(createFlash).toHaveBeenCalledWith({
          message: 'Failed to load states. Please try again.',
        });
        done();
      });
    });
  });

  describe('resetStates', () => {
    it('resets the selected state and sets the stateOptions to the initial value', (done) => {
      testAction(
        actions.resetStates,
        null,
        {},
        [
          { type: 'UPDATE_COUNTRY_STATE', payload: null },
          { type: 'UPDATE_STATE_OPTIONS', payload: [] },
        ],
        [],
        done,
      );
    });
  });

  describe('updateCountry', () => {
    it('updates country to the provided value', (done) => {
      testAction(
        actions.updateCountry,
        'country',
        {},
        [{ type: 'UPDATE_COUNTRY', payload: 'country' }],
        [],
        done,
      );
    });
  });

  describe('updateStreetAddressLine1', () => {
    it('updates streetAddressLine1 to the provided value', (done) => {
      testAction(
        actions.updateStreetAddressLine1,
        'streetAddressLine1',
        {},
        [{ type: 'UPDATE_STREET_ADDRESS_LINE_ONE', payload: 'streetAddressLine1' }],
        [],
        done,
      );
    });
  });

  describe('updateStreetAddressLine2', () => {
    it('updates streetAddressLine2 to the provided value', (done) => {
      testAction(
        actions.updateStreetAddressLine2,
        'streetAddressLine2',
        {},
        [{ type: 'UPDATE_STREET_ADDRESS_LINE_TWO', payload: 'streetAddressLine2' }],
        [],
        done,
      );
    });
  });

  describe('updateCity', () => {
    it('updates city to the provided value', (done) => {
      testAction(
        actions.updateCity,
        'city',
        {},
        [{ type: 'UPDATE_CITY', payload: 'city' }],
        [],
        done,
      );
    });
  });

  describe('updateCountryState', () => {
    it('updates countryState to the provided value', (done) => {
      testAction(
        actions.updateCountryState,
        'countryState',
        {},
        [{ type: 'UPDATE_COUNTRY_STATE', payload: 'countryState' }],
        [],
        done,
      );
    });
  });

  describe('updateZipCode', () => {
    it('updates zipCode to the provided value', (done) => {
      testAction(
        actions.updateZipCode,
        'zipCode',
        {},
        [{ type: 'UPDATE_ZIP_CODE', payload: 'zipCode' }],
        [],
        done,
      );
    });
  });

  describe('startLoadingZuoraScript', () => {
    it('updates isLoadingPaymentMethod to true', (done) => {
      testAction(
        actions.startLoadingZuoraScript,
        undefined,
        {},
        [{ type: 'UPDATE_IS_LOADING_PAYMENT_METHOD', payload: true }],
        [],
        done,
      );
    });
  });

  describe('fetchPaymentFormParams', () => {
    it('fetches paymentFormParams and calls fetchPaymentFormParamsSuccess with the returned data on success', (done) => {
      mock
        .onGet(paymentFormPath, { params: { id: constants.PAYMENT_FORM_ID } })
        .replyOnce(200, { token: 'x' });

      testAction(
        actions.fetchPaymentFormParams,
        null,
        {},
        [],
        [{ type: 'fetchPaymentFormParamsSuccess', payload: { token: 'x' } }],
        done,
      );
    });

    it('calls fetchPaymentFormParamsError on error', (done) => {
      mock.onGet(paymentFormPath).replyOnce(500);

      testAction(
        actions.fetchPaymentFormParams,
        null,
        {},
        [],
        [{ type: 'fetchPaymentFormParamsError' }],
        done,
      );
    });
  });

  describe('fetchPaymentFormParamsSuccess', () => {
    it('updates paymentFormParams to the provided value when no errors are present', (done) => {
      testAction(
        actions.fetchPaymentFormParamsSuccess,
        { token: 'x' },
        {},
        [{ type: 'UPDATE_PAYMENT_FORM_PARAMS', payload: { token: 'x' } }],
        [],
        done,
      );
    });

    it('creates a flash when errors are present', (done) => {
      testAction(
        actions.fetchPaymentFormParamsSuccess,
        { errors: 'error message' },
        {},
        [],
        [],
        () => {
          expect(createFlash).toHaveBeenCalledWith({
            message: 'Credit card form failed to load: error message',
          });
          done();
        },
      );
    });
  });

  describe('fetchPaymentFormParamsError', () => {
    it('creates a flash', (done) => {
      testAction(actions.fetchPaymentFormParamsError, null, {}, [], [], () => {
        expect(createFlash).toHaveBeenCalledWith({
          message: 'Credit card form failed to load. Please try again.',
        });
        done();
      });
    });
  });

  describe('zuoraIframeRendered', () => {
    it('updates isLoadingPaymentMethod to false', (done) => {
      testAction(
        actions.zuoraIframeRendered,
        undefined,
        {},
        [{ type: 'UPDATE_IS_LOADING_PAYMENT_METHOD', payload: false }],
        [],
        done,
      );
    });
  });

  describe('paymentFormSubmitted', () => {
    describe('on success', () => {
      it('calls paymentFormSubmittedSuccess with the refID from the response and updates isLoadingPaymentMethod to true', (done) => {
        testAction(
          actions.paymentFormSubmitted,
          { success: true, refId: 'id' },
          {},
          [{ type: 'UPDATE_IS_LOADING_PAYMENT_METHOD', payload: true }],
          [{ type: 'paymentFormSubmittedSuccess', payload: 'id' }],
          done,
        );
      });
    });

    describe('on failure', () => {
      it('calls paymentFormSubmittedError with the response', (done) => {
        testAction(
          actions.paymentFormSubmitted,
          { error: 'foo' },
          {},
          [],
          [{ type: 'paymentFormSubmittedError', payload: { error: 'foo' } }],
          done,
        );
      });
    });
  });

  describe('paymentFormSubmittedSuccess', () => {
    it('updates paymentMethodId to the provided value and calls fetchPaymentMethodDetails', (done) => {
      testAction(
        actions.paymentFormSubmittedSuccess,
        'id',
        {},
        [{ type: 'UPDATE_PAYMENT_METHOD_ID', payload: 'id' }],
        [{ type: 'fetchPaymentMethodDetails' }],
        done,
      );
    });
  });

  describe('paymentFormSubmittedError', () => {
    it('creates a flash', (done) => {
      testAction(
        actions.paymentFormSubmittedError,
        { errorCode: 'codeFromResponse', errorMessage: 'messageFromResponse' },
        {},
        [],
        [],
        () => {
          expect(createFlash).toHaveBeenCalledWith({
            message:
              'Submitting the credit card form failed with code codeFromResponse: messageFromResponse',
          });
          done();
        },
      );
    });
  });

  describe('fetchPaymentMethodDetails', () => {
    it('fetches paymentMethodDetails and calls fetchPaymentMethodDetailsSuccess with the returned data on success and updates isLoadingPaymentMethod to false', (done) => {
      mock
        .onGet(paymentMethodPath, { params: { id: 'paymentMethodId' } })
        .replyOnce(200, { token: 'x' });

      testAction(
        actions.fetchPaymentMethodDetails,
        null,
        { paymentMethodId: 'paymentMethodId' },
        [{ type: 'UPDATE_IS_LOADING_PAYMENT_METHOD', payload: false }],
        [{ type: 'fetchPaymentMethodDetailsSuccess', payload: { token: 'x' } }],
        done,
      );
    });

    it('calls fetchPaymentMethodDetailsError on error and updates isLoadingPaymentMethod to false', (done) => {
      mock.onGet(paymentMethodPath).replyOnce(500);

      testAction(
        actions.fetchPaymentMethodDetails,
        null,
        {},
        [{ type: 'UPDATE_IS_LOADING_PAYMENT_METHOD', payload: false }],
        [{ type: 'fetchPaymentMethodDetailsError' }],
        done,
      );
    });
  });

  describe('fetchPaymentMethodDetailsSuccess', () => {
    it('updates creditCardDetails to the provided data and calls defaultClient with activateNextStepMutation', (done) => {
      testAction(
        actions.fetchPaymentMethodDetailsSuccess,
        {
          credit_card_type: 'cc_type',
          credit_card_mask_number: '************4242',
          credit_card_expiration_month: 12,
          credit_card_expiration_year: 2019,
        },
        {},
        [
          {
            type: 'UPDATE_CREDIT_CARD_DETAILS',
            payload: {
              credit_card_type: 'cc_type',
              credit_card_mask_number: '************4242',
              credit_card_expiration_month: 12,
              credit_card_expiration_year: 2019,
            },
          },
        ],
        [],
        () => {
          expect(defaultClient.mutate).toHaveBeenCalledWith({
            mutation: activateNextStepMutation,
          });
          done();
        },
      );
    });
  });

  describe('fetchPaymentMethodDetailsError', () => {
    it('creates a flash', (done) => {
      testAction(actions.fetchPaymentMethodDetailsError, null, {}, [], [], () => {
        expect(createFlash).toHaveBeenCalledWith({
          message: 'Failed to register credit card. Please try again.',
        });
        done();
      });
    });
  });

  describe('confirmOrder', () => {
    it('calls confirmOrderSuccess with a redirect location on success', (done) => {
      const response = { location: 'x' };
      mock.onPost(confirmOrderPath).replyOnce(200, response);

      testAction(
        actions.confirmOrder,
        null,
        {},
        [{ type: 'UPDATE_IS_CONFIRMING_ORDER', payload: true }],
        [{ type: 'confirmOrderSuccess', payload: response }],
        done,
      );
    });

    it('calls confirmOrderError with the errors on error', (done) => {
      mock.onPost(confirmOrderPath).replyOnce(200, { errors: 'errors' });

      testAction(
        actions.confirmOrder,
        null,
        {},
        [{ type: 'UPDATE_IS_CONFIRMING_ORDER', payload: true }],
        [{ type: 'confirmOrderError', payload: '"errors"' }],
        done,
      );
    });

    it('calls confirmOrderError on failure', (done) => {
      mock.onPost(confirmOrderPath).replyOnce(500);

      testAction(
        actions.confirmOrder,
        null,
        {},
        [{ type: 'UPDATE_IS_CONFIRMING_ORDER', payload: true }],
        [{ type: 'confirmOrderError' }],
        done,
      );
    });
  });

  describe('confirmOrderSuccess', () => {
    useMockLocationHelper();

    const params = { location: 'http://example.com', plan_id: 'x', quantity: 10 };

    it('changes the window location', (done) => {
      testAction(actions.confirmOrderSuccess, params, {}, [], [], () => {
        expect(window.location.assign).toHaveBeenCalledWith('http://example.com');
        done();
      });
    });
  });

  describe('confirmOrderError', () => {
    it('creates a flash with a default message when no error given', (done) => {
      testAction(
        actions.confirmOrderError,
        null,
        {},
        [{ type: 'UPDATE_IS_CONFIRMING_ORDER', payload: false }],
        [],
        () => {
          expect(createFlash).toHaveBeenCalledWith({
            message: 'Failed to confirm your order! Please try again.',
          });
          done();
        },
      );
    });

    it('creates a flash with a the error message when an error is given', (done) => {
      testAction(
        actions.confirmOrderError,
        '"Error"',
        {},
        [{ type: 'UPDATE_IS_CONFIRMING_ORDER', payload: false }],
        [],
        () => {
          expect(createFlash).toHaveBeenCalledWith({
            message: 'Failed to confirm your order: "Error". Please try again.',
          });
          done();
        },
      );
    });
  });
});
