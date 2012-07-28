#library("eventaggregator");
#import("../common/common.dart");
#source("eventargs.dart");

/**
 * EventAggregator is a class that provides pub/sub pattern for
 * event/command management
 */ 
interface EventAggregator {
  void pub(String eventClassName, EventArgs e);
  void sub(String eventClassName, Hashable subscriber, EventHandler h);
  void unSub(String eventClassName, Hashable subscriber);
}

/**
 * Prorvides a singleton global event manager. 
 * Use dependency injection if possible instead of this class.
 */
class GlobalEventManager {
  static var _agger;
  static EventAggregator get eventAggregator() {
    if (_agger == null) {
      _agger = new NamedEventAggregator();
    }
    return _agger;
  }
}

class _eventHandler implements Hashable {
  final EventHandler hanler;
  final Hashable caller;
  _eventHandler(this.hanler, this.caller);
  int hashCode(){
    return caller.hashCode();
  }
}

/**
 * Don't use this directly.
 */
class NamedEventAggregator implements EventAggregator {
  Map<String, Set<_eventHandler>> _assignments;
  
  NamedEventAggregator() : _assignments = new Map<String, Set<_eventHandler>>();
  
  void pub(String eventClass, EventArgs e){
    var subers = _getAssignments(eventClass);
    for(var suber in subers){
      suber.hanler(e);
    }
  }
  
  Set<_eventHandler> _getAssignments(String eventClass){
    return _assignments[eventClass];
  }
  
  /**
   * Subscribes to an event class,
   * Note that if the subscriber has already subscribed to the event before,
   * an exception will be thrown
   * I.e. no duplicate subscriber for one class is possible
   */
  void sub(String eventClassName, Hashable subscriber, EventHandler e){
    _assignments.putIfAbsent(eventClassName, () => new Set<_eventHandler>());
    var subers = _assignments[eventClassName];
    var handler = new _eventHandler(e, subscriber);
    if (subers.contains(handler)) {
      throw new IllegalArgumentException("Subscriber is already subscribed to the event ".concat(eventClassName));
    }
    _assignments[eventClassName].add( handler );
  }
  
  void unSub(String eventClassName, Hashable subscriber){
    var subers = _getAssignments(eventClassName);
    if (subers != null){
      var lup = subers.filter((e) => e.caller === subscriber);
      if (lup!=null && !lup.isEmpty())
      {
        for(var l in lup){
          subers.remove(l);
        }
      }
    }
  }
}