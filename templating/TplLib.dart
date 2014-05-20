
import 'TplNodes.dart';

abstract class Lexeme{
  String content;
  String type = 'none';
  Lexeme(this.content, [this.type]){}
  String toString() => content;
}

class StaticLexeme extends Lexeme{
  StaticLexeme(content):super(content, 'tstatic'){}
}

class CommentLexeme extends Lexeme{
  CommentLexeme(content):super(content, 'comment'){}
}

class VarLexeme extends Lexeme{
  VarLexeme(content):super(content, 'variable'){}
}

class StartBlockLexeme extends Lexeme{
  StartBlockLexeme(content):super(content, 'start_block'){}
}

class EndBlockLexeme extends Lexeme{
  EndBlockLexeme(content):super(content, 'end_block'){}
}

class EndStartBlockLexeme extends Lexeme{
  EndStartBlockLexeme(content):super(content, 'end_start_block'){}
}

class UnknownLexeme extends Lexeme{
  UnknownLexeme(content):super(content, 'unknown'){}
}

// **************************** Build and display methods ************************************



void printNodes(BlockNode node, [BlockNode parent]){
  int parentDepth = (parent != null) ? parent.depth : 0;
  String makePrefix(String str, int count){ String x = ''; for(int i=0;i<count;++i){ x += str; };return x;}
  String prefix;
  if(node.isBlock){
    prefix = makePrefix('-', node.depth);
  //  print("$prefix ${node.content}");
  } else {
    prefix = makePrefix('-', parentDepth + 1);
    RegExp endLine = new RegExp(r'\n');
    //print("@= ${node.content.trim().contains(endLine)} ${node.content.trim().indexOf(endLine)}");
    int sublen = (node.content.trim().contains(endLine)) ? node.content.trim().indexOf(endLine) : node.content.trim().length;
  //  print ('$prefix *** ${node.content.trim().substring(0,sublen)}');
  }
}

// ****************************************************************

