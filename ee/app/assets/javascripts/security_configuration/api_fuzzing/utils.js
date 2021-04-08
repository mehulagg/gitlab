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
  const lines = snippet.split('\n');
  for (let i = 0; i < lines.length; i += 1) {
    if (lines[i].includes(token)) {
      const indent = lines[i].match(/^[ \t]+/)?.[0] ?? '';
      lines[i] = lines[i].replace(token, `# ${tip}\n${indent}${token}`);
      break;
    }
  }
  return lines.join('\n');
};

export const insertTips = (snippet, tips = []) =>
  tips.reduce(
    (snippetWithTips, { tip, token }) => insertTip({ snippet: snippetWithTips, tip, token }),
    snippet,
  );
