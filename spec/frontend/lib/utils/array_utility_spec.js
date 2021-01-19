import * as arrayUtils from '~/lib/utils/array_utility';

describe('array_utility', () => {
  describe('swapArrayItems', () => {
    it.each`
      target             | leftIndex | rightIndex | result
      ${[]}              | ${0}      | ${0}       | ${[]}
      ${[]}              | ${0}      | ${0}       | ${[]}
      ${[1]}             | ${0}      | ${1}       | ${[1]}
      ${[1, 2]}          | ${0}      | ${0}       | ${[1, 2]}
      ${[1, 2]}          | ${0}      | ${1}       | ${[2, 1]}
      ${[1, 2, 3]}       | ${0}      | ${2}       | ${[3, 2, 1]}
      ${[1, 2, 3, 4]}    | ${0}      | ${2}       | ${[3, 2, 1, 4]}
      ${[1, 2, 3, 4, 5]} | ${0}      | ${4}       | ${[5, 2, 3, 4, 1]}
      ${[1, 2, 3, 4, 5]} | ${1}      | ${2}       | ${[1, 3, 2, 4, 5]}
    `(
      'given $target with index $leftIndex and $rightIndex will return $result',
      ({ target, leftIndex, rightIndex, result }) => {
        expect(arrayUtils.swapArrayItems({ target, leftIndex, rightIndex })).toEqual(result);
      },
    );
  });
});
