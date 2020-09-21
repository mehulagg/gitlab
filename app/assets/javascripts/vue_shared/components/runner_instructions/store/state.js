export default (initialState = {}) => ({
  instructionsPath: initialState.instructionsPath || '',
  platformsPath: initialState.platformsPath || '',
  availablePlatforms: initialState.availablePlatforms || {},
  selectedAvailablePlatform: initialState.selectedAvailablePlatform || '', // index from the availablePlatforms array
  selectedArchitecture: initialState.selectedArchitecture || '',
  instructions: initialState.instructions || {},
});
