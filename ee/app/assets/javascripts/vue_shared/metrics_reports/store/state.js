export default () => ({
  endpoint: null,

  isLoading: false,
  hasError: false,

  /**
   * Each metric will have the following format:
   * {
   *    name: {String},
   *    value: {String},
   *    previous_value: {String}
   * }
   */
  changedMetrics: [],
  newMetrics: [],
  removedMetrics: [],
  unchangedMetrics: [],

  numberOfChanges: 0,
});
