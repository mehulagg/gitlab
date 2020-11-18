export const AVAILABILITY_STATUS = {
  BUSY: 'busy',
  NOT_SET: 'not_set',
};

export const isUserBusy = status => status === AVAILABILITY_STATUS.BUSY;

const defaultEmoji = 'speech_balloon';

export const hasStatusSet = ({ message, emoji }) => message || emoji !== defaultEmoji;

export const isValidAvailibility = availability =>
  availability.length ? Object.values(AVAILABILITY_STATUS).includes(availability) : true;
