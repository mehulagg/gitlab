export const getSupportedArchitectures = state => {
  return state.availablePlatforms[state.selectedAvailablePlatform]?.supported_architectures;
};

export const getSelectedArchitecture = state => {
  return state.availablePlatforms[state.selectedAvailablePlatform]?.supported_architectures[
    state.selectedArchitecture
  ];
};

export const getSelectedOS = state => {
  return state.availablePlatforms[state.selectedAvailablePlatform]?.name;
};
