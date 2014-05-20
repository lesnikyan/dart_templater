
import 'TplContext.dart';

abstract class TNode{
  final bool isBlock;
  TNode(this.isBlock){}
  String render(TplContext context);
}

class StaticNode extends TNode{
  final String content;
  StaticNode(this.content):super(false){}
  String render(TplContext context){
    //print ("[${content}]");
    return content;
  }
}

class CommentNode extends StaticNode {
  CommentNode(String content):super(''){

  }
  String render(TplContext context){
    return '';
  }
}

class VarNode extends TNode{
  String content;
  String keyWord;
  VarNode(this.content):super(false){
    RegExp lexWord = new RegExp(r'^<%\s*=\s*([\w\.]+)');
    Match match = (lexWord).firstMatch(content);
    keyWord = match.group(1);
  //  print("@@ $keyWord");
  }
  String render(TplContext context){
    return context.value(keyWord);
  }
}

abstract class BlockNode extends TNode{
  int depth = 0;
  List<TNode> sub =  [];
  List<String> source = ['',''];
  String content = '';
  String blockType = 'baseBlock';
  bool superNode = false;
  BlockNode(String this.content):super(true){ source[0] = content; }
  void add(TNode node){
    sub.add(node);
  }
  void each(method){
    method(this);
    sub.forEach((subNode){
      if(subNode.isBlock){
        subNode.each(method);
      } else {
        method(subNode, this);
      }
    });
  }

  String renderBlock(TplContext context){
    String res = '';
    for(int i = 0; i < sub.length; ++i){
      TNode node  = sub[i];
      res += node.render(context).toString();
    }
    return res;
  }

  String render(TplContext context);
}


class TreeNode extends BlockNode{
  TreeNode():super(''){}
  String render(TplContext context){
    return renderBlock(context);
  }
}


/**
 * conditions: true/false var, == , != , > , < , >= , <=
 */
class ConditionNode extends BlockNode{
  String lexemeName;
  String firstOperand;
  String secondOperand;
  String operator;
  bool inversion = false;
  Condition condition;

  ConditionNode(String content):super(content){
    blockType = 'condition';
    RegExp lexWord = new RegExp(r'^<%\s*([\w]+)([^%]+)?\s*%>');
    Match match = (lexWord).firstMatch(content);
    String word, optionsPart;
    lexemeName = word = match.group(1).trim();
    if(lexemeName == 'else'){
      return;
    }
    optionsPart = match.group(2).trim();
    //print("getBlock ${word} [${optionsPart}]");

    if(optionsPart.contains('!')){
      if(optionsPart.indexOf('!') == 0){
        inversion = true;
        optionsPart = optionsPart.replaceFirst('!', '').trim();
      } else {
        //
      }
    }
  //  print("optionsPart = (${optionsPart})");
    RegExp splreg = new RegExp(r'\s+');
    List<String> expressionList = optionsPart.toString().split(splreg);
  //  print("expressionList = (${expressionList.toList().toString()})");
    if(expressionList.length == 1){
      // bool value
      condition = new SimpleCondition(expressionList[0]);
    } else if (expressionList.length == 3){
      // operand operator operand
      condition = new ExpressionCondition(expressionList[0], expressionList[2], expressionList[1]);
    } else {
      throw new Exception('ConditionNode: invalid number of arguments = ${expressionList.length} : ${expressionList.toList().toString()}');
    }
  }

  bool checkCondition(TplContext context){
    if(lexemeName == 'else')
      return true;
    return condition.value(context);
  }

  /**
   * i.e. select valid sub block and run it
   */
  String render(TplContext context){
    return renderBlock(context);
  }
}

class ConditionTreeNode extends BlockNode{
  List<ConditionNode> sub = [];
  ConditionTreeNode(String content):super(content){
    superNode = true;
  }
  void add(ConditionNode node){
    sub.add(node);
  }

  String render(TplContext context){
    for(int i = 0; i < sub.length; ++i){
      ConditionNode node = sub[i];
      if(node.checkCondition(context)){
        return node.render(context);
      }
    }
    return '';
  }
}

class EachNode extends BlockNode{
  String keyVar;
  String valueVar;
  String sourceVar;

  EachNode(String content):super(content){
    blockType = 'each';
    RegExp lexWord = new RegExp(r'^<%\s*([\w]+)([^%]+)?\s*%>');
    Match match = (lexWord).firstMatch(content);
    String word, options;
    word = match.group(1).trim();
    options = match.group(2);
  //  print("EachNode ${word} [${options}]");


    Match optMatch = (new RegExp(r'^\s*(?:([\w]+)\s*,\s*)?([\w]+)\s*in\s*([\w\.]+)\s*([\w,\s]+)')).firstMatch(options);
    if(optMatch == null){
      throw new Exception('Tpl: bad block syntax');
    }

    if(optMatch.group(1) == null){ // val in source
      keyVar = 'index';
    } else { // key, val in source

    }
    keyVar = optMatch.group(1) == null ? 'index' : optMatch.group(1);
    valueVar = optMatch.group(2);
    sourceVar = optMatch.group(3);

  //  print("each: ${keyVar}, ${valueVar} in ${sourceVar} ");
  }

  String render(TplContext context){
    // addSub(String key, Object value, [String infoKey, String info])
    String res = '';
    List blocks = context.value(sourceVar);
  //  print(" Each.render [$sourceVar] ${blocks}");
    for(int i = 0; i < blocks.length; ++i){
      Object key = i;
    //  print("Each.render key = ${key}");
      Object blockContext = blocks[key];
      context.setSub(keyVar, key);
      context.setSub(valueVar, blockContext);
      res += renderBlock(context).toString();
    }
    context.removeSub();
    return res;
  }
}

//*******************************************************************


abstract class Condition{
  bool value(TplContext context);
}
class SimpleCondition extends Condition{
  String keyWord;
  SimpleCondition(String this.keyWord){}
  bool value(TplContext context){
    return context.value(keyWord);
  }
}
class ExpressionCondition extends Condition{
  String operand1;
  String operand2;
  String operator;
  List<String> operators = ['==', '!=', '>', '<', '>=', '<='];

  ExpressionCondition(String this.operand1, String this.operand2, String this.operator){
    if(!operators.contains(operator))
      throw new Exception('ExpressionCondition: incorrect operator [${operator}]');
  }

  bool compare(Object x, Object y, String logicOperator){
    switch(logicOperator){
      case '==' : return x == y;
      case '!=' : return x != y;
      case '>' : return x > y;
      case '<' : return x < y;
      case '>=' : return x >= y;
      case '<=' : return x <= y;
    }
  }

  bool value(TplContext context){
    return compare(operandValue(operand1, context), operandValue(operand2, context), operator);
  }

  Object operandValue(String operand, TplContext context){
    Object operandValue;
    RegExp numReg = new RegExp(r'^[\d\.]+$');
    String quote = "\\\'\\\"";
    RegExp strReg = new RegExp('^[$quote]([\\\.\\\s]+)[$quote]'+r'$');
    if(numReg.hasMatch(operand)){
      if(operand.contains('.')){
        return int.parse(operand);
      } else {
        return double.parse(operand);
      }
      return operand;
    } else if (strReg.hasMatch(operand)){
      operand.replaceAll(new RegExp("[$quote]"), '');
      return operand;
    } else {
      return context.value(operand);
    }
  }
}