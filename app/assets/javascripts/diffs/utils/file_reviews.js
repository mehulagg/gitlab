function getFileReviewsKey(mrPath) {
  return `${mrPath}-file-reviews`;
}

export function getReviewsForMergeRequest(mrPath) {
  const reviewsForMr = localStorage.getItem(getFileReviewsKey(mrPath));
  let reviews = {};

  if (reviewsForMr) {
    try {
      reviews = JSON.parse(reviewsForMr);
    } catch (err) {
      reviews = {};
    }
  }

  return reviews;
}

export function setReviewsForMergeRequest(mrPath, reviews) {
  localStorage.setItem(getFileReviewsKey(mrPath), JSON.stringify(reviews));

  return reviews;
}

export function getReviewForFile(reviews, file) {
  const fileReviews = reviews[file.file_identifier_hash];

  return file?.id && fileReviews ? fileReviews[file.id] : null;
}

export function reviewable(file) {
  return Boolean(file.id) && Boolean(file.file_identifier_hash);
}

export function markFileReviewed(reviews, file) {
  const usableReviews = { ...(reviews || {}) };
  let updatedReviews = usableReviews;
  let fileReviews;

  if (reviewable(file)) {
    fileReviews = { ...(usableReviews[file.file_identifier_hash] || {}) };

    fileReviews[file.id] = {
      date: new Date().toISOString(),
    };

    updatedReviews = {
      ...usableReviews,
      [file.file_identifier_hash]: fileReviews,
    };
  }

  return updatedReviews;
}
