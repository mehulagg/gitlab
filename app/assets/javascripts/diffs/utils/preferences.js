import Cookies from 'js-cookie';
import { DIFF_FILE_BY_FILE_COOKIE_NAME, DIFF_VIEW_FILE_BY_FILE } from '../constants';

export function fileByFile(pref = false) {
  const cookie = Cookies.get(DIFF_FILE_BY_FILE_COOKIE_NAME);
  let viewFileByFile = pref;

  // use the cookie first, if it exists
  if (cookie) {
    viewFileByFile = cookie === DIFF_VIEW_FILE_BY_FILE;
  }

  return viewFileByFile;
}
