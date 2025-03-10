
//订阅者回调签名
typedef void EventCallback(arg);

class EventBus {

  //私有构造函数
  EventBus._internal();

  //保持单例
  static EventBus _singleton = EventBus._internal();

  //工厂构造函数
  factory EventBus() => _singleton;

  //保存事件订阅者队列，key: 事件名成 value:对应的事件订阅者队列
  final Map _emap = Map<Object, List<EventCallback>>();
  //添加订阅者
  void on(String eventName, EventCallback callback) {
    _emap[eventName] ??= <EventCallback>[];
    _emap[eventName].add(callback);
  }

  //移除订阅者
  void off(String eventName, [EventCallback? f]) {
    var list = _emap[eventName];
    if (list == null) {
      return;
    }
    if (f == null){
      // _emap[eventName] = null;
      _emap.remove(eventName);
    } else {
      list.remove(f);
    }
  }

  //触发事件，事件触发后该事件所有订阅者会被调用
  void emit(String eventName, [arg]) {
    var list = _emap[eventName];
    if (list ==null) return;
    int len = list.length-1;
    //反向遍历，防止订阅者在回调中移除自身带来的下标错位
    for (var i=len; i>-1; --i){
      list[i](arg);
    }
  }
}