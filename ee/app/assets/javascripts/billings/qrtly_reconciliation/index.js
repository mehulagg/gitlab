export const shouldQrtlyReconciliationMount = async () => {
  const el = document.querySelector('#js-qrtly-reconciliation-alert');

  if (el) {
    const { initQrtlyReconciliationAlert } = await import(
      /* webpackChunkName: 'init_qrtly_reconciliation_alert' */ './init_qrtly_reconciliation_alert'
    );
    initQrtlyReconciliationAlert();
  }
};
