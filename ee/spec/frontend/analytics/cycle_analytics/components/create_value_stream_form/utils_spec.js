import { initializeFormData } from 'ee/analytics/cycle_analytics/components/create_value_stream_form/utils';
import { emptyErrorsState, emptyState, formInitialData } from './mock_data';

describe('initializeFormData', () => {
  const checkInitializedData = (
    { emptyFieldState = emptyState, fields = {}, errors = emptyErrorsState },
    { fields: resultFields = emptyState, errors: resultErrors = emptyErrorsState },
  ) => {
    const res = initializeFormData({ emptyFieldState, fields, errors });
    expect(res.fields).toEqual(resultFields);
    expect(res.errors).toMatchObject(resultErrors);
  };

  describe('without a startEventIdentifier', () => {
    it('with no errors', () => {
      checkInitializedData(
        { fields: {} },
        { errors: { endEventIdentifier: ['Please select a start event first'] } },
      );
    });

    it('with field errors', () => {
      const data = { errors: { name: ['is reserved'] } };
      const result = {
        errors: {
          endEventIdentifier: ['Please select a start event first'],
          name: ['is reserved'],
        },
      };
      checkInitializedData(data, result);
    });
  });

  describe('with a startEventIdentifier', () => {
    it('with no errors', () => {
      const data = {
        fields: { startEventIdentifier: 'start-event' },
        errors: { ...emptyErrorsState, endEventIdentifier: [] },
      };
      const result = {
        fields: { ...emptyState, startEventIdentifier: 'start-event' },
        errors: { ...emptyErrorsState, endEventIdentifier: [] },
      };
      checkInitializedData(data, result);
    });

    it('with field errors', () => {
      const data = {
        fields: { startEventIdentifier: 'start-event' },
        errors: { name: ['is reserved'] },
      };
      const result = {
        fields: { ...emptyState, startEventIdentifier: 'start-event' },
        errors: { endEventIdentifier: [], name: ['is reserved'] },
      };
      checkInitializedData(data, result);
    });
  });

  describe('with all fields set', () => {
    it('with no errors', () => {
      const data = { fields: formInitialData };
      const result = { fields: formInitialData };
      checkInitializedData(data, result);
    });

    it('with field errors', () => {
      const data = { fields: formInitialData, errors: { name: ['is reserved'] } };
      const result = { fields: formInitialData, errors: { name: ['is reserved'] } };
      checkInitializedData(data, result);
    });
  });
});
