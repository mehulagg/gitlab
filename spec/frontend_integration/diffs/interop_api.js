/**
 * This helper module helps freeze the API expectation of the diff output.
 *
 * This helps simulate what third-parties, such as Sourcegraph, which scrape
 * the HTML shold be looking fo.
 *
 * TEMPORARY! These functions are copied from Sourcegraph
 */
export const getDiffCodePart = (codeElement) => {
  let selector = 'old';

  const row = codeElement.closest('.diff-td,td');

  // Split diff
  if (row.classList.contains('parallel')) {
    selector = 'left-side';
  }

  return row.classList.contains(selector) ? 'base' : 'head';
};

export const getCodeElementFromLineNumber = (codeView, line, part) => {
  const lineNumberElement = codeView.querySelector(
    `.${part === 'base' ? 'old_line' : 'new_line'} [data-linenumber="${line}"]`,
  );
  if (!lineNumberElement) {
    return null;
  }

  const row = lineNumberElement.closest('.diff-tr,tr');
  if (!row) {
    return null;
  }

  let selector = 'span.line';

  // Split diff
  if (row.classList.contains('parallel')) {
    selector = `.${part === 'base' ? 'left-side' : 'right-side'} ${selector}`;
  }

  return row.querySelector(selector);
};

export const getLineNumberFromCodeElement = (el) => {
  const part = getDiffCodePart(el);

  let cell = el.closest('.diff-td,td');
  while (
    cell &&
    !cell.matches(`.diff-line-num.${part === 'base' ? 'old_line' : 'new_line'}`) &&
    cell.previousElementSibling
  ) {
    cell = cell.previousElementSibling;
  }

  if (cell) {
    const a = cell.querySelector('a');
    return parseInt(a.dataset.linenumber || '', 10);
  }

  throw new Error('Unable to determine line number for diff code element');
};
