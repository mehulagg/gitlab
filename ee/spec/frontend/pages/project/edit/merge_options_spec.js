describe('Merge Options Settings', () => {
  let mergePipelinesCheckbox;
  let mergeTrainsCheckbox;

  beforeEach(() => {
    loadFixtures('static/merge_options_settings.html');
    mergePipelinesCheckbox = document.querySelector('.js-merge-options-merge-pipelines');
    mergeTrainsCheckbox = document.querySelector('.js-merge-options-merge-trains');
});

  describe('before fetching the GraphQL query', () => {
    it('checkboxes for merge pipelines and merge trains are enabled by default', () => {
      expect(mergePipelinesCheckbox.disabled).toBe(false);
      expect(mergeTrainsCheckbox.disabled).toBe(false);
    });
  });

  describe('when merge pipelines is enabled', () => {
    it('checkboxes for merge pipelines and merge trains are enabled', () => {
      // TODO: mock graphql response

      expect(mergePipelinesCheckbox.disabled).toBe(false);
      expect(mergeTrainsCheckbox.disabled).toBe(false);
    });
  });

  // TODO

  // describe('when merge pipelines is disabled', () => {
  //   it('checkboxes for merge pipelines and merge trains are disabled', () => {
  //     expect(mergePipelinesCheckbox.disabled).toBe(true);
  //     expect(mergeTrainsCheckbox.disabled).toBe(true);
  //   });
  // });

  // describe('when merge trains is disabled', () => {
  //   it('only merge trains checkbox is disabled', () => {
  //     expect(mergePipelinesCheckbox.disabled).toBe(false);
  //     expect(mergeTrainsCheckbox.disabled).toBe(true);
  //   });
  // });

  // describe('when GraphQL query fails to fetch', () => {
  //   it('checkboxes for merge pipelines and merge trains are disabled', () => {
  //     expect(mergePipelinesCheckbox.disabled).toBe(true);
  //     expect(mergeTrainsCheckbox.disabled).toBe(true);
  //   });
  // });
});
