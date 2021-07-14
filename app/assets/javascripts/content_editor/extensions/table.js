import { Table } from '@tiptap/extension-table';
import { uniq } from 'lodash';

export const tiptapExtension = Table;

function getRowsAndCells(table) {
  const cells = [];
  const rows = [];
  table.descendants((n) => {
    if (n.type.name === 'tableCell' || n.type.name === 'tableHeader') {
      cells.push(n);
      return false;
    }

    if (n.type.name === 'tableRow') {
      rows.push(n);
    }

    return true;
  });
  return { rows, cells };
}

function hasBlockContent(table) {
  const { cells } = getRowsAndCells(table);

  const childCount = Math.max(...cells.map((cell) => cell.childCount));
  if (childCount === 1) {
    const children = uniq(cells.map((cell) => cell.child(0).type.name));
    if (children.length === 1 && children[0] === 'paragraph') {
      return false;
    }
  }

  return true;
}

const map = new Map();

export function isBlockTable(table) {
  return map.has(table);
}

function mapSet(m, key, value) {
  if (value) m.set(key, value);
  else m.delete(key);
}

function setIsBlockTable(table, value) {
  mapSet(map, table, value);

  const { rows, cells } = getRowsAndCells(table);
  rows.forEach((row) => mapSet(map, row, value));
  cells.forEach((cell) => mapSet(map, cell, value));
}

export function serializer(state, node) {
  if (hasBlockContent(node)) {
    setIsBlockTable(node, true);
  }

  if (isBlockTable(node)) state.write('<table>');

  state.renderContent(node);

  if (isBlockTable(node)) state.write('</table>');

  map.delete(node);
}
