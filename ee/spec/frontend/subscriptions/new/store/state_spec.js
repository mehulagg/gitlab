import createState from 'ee/subscriptions/new/store/state';
import * as constants from 'ee/subscriptions/new/constants';

constants.STEPS = ['firstStep', 'secondStep'];
constants.TAX_RATE = 0;

describe('projectsSelector default state', () => {
  const planData = [
    { id: 'firstPlanId', code: 'bronze', price_per_year: 48 },
    { id: 'secondPlanId', code: 'silver', price_per_year: 228 },
  ];

  const initialData = {
    planData: JSON.stringify(planData),
    planId: 'secondPlanId',
    setupForCompany: 'true',
    fullName: 'Full Name',
  };

  const currentDate = new Date('2020-01-07T12:44:08.135Z');

  jest.spyOn(global.Date, 'now').mockImplementationOnce(() => currentDate.valueOf());

  const state = createState(initialData);

  it('sets the currentStep to the first item of the STEPS constant', () => {
    expect(state.currentStep).toEqual('firstStep');
  });

  describe('availablePlans', () => {
    it('sets the availablePlans to the provided parsed planData', () => {
      expect(state.availablePlans).toEqual([
        { value: 'firstPlanId', text: 'Bronze', pricePerUserPerYear: 48 },
        { value: 'secondPlanId', text: 'Silver', pricePerUserPerYear: 228 },
      ]);
    });

    it('sets the availablePlans to an empty array when no planData provided', () => {
      const modifiedState = createState({ ...initialData, ...{ planData: undefined } });

      expect(modifiedState.availablePlans).toEqual([]);
    });
  });

  describe('selectedPlan', () => {
    it('sets the selectedPlan to the provided planId if it is present in the provided planData', () => {
      expect(state.selectedPlan).toEqual('secondPlanId');
    });

    it('sets the selectedPlan to the first value of availablePlans if planId is not provided', () => {
      const modifiedState = createState({ ...initialData, ...{ planId: undefined } });

      expect(modifiedState.selectedPlan).toEqual('firstPlanId');
    });

    it('sets the selectedPlan to the first value of availablePlans if planId is not present in the availablePlans', () => {
      const modifiedState = createState({ ...initialData, ...{ planId: 'invalidPlanId' } });

      expect(modifiedState.selectedPlan).toEqual('firstPlanId');
    });

    it('sets the selectedPlan to an empty string if availablePlans are not present', () => {
      const modifiedState = createState({ ...initialData, ...{ planData: '[]' } });

      expect(modifiedState.selectedPlan).toBeUndefined();
    });
  });

  describe('isSetupForCompany', () => {
    it('sets the isSetupForCompany to true if provided setupForCompany is "true"', () => {
      expect(state.isSetupForCompany).toEqual(true);
    });

    it('sets the isSetupForCompany to false if provided setupForCompany is "false"', () => {
      const modifiedState = createState({ ...initialData, ...{ setupForCompany: 'false' } });

      expect(modifiedState.isSetupForCompany).toEqual(false);
    });
  });

  it('sets the fullName to the provided fullName', () => {
    expect(state.fullName).toEqual('Full Name');
  });

  it('sets the organizationName to null', () => {
    expect(state.organizationName).toBeNull();
  });

  describe('numberOfUsers', () => {
    it('sets the numberOfUsers to 0 when setupForCompany is true', () => {
      expect(state.numberOfUsers).toEqual(0);
    });

    it('sets the numberOfUsers to 1 when setupForCompany is false', () => {
      const modifiedState = createState({ ...initialData, ...{ setupForCompany: 'false' } });

      expect(modifiedState.numberOfUsers).toEqual(1);
    });
  });

  it('sets the country to null', () => {
    expect(state.country).toBeNull();
  });

  it('sets the streetAddressLine1 to null', () => {
    expect(state.streetAddressLine1).toBeNull();
  });

  it('sets the streetAddressLine2 to null', () => {
    expect(state.streetAddressLine2).toBeNull();
  });

  it('sets the city to null', () => {
    expect(state.city).toBeNull();
  });

  it('sets the countryState to null', () => {
    expect(state.countryState).toBeNull();
  });

  it('sets the zipCode to null', () => {
    expect(state.zipCode).toBeNull();
  });

  it('sets the countryOptions to an empty array', () => {
    expect(state.countryOptions).toEqual([]);
  });

  it('sets the stateOptions to an empty array', () => {
    expect(state.stateOptions).toEqual([]);
  });

  it('sets the taxRate to the TAX_RATE constant', () => {
    expect(state.taxRate).toEqual(0);
  });

  it('sets the startDate to the current date', () => {
    expect(state.startDate).toEqual(currentDate);
  });

  it('sets the paymentFormParams to an empty object', () => {
    expect(state.paymentFormParams).toEqual({});
  });

  it('sets the paymentMethodId to null', () => {
    expect(state.paymentMethodId).toBeNull();
  });

  it('sets the creditCardDetails to an empty object', () => {
    expect(state.creditCardDetails).toEqual({});
  });

  it('sets isLoadingPaymentMethod to false', () => {
    expect(state.isLoadingPaymentMethod).toEqual(false);
  });

  it('sets isConfirmingOrder to false', () => {
    expect(state.isConfirmingOrder).toBe(false);
  });
});
