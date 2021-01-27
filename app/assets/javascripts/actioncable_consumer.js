import { ConnectionMonitor, createConsumer } from '@rails/actioncable';

ConnectionMonitor.pollInterval.max = 300;

export default createConsumer();
