import { isToday } from '~/lib/utils/datetime_utility';

/**
 * A helper function which accepts the segments,
 *
 * @param {Object} params the segment data, timestamp and check for open modals
 *
 * @return {Boolean} a boolean to determine if table data should be polled
 */
export const shouldPollTableData = ({ segments, timestamp, openModal }) => {
  if (openModal) {
    return false;
  } else if (!segments.length) {
    return true;
  }

  const anyPendingSegments = segments.some((node) => node.latestSnapshot === null);
  const dataNotRefreshedToday = !isToday(new Date(timestamp));

  return anyPendingSegments || dataNotRefreshedToday;
};
