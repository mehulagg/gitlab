import * as getters from '~/vue_shared/components/runner_instructions/store/getters';
import createState from '~/vue_shared/components/runner_instructions/store/state';
import { mockPlatformsObject, mockInstructions } from '../mock_data';

describe('Runner Instructions Store Getters', () => {
  let state;

  beforeEach(() => {
    state = createState({
      instructionsPath: '/instructions',
      availablePlatforms: mockPlatformsObject,
      selectedAvailablePlatform: 'linux',
      selectedArchitecture: 'amd64',
      instructions: mockInstructions,
    });
  });

  describe('getSupportedArchitectures', () => {
    let getSupportedArchitectures;

    beforeEach(() => {
      getSupportedArchitectures = getters.getSupportedArchitectures(state);
    });

    it('should the list of supported architectures', () => {
      expect(getSupportedArchitectures).toHaveLength(
        Object.keys(mockPlatformsObject.linux.download_locations).length,
      );
      expect(getSupportedArchitectures).toEqual(
        Object.keys(mockPlatformsObject.linux.download_locations),
      );
    });
  });

  describe('hasDownloadLocationsAvailable', () => {
    let hasDownloadLocationsAvailable;

    beforeEach(() => {
      hasDownloadLocationsAvailable = getters.hasDownloadLocationsAvailable(state);
    });

    it('should get the list of download locations for each architecture', () => {
      expect(hasDownloadLocationsAvailable).toEqual(mockPlatformsObject.linux.download_locations);
    });
  });

  describe('instructionsEmpty', () => {
    let instructionsEmpty;

    beforeEach(() => {
      instructionsEmpty = getters.instructionsEmpty(state);
    });

    it('should return false if the instruction object is not empty', () => {
      expect(instructionsEmpty).toBe(false);
    });
  });

  describe('getDownloadLocation', () => {
    let getDownloadLocation;

    beforeEach(() => {
      getDownloadLocation = getters.getDownloadLocation(state);
    });

    it('should return the download link for the selected platform and architecture', () => {
      expect(getDownloadLocation).toBe(mockPlatformsObject.linux.download_locations.amd64);
    });
  });
});
