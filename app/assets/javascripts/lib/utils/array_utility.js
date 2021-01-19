/**
 * Swaps 2 items in array immutably by their index and return an new array
 *
 * @param {Array} target - The source array
 * @param {Number} [leftIndex=0] - Index of the first item
 * @param {Number} rightIndex - Index of the second item
 * @returns {Array} new array with the left and right item swapped
 */
export const swapArrayItems = ({ target = [], leftIndex = null, rightIndex = 0 }) => {
  if (target.length > 1 && rightIndex && rightIndex > leftIndex) {
    if (target.length < 3) return [target[rightIndex], target[leftIndex]];
    const middle = rightIndex - leftIndex > 0 ? target.slice(leftIndex + 1, rightIndex) : [];
    const head = target.slice(0, leftIndex);
    const tail = target.slice(rightIndex + 1, target.length);
    return [].concat(head, target[rightIndex], middle, target[leftIndex], tail);
  }
  return target;
};
