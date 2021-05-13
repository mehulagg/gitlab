import {
  mapParallel as CEMapParallel,
  mapInline as CEMapInline,
} from '~/diffs/components/diff_row_utils';

export const mapParallel = (content) => (line) => {
  let { left, right } = line;

  if (left) {
    left = {
      ...left,
      codequality: content.fileLineCodequality(content.diffFile.file_path, left.new_line),
    };
  }
  if (right) {
    right = {
      ...right,
      codequality: content.fileLineCodequality(content.diffFile.file_path, right.new_line),
    };
  }

  return {
    ...CEMapParallel(content)({
      ...line,
      left,
      right,
    }),
  };
};

export const mapInline = CEMapInline;
