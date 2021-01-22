import initVueAlerts from '~/vue_alerts';
import initConfirmModal from '~/confirm_modal';
import showToast from '~/vue_shared/plugins/global_toast';

initVueAlerts();
initConfirmModal();

const toasts = document.querySelectorAll('.js-toast-message');
toasts.forEach((toast) => showToast(toast.dataset.message));
