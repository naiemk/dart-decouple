/**
  * Represents arguments for an event.
*/
class EventArgs<E> {
  E payload;
  EventArgs(this.payload);
}

/**
 * Identifies an event handler to be used by event aggregator
 */
typedef void EventHandler<E>(EventArgs<E> e);