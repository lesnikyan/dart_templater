import 'dart:mirrors';

class TplContext{
  Map data = {};
  List<Map> subData = [];
  Map info = {};

  TplContext([Map this.data]){}

  void add(Map data){
    this.data.addAll(data);
  }

  void remove(List keys){
    keys.forEach((key){data.remove(key);});
  }

  /**
   * key = '\w+' for scalar value
   * or '(\w.)+\w+' for field of object
   */
  Object value(String key){
    String firstKey = key;
    bool scalar = ! key.contains('.');
    List<String> segments;
    if(!scalar){
      segments = key.split('.');
      firstKey = segments[0];
    }
  //  print("firstKey = $firstKey");
    Object subVal = fromSub(firstKey);
    if( subVal == null && !data.containsKey(firstKey))
      return null; // throw Exception(Tpl: incorrect var name');
    Object src = subVal != null ? subVal : data[firstKey];
    if(scalar)
      return src;
    return valueByList(src, segments.skip(1).toList());
  }

  Object fromSub(String key){
    // from and to begin
    for(int i = subData.length-1; i >= 0 ; --i){
      if(subData[i].containsKey(key))
        return subData[i][key];
    }
    return null;
  }

  Object valueByList(Object src, List<String> keys){
    Object next = src;
    for(int i=0; i < keys.length; ++i){
      next = valueFromObject(next, keys[i]);
      if(next == null)
        return null;
    }
    return next;
  }

  Object valueFromObject(Object src, String key){
    InstanceMirror mirror = reflect(src);
   // print("fromOb key = $key");
    Object val = mirror.getField(new Symbol(key)).reflectee;
    //   print(mirror.type);
    return val;
  }

  /**
   * adds next sub context
   */
  void setSub(String key, Object value, [String infoKey, String info]){
    Map subNode = {};
    subNode[key] = value;
    if(info != null)
      subNode[infoKey] = info;
    subData.add(subNode);
  }

  void removeSub(){
    subData.removeLast();
  }
}
