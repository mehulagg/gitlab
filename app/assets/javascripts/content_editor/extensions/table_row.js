import { TableRow } from '@tiptap/extension-table-row';
import { isBlockTable } from './table';
import { shouldRenderInline } from './table_cell';

export const tiptapExtension = TableRow.extend({
  allowGapCursor: false,
});

export function serializer(state, node) {
  const isHeaderRow = node.child(0).type.name === 'tableHeader';
  const open = (tag, align) => `<${tag}${align ? ` align="${align}"` : ''}>`;
  const close = (tag) => `</${tag}>`;

  const renderRow = () => {
    const cellWidths = [];

    state.flushClose(1);

    state.write('| ');
    node.forEach((cell, _, i) => {
      if (i) state.write(' | ');

      const { length } = state.out;
      state.render(cell, node, i);
      cellWidths.push(state.out.length - length);
    });
    state.write(' |');

    state.closeBlock(node);

    return cellWidths;
  };

  const renderHeaderRow = (cellWidths) => {
    state.flushClose(1);

    state.write('|');
    node.forEach((cell, _, i) => {
      if (i) state.write('|');

      state.write(cell.attrs.align === 'center' ? ':' : '-');
      state.write(state.repeat('-', cellWidths[i]));
      state.write(cell.attrs.align === 'center' || cell.attrs.align === 'right' ? ':' : '-');
    });
    state.write('|');

    state.closeBlock(node);
  };

  if (isBlockTable(node)) {
    const tag = isHeaderRow ? 'th' : 'td';

    state.write(open('tr'));
    node.forEach((cell, _, i) => {
      state.write(open(tag, cell.attrs.align));
      if (!shouldRenderInline(cell)) {
        state.write('\n\n');
      }
      state.render(cell, node, i);
      state.flushClose(1);
      state.write(close(tag));
    });
    state.write(close('tr'));
  } else if (isHeaderRow) {
    renderHeaderRow(renderRow());
  } else {
    renderRow();
  }
}
