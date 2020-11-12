export const hasHistory = ({ statistics: { history } }) =>
  Boolean(history.nominal.length || history.anomalous.length);
