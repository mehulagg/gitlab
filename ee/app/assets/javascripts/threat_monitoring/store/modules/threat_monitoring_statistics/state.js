export default () => ({
  statisticsEndpoint: '',
  statistics: {
    total: 0,
    anomalous: 0,
    history: {
      nominal: [],
      anomalous: [],
    },
  },
  timeRange: {
    from: null,
    to: null,
  },
  isLoadingStatistics: false,
  errorLoadingStatistics: false,
});
