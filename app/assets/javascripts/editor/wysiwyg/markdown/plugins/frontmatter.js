// Process front matter and pass to cb
export const parse = md => {
  const minMarkers = 3;
  const markerStr = '-';
  const markerChar = markerStr.charCodeAt(0);
  const markerLen = markerStr.length;

  function frontMatter(state, startLine, endLine, silent) {
    let pos;
    let nextLine;
    let startContent;
    let autoClosed = false;
    let start = state.bMarks[startLine] + state.tShift[startLine];
    let max = state.eMarks[startLine];

    // Check out the first character of the first line quickly,
    // this should filter out non-front matter
    if (startLine !== 0 || markerChar !== state.src.charCodeAt(0)) {
      return false;
    }

    // Check out the rest of the marker string
    // while pos <= 3
    for (pos = start + 1; pos <= max; pos += 1) {
      if (markerStr[(pos - start) % markerLen] !== state.src[pos]) {
        startContent = pos + 1;
        break;
      }
    }

    const markerCount = Math.floor((pos - start) / markerLen);

    if (markerCount < minMarkers) {
      return false;
    }
    pos -= (pos - start) % markerLen;

    // Since start is found, we can report success here in validation mode
    if (silent) {
      return true;
    }

    // Search for the end of the block
    nextLine = startLine;

    for (;;) {
      nextLine += 1;
      if (nextLine >= endLine) {
        // unclosed block should be autoclosed by end of document.
        // also block seems to be autoclosed by end of parent
        break;
      }

      if (state.src.slice(start, max) === '...') {
        break;
      }

      start = state.bMarks[nextLine] + state.tShift[nextLine];
      max = state.eMarks[nextLine];

      if (start < max && state.sCount[nextLine] < state.blkIndent) {
        // non-empty line with negative indent should stop the list:
        // - ```
        //  test
        break;
      }

      if (markerChar !== state.src.charCodeAt(start)) {
        // eslint-disable-next-line no-continue
        continue;
      }

      if (state.sCount[nextLine] - state.blkIndent >= 4) {
        // closing fence should be indented less than 4 spaces
        // eslint-disable-next-line no-continue
        continue;
      }

      for (pos = start + 1; pos <= max; pos += 1) {
        if (markerStr[(pos - start) % markerLen] !== state.src[pos]) {
          break;
        }
      }

      // closing code fence must be at least as long as the opening one
      if (Math.floor((pos - start) / markerLen) < markerCount) {
        // eslint-disable-next-line no-continue
        continue;
      }

      // make sure tail has spaces only
      pos -= (pos - start) % markerLen;
      pos = state.skipSpaces(pos);

      if (pos < max) {
        // eslint-disable-next-line no-continue
        continue;
      }

      // found!
      autoClosed = true;
      break;
    }

    const oldParent = state.parentType;
    const oldLineMax = state.lineMax;
    state.parentType = 'container';

    // this will prevent lazy continuations from ever going past our end marker
    state.lineMax = nextLine;

    const token = state.push('front_matter', null, 0);
    token.hidden = true;
    token.markup = state.src.slice(startLine, pos);
    token.block = true;
    token.map = [startLine, pos];
    token.content = state.src.slice(startContent, start - 1);

    state.parentType = oldParent;
    state.lineMax = oldLineMax;
    state.line = nextLine + (autoClosed ? 1 : 0);

    return true;
  }

  md.block.ruler.before('table', 'front_matter', frontMatter, {
    alt: ['paragraph', 'reference', 'blockquote', 'list'],
  });
};

export const serialize = (state, node) => {
  state.write(`---\n`);
  state.text(node.textContent, false);
  state.ensureNewLine();
  state.write('---\n');
  state.closeBlock(node);
};

export const mapper = {
  front_matter: { block: 'frontmatter', noCloseToken: true },
};
