// Checks for a valid date string
export const isValidSlaDueAt = (slaDueAt) =>
  Boolean(slaDueAt) && !Number.isNaN(Date.parse(slaDueAt));
