

import 'dart:math';

enum PlayMode { in_order, repeat, repeat_one,  shuffle, only_one, only_two}

String enumToString(o) => o.toString().split('.').last;

T enumFromString<T>(Iterable<T> values, String value) {
  return values.firstWhere((type) => type.toString().split('.').last == value,
    orElse: () => null
  );
}

abstract class PlayListInterface {
  int tracesCount();
  int currentTraceIndex();
}

abstract class PlayStrategy {
  PlayListInterface _playList;

  PlayStrategy(this._playList);

  int get current => _playList.currentTraceIndex();
  int get count => _playList.tracesCount();

  int next();
  int previous();
  int play();

  bool canPrevious();
  bool canNext();
  bool canPlay();
  bool inPlayList(int index);

  void reset() {}

  void onItemRemovedAt(int index) {}
}

///
/// 顺序播放策略：从第一首播放到最后一首，不循环
///
class InOrderPlayStrategy extends PlayStrategy {
  InOrderPlayStrategy(PlayListInterface playList) : super(playList);

  @override
  bool canPrevious() => count>0 && current>0;

  @override
  bool canNext() => count>0 && current<(count-1);

  @override
  bool canPlay() => count>0;

  @override
  int next() => canNext()?((current + 1) % count):-1;

  @override
  int previous() => canPrevious()?((current - 1) % count):-1;

  @override
  int play() {
    if(!canPlay()) return -1;
    if(current<0) return 0;
    if(current>=count) return count-1;
    return current;
  }

  @override
  bool inPlayList(int index) => index>=0 && index<count;
}

///
/// 循环播放策略：从第一首到最后一首顺序播放，再从最后跳到第一首，如此循环
///
class RepeatPlayStrategy extends InOrderPlayStrategy {
  RepeatPlayStrategy(PlayListInterface playList) : super(playList);

  @override
  bool canPrevious() => count>0;

  @override
  bool canNext() => count>0;

  @override
  int previous() => canPrevious()?((current - 1)<0 ? (count-1) : ((current - 1) % count)):-1;
}

///
/// 循环播放一首策略
///
class RepeatOnePlayStrategy extends PlayStrategy {
  RepeatOnePlayStrategy(PlayListInterface playList) : super(playList);

  @override
  bool canPrevious() => count>0 && current>=0;

  @override
  bool canNext() => count>0 && current>=0;

  @override
  bool canPlay() => count>0;

  @override
  int next() => canNext()?current:-1;

  @override
  int previous() => canPrevious()?current:-1;

  @override
  int play() {
    if(!canPlay()) return -1;
    if(current<0) return 0;
    if(current>=count) return count-1;
    return current;
  }

  @override
  bool inPlayList(int index) => index==current;
}

///
/// 只播放一首策略
///
class OnlyOnePlayStrategy extends PlayStrategy {
  OnlyOnePlayStrategy(PlayListInterface playList) : super(playList);

  @override
  bool canPrevious() => false;

  @override
  bool canNext() => false;

  @override
  bool canPlay() => count>0;

  @override
  int next() => -1;

  @override
  int previous() => canPlay()?current:-1;

  @override
  int play() {
    if(!canPlay()) return -1;
    if(current<0) return 0;
    if(current>=count) return count-1;
    return current;
  }

  @override
  bool inPlayList(int index) => index==current;
}

///
/// 乱序播放策略：乱序、循环播放
///
class ShufflePlayStrategy extends RepeatPlayStrategy {

  final List<int> _todoList = [];   // 待播放列表
  final List<int> _doneList = [];   // 已播放，实现上一首功能
  void _initList() {
    // 构建新的待放列表
    _todoList.clear();
    for(var i=0;i<count;i++) _todoList.add(i);
    _todoList.shuffle();

    // 裁剪超长的已播放列表
    int overLong = _doneList.length - count;
    if(overLong>0) {
      _doneList.removeRange(0, overLong);
    }

    // 优化：下一首待放，如果刚刚放过，就移到最后
    if(_doneList.length>0 && _todoList.length>1 && _todoList.last==_doneList.last) {
      int i = _todoList.removeLast();
      _todoList.insert(0, i);
    }

    print('_todoList: '+_todoList.toString());
    print('_doneList: '+_doneList.toString());
  }

  // 下一个
  int get _nextRandomInt {
    if(_todoList.length==0) _initList();
    if(_todoList.length==0) return -1;

    int index = _todoList.removeLast();
    _doneList.add(index);

    return index;
  }

  // 上一个
  int get _previousIndex {
    if(_doneList.length<=0) return -1;
    return _doneList.removeLast();
  }

  ShufflePlayStrategy(PlayListInterface playList) : super(playList);

  @override
  bool canPrevious() => count>0 && _doneList.length>0;

  @override
  int next() => canNext()?_nextRandomInt:-1;

  @override
  int previous() => canPrevious()?_previousIndex:-1;

  @override
  int play() {
    if(!canPlay()) return -1;
    return _nextRandomInt;
  }

  @override
  void reset() {
    _todoList.clear();
    _doneList.clear();
  }

  @override
  void onItemRemovedAt(int index) {
    reset();
  }

}

///
/// 只顺序播放N首策略
///
class OnlyNPlayStrategy extends PlayStrategy {
  int firstIndex;
  int n;

  OnlyNPlayStrategy(PlayListInterface playList, int n) : super(playList) {
    this.n=n;
    this.firstIndex=current;
  }

  @override
  bool canPrevious() => n>0 && count>0 && current>this.firstIndex;

  @override
  bool canNext() => n>0 && count>0 && current<(count-1) && current<(this.firstIndex+n-1);

  @override
  bool canPlay() => n>0 && count>0;

  @override
  int next() => canNext()?((current - this.firstIndex + 1) % n + this.firstIndex ):-1;

  @override
  int previous() => canPrevious()?((current - this.firstIndex - 1) % n + this.firstIndex):-1;

  @override
  int play() {
    print('OnlyNPlayStrategy play() - first: '+firstIndex.toString()+', n: '+n.toString());
    if(!canPlay()) return -1;
    if(this.firstIndex<0) this.firstIndex=0;
    if(current<this.firstIndex) return this.firstIndex;
    if(current>=(this.firstIndex+n)) return this.firstIndex+n-1;
    return current;
  }

  @override
  void reset() {
    this.firstIndex=current;
    print('OnlyNPlayStrategy reset() - first: '+firstIndex.toString()+', n: '+n.toString());
  }

  @override
  bool inPlayList(int index) => index>=this.firstIndex && index<(this.firstIndex+n);
}

