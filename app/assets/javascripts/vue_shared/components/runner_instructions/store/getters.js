export const hasDownloadLocationsAvailable = state => {
  return state.availablePlatforms[state.selectedAvailablePlatform]?.download_locations;
};

export const getSupportedArchitectures = state => {
  return Object.keys(
    state.availablePlatforms[state.selectedAvailablePlatform]?.download_locations || {},
  );
};

export const instructionsEmpty = state => {
  return !Object.keys(state.instructions).length;
};

export const getDownloadLocation = state => {
  return state.availablePlatforms[state.selectedAvailablePlatform]?.download_locations[
    state.selectedArchitecture
  ];
};
