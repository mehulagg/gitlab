import { stringToArrayBuffer } from '~/lib/utils/array_buffer';

describe('~/lib/utils/array_buffer', () => {
  describe('stringToArrayBuffer', () => {
    it('converts string to array buffer', () => {
      const ab = stringToArrayBuffer('Lorem ipsum dolar sit');

      expect(String.fromCharCode.apply(null, new Uint8Array(ab))).toBe('Lorem ipsum dolar sit');
    });
  });
});
