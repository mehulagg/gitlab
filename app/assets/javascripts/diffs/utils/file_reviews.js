export function getReviewsForMergeRequest(mrPath) {
  const reviewsForMr = localStorage.getItem(mrPath);
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
  localStorage.setItem(mrPath, JSON.stringify(reviews));

  return reviews;
}

export function getReviewForFile(reviews, file) {
  const fileReviews = reviews[file.file_identifier_hash];

  return file?.id && fileReviews ? fileReviews[file.id] : null;
}

export function markFileReviewed(reviews, file) {
  const fileReviews = { ...(reviews[file.file_identifier_hash] || {}) };

  fileReviews[file.id] = {
    date: new Date().toISOString(),
  };

  return {
    ...reviews,
    [file.file_identifier_hash]: fileReviews,
  };
}

export function reviewable(file) {
  return file.id;
}
