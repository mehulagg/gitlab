import testAction from 'helpers/vuex_action_helper';
import { setEndpoints, setMrMetadata } from '~/mr_notes/stores/actions/mutators';
import mutationTypes from '~/mr_notes/stores/mutation_types';

describe('MR Notes Mutator Actions', () => {
  describe('setEndpoints', () => {
    it('should trigger the SET_ENDPOINTS state mutation', (done) => {
      const endpoints = { endpointA: 'a' };

      testAction(
        setEndpoints,
        endpoints,
        {},
        [
          {
            type: mutationTypes.SET_ENDPOINTS,
            payload: endpoints,
          },
        ],
        [],
        done,
      );
    });
  });

  describe('setMrMetadata', () => {
    it('should trigger the SET_MR_METADATA state mutation', (done) => {
      const mrMetadata = { propA: 'a', propB: 'b' };

      testAction(
        setMrMetadata,
        mrMetadata,
        {},
        [
          {
            type: mutationTypes.SET_MR_METADATA,
            payload: mrMetadata,
          },
        ],
        [],
        done,
      );
    });
  });
});
