

import 'dart:math';

enum PlayMode { in_order, repeat, repeat_one,  shuffle}

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
}

///
/// 乱序播放策略：乱序、循环播放
///
class ShufflePlayStrategy extends RepeatPlayStrategy {
  final Random _random = Random();

  // 下一个不等于current的索引，除非只有1个
  int get _nextRandomInt {
    if(count<2) return current;
    int index = current;
    while(index==current) {
     index = _random.nextInt(count);
    }
    return index;
  }
  
  ShufflePlayStrategy(PlayListInterface playList) : super(playList);

  @override
  int next() => canNext()?_nextRandomInt:-1;

  @override
  int previous() => canPrevious()?((current - 1)<0 ? (count-1) : ((current - 1) % count)):-1;

  @override
  int play() {
    if(!canPlay()) return -1;
    return _nextRandomInt;
  }
}
