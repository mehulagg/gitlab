import { useLocalStorageSpy } from 'helpers/local_storage_helper';
import { useFakeDate } from 'helpers/fake_date';

import {
  getReviewsForMergeRequest,
  setReviewsForMergeRequest,
  getReviewForFile,
  markFileReviewed,
  reviewable,
} from '~/diffs/utils/file_reviews';

const fakeDate = [2020, 11, 15, 13, 25]; // 2020 December 15, 13:25 (1:25 PM)

function getDefaultReviews() {
  return {
    abc: {
      '123': { date: new Date(...fakeDate).toISOString() },
    },
  };
}

describe('File Review(s) utilities', () => {
  const mrPath = 'my/fake/mr/42';
  const file = { id: '123', file_identifier_hash: 'abc' };
  const storedValue = JSON.stringify(getDefaultReviews());
  let reviews;

  useLocalStorageSpy();
  useFakeDate(...fakeDate);

  beforeEach(() => {
    reviews = getDefaultReviews();
    localStorage.clear();
  });

  describe('getReviewsForMergeRequest', () => {
    it('fetches the appropriate stored reviews from localStorage', () => {
      getReviewsForMergeRequest(mrPath);

      expect(localStorage.getItem).toHaveBeenCalledTimes(1);
      expect(localStorage.getItem).toHaveBeenCalledWith(mrPath);
    });

    it('returns an empty object if there have never been stored reviews for this MR', () => {
      expect(getReviewsForMergeRequest(mrPath)).toStrictEqual({});
    });

    it.each`
      data
      ${'+++'}
      ${'{ lookinGood: "yeah!", missingClosingBrace: "yeah :(" '}
    `(
      "returns an empty object if the stored reviews are corrupted/aren't parseable as JSON (like: $data)",
      ({ data }) => {
        localStorage.getItem.mockReturnValueOnce(data);

        expect(getReviewsForMergeRequest(mrPath)).toStrictEqual({});
      },
    );

    it('fetches the reviews for the MR if they exist', () => {
      localStorage.setItem(mrPath, storedValue);

      expect(getReviewsForMergeRequest(mrPath)).toStrictEqual(reviews);
    });
  });

  describe('setReviewsForMergeRequest', () => {
    it('sets the new value to localStorage', () => {
      setReviewsForMergeRequest(mrPath, reviews);

      expect(localStorage.setItem).toHaveBeenCalledTimes(1);
      expect(localStorage.setItem).toHaveBeenCalledWith(mrPath, storedValue);
    });

    it('returns the new value for chainability', () => {
      expect(setReviewsForMergeRequest(mrPath, reviews)).toStrictEqual(reviews);
    });
  });

  describe('getReviewForFile', () => {
    it.each`
      description                            | diffFile                      | fileReviews
      ${'the file does not have an `id`'}    | ${{ ...file, id: undefined }} | ${getDefaultReviews()}
      ${'there are no reviews for the file'} | ${file}                       | ${{ ...getDefaultReviews(), abc: undefined }}
    `('returns null if $description', ({ diffFile, fileReviews }) => {
      expect(getReviewForFile(fileReviews, diffFile)).toBe(null);
    });

    it("returns the review for a file if it's available in the provided reviews", () => {
      expect(getReviewForFile(reviews, file)).toStrictEqual(reviews.abc[123]);
    });
  });

  describe('reviewable', () => {
    it.each`
      response | diffFile                                        | description
      ${true}  | ${file}                                         | ${'has an `.id` and a `.file_identifier_hash`'}
      ${false} | ${{ file_identifier_hash: 'abc' }}              | ${'does not have an `.id`'}
      ${false} | ${{ ...file, id: undefined }}                   | ${'has an undefined `.id`'}
      ${false} | ${{ ...file, id: null }}                        | ${'has a null `.id`'}
      ${false} | ${{ ...file, id: 0 }}                           | ${'has an `.id` set to 0'}
      ${false} | ${{ ...file, id: false }}                       | ${'has an `.id` set to false'}
      ${false} | ${{ id: '123' }}                                | ${'does not have a `.file_identifier_hash`'}
      ${false} | ${{ ...file, file_identifier_hash: undefined }} | ${'has an undefined `.file_identifier_hash`'}
      ${false} | ${{ ...file, file_identifier_hash: null }}      | ${'has a null `.file_identifier_hash`'}
      ${false} | ${{ ...file, file_identifier_hash: 0 }}         | ${'has a `.file_identifier_hash` set to 0'}
      ${false} | ${{ ...file, file_identifier_hash: false }}     | ${'has a `.file_identifier_hash` set to false'}
    `('returns `$response` when the file $description`', ({ response, diffFile }) => {
      expect(reviewable(diffFile)).toBe(response);
    });
  });

  describe('markFileReviewed', () => {
    it("adds a review when there's nothing that already exists", () => {
      expect(markFileReviewed(null, file)).toStrictEqual(reviews);
    });

    it("overwrites an existing review if it's for the same file (identifier hash)", () => {
      expect(markFileReviewed(reviews, file)).toStrictEqual(getDefaultReviews());
    });

    it('adds a new review if the file ID is new', () => {
      const updatedFile = { ...file, id: '098' };
      const newReview = getDefaultReviews();
      const allReviews = markFileReviewed(reviews, updatedFile);

      newReview.abc['098'] = { date: new Date().toISOString() };

      expect(allReviews).toStrictEqual(newReview);
      expect(allReviews.abc['123'].date).toBe(new Date(...fakeDate).toISOString());
      expect(allReviews.abc['098'].date).toBe(new Date(...fakeDate).toISOString());
    });

    it.each`
      description                            | diffFile
      ${'missing an `.id`'}                  | ${{ file_identifier_hash: 'abc' }}
      ${'missing a `.file_identifier_hash`'} | ${{ id: '123' }}
    `("doesn't modify the reviews if the file is $description", ({ diffFile }) => {
      expect(markFileReviewed(reviews, diffFile)).toStrictEqual(getDefaultReviews());
    });
  });
});
