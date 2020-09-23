import axios from '~/lib/utils/axios_utils';
import initConfirmModal from '~/confirm_modal';
import createFlash from '~/flash';

document.addEventListener('DOMContentLoaded', () => {
  initConfirmModal({
    handleSubmit: (path = '') => {
      axios
        .delete(path)
        .then(() => {
          document
            .querySelector(`[data-path="${path}"]`)
            .closest('li.flex-row.allow-wrap')
            .remove();
        })
        .catch(error => {
          createFlash({ message: error });
        });
    },
  });
});
