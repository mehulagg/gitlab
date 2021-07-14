import { TableCell } from '@tiptap/extension-table-cell';
import { isBlockTable } from './table';

export const tiptapExtension = TableCell.extend();

export function shouldRenderInline(cell) {
  return cell.childCount === 1 && cell.child(0).type.name === 'paragraph';
}

export function serializer(state, node) {
  if (!isBlockTable(node) || shouldRenderInline(node)) {
    state.renderInline(node.child(0));
  } else {
    state.renderContent(node);
  }
}
