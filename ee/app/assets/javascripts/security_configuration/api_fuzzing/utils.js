/* eslint-disable @gitlab/require-i18n-strings */
import { isString } from 'lodash';

export const insertTip = ({ snippet, tip, token }) => {
  if (!isString(snippet)) {
    throw new Error('snippet must be a string');
  }
  if (!isString(tip)) {
    throw new Error('tip must be a string');
  }
  if (!isString(token)) {
    throw new Error('token must be a string');
  }
  return snippet.replace(token, `# ${tip}\n${token}`);
};

export const insertTips = (snippet, tips = []) =>
  tips.reduce(
    (snippetWithTips, { tip, token }) => insertTip({ snippet: snippetWithTips, tip, token }),
    snippet,
  );
