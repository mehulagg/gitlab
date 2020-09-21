import * as getters from '~/vue_shared/components/runner_instructions/store/getters';
import createState from '~/vue_shared/components/runner_instructions/store/state';
import { mockPlatformsArray } from '../mock_data';

describe('Runner Instructions store Getters', () => {
  let state;

  beforeEach(() => {
    state = createState({
      instructionsPath: '/instructions',
      availablePlatforms: mockPlatformsArray,
      selectedAvailablePlatform: 0,
      selectedArchitecture: 0,
    });
  });

  describe('getSupportedArchitectures', () => {
    let getSupportedArchitectures;

    beforeEach(() => {
      getSupportedArchitectures = getters.getSupportedArchitectures(state);
    });

    it('should the list of supported architectures', () => {
      expect(getSupportedArchitectures).toHaveLength(
        mockPlatformsArray[0].supported_architectures.length,
      );
      expect(getSupportedArchitectures).toEqual(mockPlatformsArray[0].supported_architectures);
    });
  });

  describe('getSelectedArchitecture', () => {
    let getSelectedArchitecture;

    beforeEach(() => {
      getSelectedArchitecture = getters.getSelectedArchitecture(state);
    });

    it('should the list of supported architectures', () => {
      expect(getSelectedArchitecture).toBe('amd64');
    });
  });

  describe('getSelectedOS', () => {
    let getSelectedOS;

    beforeEach(() => {
      getSelectedOS = getters.getSelectedOS(state);
    });

    it('should get the selected OS name', () => {
      expect(getSelectedOS).toBe('linux');
    });
  });
});
