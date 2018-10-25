import somethingEE from 'ee/something_ee.vue';

describe('something EE', () => {
  it('has extends', () => {
    expect(somethingEE.extends).toBe('somethingEE.extends');
  });
});
