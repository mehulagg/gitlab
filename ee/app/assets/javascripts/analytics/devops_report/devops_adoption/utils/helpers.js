import { isToday } from '~/lib/utils/datetime_utility';

/**
 * A helper function which accepts the enabledNamespaces,
 *
 * @param {Object} params the enabledNamespaces data, timestamp and check for open modals
 *
 * @return {Boolean} a boolean to determine if table data should be polled
 */
export const shouldPollTableData = ({ enabledNamespaces, timestamp, openModal }) => {
  if (openModal) {
    return false;
  } else if (!enabledNamespaces.length) {
    return true;
  }

  const anyPendingEnabledNamespaces = enabledNamespaces.some(
    (node) => node.latestSnapshot === null,
  );
  const dataNotRefreshedToday = !isToday(new Date(timestamp));

  return anyPendingEnabledNamespaces || dataNotRefreshedToday;
};
