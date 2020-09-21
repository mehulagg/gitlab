import mutations from '~/vue_shared/components/runner_instructions/store/mutations';
import createState from '~/vue_shared/components/runner_instructions/store/state';
import { mockPlatformsArray } from '../mock_data';

describe('Runner Instructions mutations', () => {
  let localState;

  beforeEach(() => {
    localState = createState();
  });

  describe('SET_AVAILABLE_PLATFORMS', () => {
    it('should set the availablePlatforms array', () => {
      mutations.SET_AVAILABLE_PLATFORMS(localState, mockPlatformsArray);

      expect(localState.availablePlatforms).toEqual(mockPlatformsArray);
    });
  });

  describe('SET_AVAILABLE_PLATFORM', () => {
    it('should set the selectedAvailablePlatform index', () => {
      mutations.SET_AVAILABLE_PLATFORM(localState, 1);

      expect(localState.selectedAvailablePlatform).toBe(1);
    });
  });

  describe('SET_ARCHITECTURE', () => {
    it('should set the selectedArchitecture index', () => {
      mutations.SET_ARCHITECTURE(localState, 1);

      expect(localState.selectedArchitecture).toBe(1);
    });
  });
});
