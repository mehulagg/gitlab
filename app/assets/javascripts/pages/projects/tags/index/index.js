import axios from '~/lib/utils/axios_utils';
import initConfirmModal from '~/confirm_modal';

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
          console.log('FAILLLLED', error);
        });
    },
  });
});
