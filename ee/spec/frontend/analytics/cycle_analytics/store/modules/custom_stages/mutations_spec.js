import mutations from 'ee/analytics/cycle_analytics/store/modules/custom_stages/mutations';
import * as types from 'ee/analytics/cycle_analytics/store/modules/custom_stages/mutation_types';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';
import { rawCustomStageEvents, camelCasedStageEvents, rawCustomStage } from '../../../mock_data';

let state = null;

describe('Custom stage mutations', () => {
  beforeEach(() => {
    state = {};
  });

  afterEach(() => {
    state = null;
  });

  it.each`
    mutation                              | stateKey                   | value
    ${types.HIDE_FORM}                    | ${'isCreatingCustomStage'} | ${false}
    ${types.HIDE_FORM}                    | ${'isEditingCustomStage'}  | ${false}
    ${types.HIDE_FORM}                    | ${'formErrors'}            | ${null}
    ${types.HIDE_FORM}                    | ${'formInitialData'}       | ${null}
    ${types.CLEAR_FORM_ERRORS}            | ${'formErrors'}            | ${null}
    ${types.SHOW_CREATE_FORM}             | ${'isCreatingCustomStage'} | ${true}
    ${types.SHOW_CREATE_FORM}             | ${'isEditingCustomStage'}  | ${false}
    ${types.SHOW_CREATE_FORM}             | ${'formErrors'}            | ${null}
    ${types.SHOW_CREATE_FORM}             | ${'formInitialData'}       | ${null}
    ${types.SHOW_EDIT_FORM}               | ${'isEditingCustomStage'}  | ${true}
    ${types.SHOW_EDIT_FORM}               | ${'isCreatingCustomStage'} | ${false}
    ${types.SHOW_EDIT_FORM}               | ${'formErrors'}            | ${null}
    ${types.RECEIVE_CREATE_STAGE_SUCCESS} | ${'formErrors'}            | ${null}
    ${types.RECEIVE_CREATE_STAGE_SUCCESS} | ${'formInitialData'}       | ${null}
    ${types.RECEIVE_CREATE_STAGE_ERROR}   | ${'isSavingCustomStage'}   | ${false}
    ${types.SET_SAVING_CUSTOM_STAGE}      | ${'isSavingCustomStage'}   | ${true}
    ${types.CLEAR_SAVING_CUSTOM_STAGE}    | ${'isSavingCustomStage'}   | ${false}
    ${types.SET_LOADING}                  | ${'isLoadingCustomStage'}  | ${true}
  `('$mutation will set $stateKey=$value', ({ mutation, stateKey, value }) => {
    mutations[mutation](state);

    expect(state[stateKey]).toEqual(value);
  });

  describe(`${types.SET_STAGE_EVENTS}`, () => {
    it('will set formEvents', () => {
      state = {};
      mutations[types.SET_STAGE_EVENTS](state, rawCustomStageEvents);
      expect(state.formEvents).toEqual(camelCasedStageEvents);
    });
  });

  describe(`${types.SET_STAGE_FORM_ERRORS}`, () => {
    const mockFormError = { start_identifier: ['Cant be blank'] };
    it('will set formErrors', () => {
      state = {};
      mutations[types.SET_STAGE_FORM_ERRORS](state, mockFormError);

      expect(state.formErrors).toEqual(convertObjectPropsToCamelCase(mockFormError));
    });
  });

  describe(`${types.SET_FORM_INITIAL_DATA}`, () => {
    const mockStage = {
      endEventIdentifier: 'issue_first_added_to_board',
      endEventLabelId: null,
      id: 18,
      name: 'Coolest beans stage',
      startEventIdentifier: 'issue_first_mentioned_in_commit',
      startEventLabelId: null,
    };

    it('will set formInitialData', () => {
      state = {};
      mutations[types.SET_FORM_INITIAL_DATA](state, rawCustomStage);

      expect(state.formInitialData).toEqual(mockStage);
    });
  });
});
