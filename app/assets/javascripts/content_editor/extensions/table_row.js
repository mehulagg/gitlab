import { TableRow } from '@tiptap/extension-table-row';

export const tiptapExtension = TableRow;

export function serializer(state, node) {
  let numHeaders = 0;

  state.write('|');
  node.forEach((child) => {
    if (child.type.name === 'tableHeader') {
      numHeaders += 1;
    }
    state.renderInline(child);
    state.write('|');
  });
  state.write('\n');

  if (numHeaders) {
    state.write('|');
    state.write(state.repeat('--|', numHeaders));
    state.write('\n');
  }
}
