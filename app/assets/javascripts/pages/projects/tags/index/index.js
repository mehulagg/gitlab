import axios from '~/lib/utils/axios_utils';
import initConfirmModal from '~/confirm_modal';
import createFlash from '~/flash';

document.addEventListener('DOMContentLoaded', () => {
  initConfirmModal({
    handleSubmit: (path = '') => {
      console.log('DELETINGGGGGG', path);
      axios
        .delete(path)
        .then(() => {
          console.log('DONESKIESSSSS');
        })
        .catch(error => {
          console.log('FAIL!!!!', error.message);
          createFlash({ message: error });
        });
    },
  });
});
