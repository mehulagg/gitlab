export const hasDownloadLocationsAvailable = state => {
  return state.availablePlatforms[state.selectedAvailablePlatform]?.download_locations;
};

export const getSupportedArchitectures = state => {
  if (hasDownloadLocationsAvailable(state)) {
    return Object.keys(
      state.availablePlatforms[state.selectedAvailablePlatform]?.download_locations,
    );
  }
  return [];
};

export const instructionsEmpty = state => {
  return !Object.keys(state.instructions).length > 0;
};

export const getDownloadLocation = state => {
  return state.availablePlatforms[state.selectedAvailablePlatform]?.download_locations[
    state.selectedArchitecture
  ];
};
