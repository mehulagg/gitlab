import { createFakeDateClass } from './fake_date';

describe('spec/helpers/fake_date', () => {
  describe('createFakeDateClass', () => {
    let FakeDate;

    beforeEach(() => {
      FakeDate = createFakeDateClass();
    });

    it('should use default args', () => {
      expect(new FakeDate()).toMatchInlineSnapshot(`2015-07-03T10:00:00.000Z`);
    });

    it('should use default args when called as a function', () => {
      expect(FakeDate()).toMatchInlineSnapshot(
        `"Fri Jul 03 2015 10:00:00 GMT+0000 (Greenwich Mean Time)"`,
      );
    });

    it('should have deterministic now()', () => {
      expect(FakeDate.now()).toMatchInlineSnapshot(`1435917600000`);
    });

    it('should be instanceof Date', () => {
      expect(new FakeDate()).toBeInstanceOf(Date);
    });

    it('should be instanceof self', () => {
      expect(new FakeDate()).toBeInstanceOf(FakeDate);
    });
  });
});
