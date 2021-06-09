import initSubscriptions from 'ee/billings/subscriptions';
import { initQrtlyReconciliationAlert } from 'ee/billings/qrtly_reconciliation/init_qrtly_reconciliation_alert';
import PersistentUserCallout from '~/persistent_user_callout';

PersistentUserCallout.factory(document.querySelector('.js-gold-trial-callout'));
initSubscriptions();
initQrtlyReconciliationAlert();
