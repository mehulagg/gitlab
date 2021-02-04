import { createConsumer, logger } from '@rails/actioncable';
import ConnectionMonitor from './actioncable_connection_monitor';

const consumer = createConsumer();

consumer.connection.monitor = new ConnectionMonitor(consumer.connection);

export default consumer;
