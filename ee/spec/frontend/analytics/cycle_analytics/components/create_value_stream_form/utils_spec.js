import {
  initializeFormData,
  validateStage,
  validateValueStreamName,
} from 'ee/analytics/cycle_analytics/components/create_value_stream_form/utils';
import {
  ERRORS,
  NAME_MAX_LENGTH,
} from 'ee/analytics/cycle_analytics/components/create_value_stream_form/constants';

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

const expectFieldError = ({ error, field, result }) =>
  expect(result).toMatchObject({ [field]: [error] });

describe('validateStage', () => {
  const defaultFields = {
    name: '',
    startEventIdentifier: '',
    endEventIdentifier: '',
    custom: true,
  };

  it.each`
    field                   | value                              | error                          | msg
    ${'name'}               | ${'a'.repeat(NAME_MAX_LENGTH + 1)} | ${ERRORS.MAX_LENGTH}           | ${'is too long'}
    ${'name'}               | ${'issue'}                         | ${ERRORS.STAGE_NAME_EXISTS}    | ${'is a lowercase default name'}
    ${'name'}               | ${'Issue'}                         | ${ERRORS.STAGE_NAME_EXISTS}    | ${'is a capitalized default name'}
    ${'endEventIdentifier'} | ${''}                              | ${ERRORS.START_EVENT_REQUIRED} | ${'has no corresponding start event'}
  `('returns "$error" if $field $msg', ({ field, value, error }) => {
    const result = validateStage({ ...defaultFields, [field]: value });
    expectFieldError({ result, error, field });
  });

  it(`returns "${ERRORS.END_EVENT_REQUIRED}" with a start event and no end event set`, () => {
    const result = validateStage({ ...defaultFields, startEventIdentifier: 'start-event' });
    expectFieldError({ result, error: ERRORS.END_EVENT_REQUIRED, field: 'endEventIdentifier' });
  });
});

describe('validateValueStreamName,', () => {
  it('with valid data returns an empty array', () => {
    expect(validateValueStreamName({ name: 'Cool stream name' })).toEqual({ name: [] });
  });

  it.each`
    name                               | error                                  | msg
    ${'a'.repeat(NAME_MAX_LENGTH + 1)} | ${ERRORS.MAX_LENGTH}                   | ${'too long'}
    ${''}                              | ${ERRORS.VALUE_STREAM_NAME_MIN_LENGTH} | ${'too short'}
  `('returns "$error" if name is $msg', ({ name, error }) => {
    const result = validateValueStreamName({ name });
    expectFieldError({ result, error, field: 'name' });
  });
});
