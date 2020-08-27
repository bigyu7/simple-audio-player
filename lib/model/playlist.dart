
class PlayListItem {
  String file;
  String title;
  int length;

  PlayListItem(this.file,this.title,this.length);

  @override
  bool operator ==(other) {
    // 判断是否是非
    if(other is! PlayListItem){
      return false;
    }
    return file == other.file;
  }

  @override
  int get hashCode => file.hashCode;

}

class PlayList {
  String name;
  String filePath;
  final List<PlayListItem> _traces;

  PlayList(this.filePath, this.name, this._traces);

  List<PlayListItem> get traces => _traces;

  PlayListItem getByPosition(int postion) {
    if(_traces.length==0) return null;
    if(postion<0) postion=0;
    return _traces[postion%_traces.length];
  }

  int get tracesCount => _traces.length;

  bool add(PlayListItem item) {
    // 如果已经在列表中，就不添加
    for(var i in _traces) {
      if(i==item) return false;
    }
    _traces.add(item);
    return true;
  }

  PlayListItem removePlayListItemAt(int index) {
    if(_traces.length==0 || index<0 || index>=_traces.length) return null;
    return _traces.removeAt(index);
  }

  /**
   * 调整在列表中的位置
   * 返回新位置
   */
  int reorderPlayListItem(int oldIndex, int newIndex) {
    if(_traces.length==0 || oldIndex<0 || oldIndex>=_traces.length) return -1;

    if(oldIndex < newIndex) {
      newIndex -= 1;
    }

    PlayListItem temp = _traces.removeAt(oldIndex);
    _traces.insert(newIndex, temp);
    return newIndex;
  }
}

