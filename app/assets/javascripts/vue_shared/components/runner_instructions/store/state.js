export default (initialState = {}) => ({
  instructionsPath: initialState.instructionsPath || '',
  availablePlatforms: initialState.availablePlatforms || [],
  selectedAvailablePlatform: initialState.selectedAvailablePlatform || 0, // index from the availablePlatforms array
  selectedArchitecture: initialState.selectedArchitecture || 0,
});
