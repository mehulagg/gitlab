import mutations from '~/vue_shared/components/runner_instructions/store/mutations';
import createState from '~/vue_shared/components/runner_instructions/store/state';
import { mockPlatformsObject, mockInstructions } from '../mock_data';

describe('Runner Instructions mutations', () => {
  let localState;

  beforeEach(() => {
    localState = createState();
  });

  describe('SET_AVAILABLE_PLATFORMS', () => {
    it('should set the availablePlatforms object', () => {
      mutations.SET_AVAILABLE_PLATFORMS(localState, mockPlatformsObject);

      expect(localState.availablePlatforms).toEqual(mockPlatformsObject);
    });
  });

  describe('SET_AVAILABLE_PLATFORM', () => {
    it('should set the selectedAvailablePlatform key', () => {
      mutations.SET_AVAILABLE_PLATFORM(localState, 'linux');

      expect(localState.selectedAvailablePlatform).toBe('linux');
    });
  });

  describe('SET_ARCHITECTURE', () => {
    it('should set the selectedArchitecture key', () => {
      mutations.SET_ARCHITECTURE(localState, 'amd64');

      expect(localState.selectedArchitecture).toBe('amd64');
    });
  });

  describe('SET_INSTRUCTIONS', () => {
    it('should set the instructions object', () => {
      mutations.SET_INSTRUCTIONS(localState, mockInstructions);

      expect(localState.instructions).toEqual(mockInstructions);
    });
  });

  describe('SET_SHOW_ALERT', () => {
    it('should set the showAlert boolean', () => {
      mutations.SET_SHOW_ALERT(localState, true);

      expect(localState.showAlert).toEqual(true);
    });
  });
});
