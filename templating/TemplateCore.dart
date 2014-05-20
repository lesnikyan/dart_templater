
//import 'dart:mirrors';
import 'TplContext.dart';
import 'TplNodes.dart';
import 'TplLib.dart';



class Template {
  List<String> startBlockKeywords = ['each', 'for', 'if'];
  List<String> endBlockKeywords = ['end', 'endeach', 'endfor', 'endif'];
  List endStartKeyWords = ['else', 'elseif'];
  List<String> blockKeyWords = [];

  TreeNode tree = null;
  TplContext tplContext = null;

  Template(){
    init();
  }

  Template.from(String tpl, [Map contextData]){
    init();
    setTemplate(tpl);
    tplContext = new TplContext(contextData);
  }

  void init(){
    blockKeyWords.addAll(startBlockKeywords);
    blockKeyWords.addAll(endBlockKeywords);
    blockKeyWords.addAll(endStartKeyWords);
  }

  void setContext(Map data){
    if(tplContext == null)
      tplContext = new TplContext();
    tplContext.add(data);
  }

  void setTemplate(String tpl){

    RegExp reg = new RegExp(r'<%[^%]+%>');

    List split = tpl.split(reg); // static strings
    Iterable matches = reg.allMatches(tpl);
    List cases = matches.toList(); // template lexemes

    String  prepareStatic(String src, String keyWord){
    //  print("[$src]");
    //  print('[$keyWord]');
      if(blockKeyWords.contains(keyWord)){
        int index = src.lastIndexOf(new RegExp('\n'));
        return src.substring(0, index);
      }
      return src;
    }

    RegExp lexWord = new RegExp(r'^<%\s*([^\s%=]+|=)');
    List<Lexeme>lexemes = [];
    int len = cases.length;
    for (int index=0; index < len; ++index){
      // number of split = cases - 1
      Lexeme lex;
      String curcase = cases[index].group(0);
      curcase.trim(); // removes last '\n' of lexeme
      Match match = (lexWord).firstMatch(curcase);
      String word;
      if(match == null){
        word = '';
      } else {
        word = match.group(1);
      }

      if(blockKeyWords.contains(word)){
        // add previous static lexeme
        lexemes.add(new StaticLexeme(prepareStatic(split[index], word)));

        if(endBlockKeywords.contains(word)){
          lex = new EndBlockLexeme(curcase);
        }else if(startBlockKeywords.contains(word)){
          lex = new StartBlockLexeme(curcase);
        } else if(endStartKeyWords.contains(word)){

          lex = new EndStartBlockLexeme(curcase);
        }
      } else {
        //lexemes.add(new StaticLexeme(split[index]));
        String prevStatWord = split[index];
        if (word == '='){
          lex = new VarLexeme(curcase);
        } else if (word == '!'){
          lex = new CommentLexeme(curcase);
          //print("1#$prevStatWord#");
          prevStatWord = prevStatWord.replaceFirst(new RegExp(r'\n\s*$'), '');
          //print("2#$prevStatWord#");
        } else {
          lex = new UnknownLexeme('??? '+curcase);
        }
        lexemes.add(new StaticLexeme(prevStatWord));
      }
      lexemes.add(lex);
    }
    lexemes.add(new StaticLexeme(split.last));

    tree = new TreeNode();
    BlockNode curNode = tree;
    List<BlockNode> branch = [tree];

  //  print("lexemes.length = ${lexemes.length}");
    for(int i=0; i < lexemes.length; ++i){
      Lexeme lex = lexemes[i];
    //  print("## ${lexemes[i]}");
      switch(lex.type){
        case 'tstatic':
          curNode.add(new StaticNode(lex.content));
          break;
        case 'comment':
          curNode.add(new CommentNode(lex.content));
          break;
        case 'variable':
          curNode.add(new VarNode(lex.content));
          break;
        case 'start_block':
        // use special method for concrete type of block
          BlockNode node = getBlock(lex);
          curNode.add(node);
          curNode = node;
          branch.add(node);
          node.depth = branch.length;
          node.source[0] = lex.content;
          if(node.superNode){
            // switch current to first sub node of superNode
            // superNode from 'getNode' has 1 child
            branch.add(node.sub[0]);
            node.sub[0].depth = branch.length;
            curNode = node.sub[0];
          //  print("superNode in action ${lex.content} curNode = ${curNode.blockType}");
          }
          break;
        case 'end_block':
          curNode.source[1] = lex.content;
        //  print("^"+curNode.content.trim() + " ends");
          branch.removeLast();
          curNode = branch.last;
          // if current - ConditionNode, close current node and parent ConditionTreeNode
          // close superNode
          if(curNode.superNode){
            //if(mirror.type == 'ConditionTreeNode'){
          //  print("close super node");
            curNode.source[1] = lex.content;
            branch.removeLast();
            curNode = branch.last;
          }
          break;
        case 'end_start_block':
          curNode.source[1] = lex.content;
        //  print("^^"+curNode.content);
          branch.removeLast();
          curNode = branch.last;
          BlockNode node = getBlock(lex);
          curNode.add(node);
          curNode = node;
          branch.add(node);
          node.depth = branch.length;
          node.source[0] = lex.content;
        //  print("^-^"+curNode.content);
          break;
        case 'undefined':
          break;
        default: break;
      }
    }
  }

  BlockNode getBlock(Lexeme lex){
    RegExp lexWord = new RegExp(r'^<%\s*([\w]+)([^%]+)?\s*%>');
    Match match = (lexWord).firstMatch(lex.content);
    String word, options;
    if(match == null){
      return null;
    }

    word = match.group(1).trim();
    options = match.group(2);

    switch(word){
      case 'if':
        BlockNode tree = new ConditionTreeNode("[${lex.content.trim()}]");
        tree.add(new ConditionNode(lex.content.trim()));
        return tree;
        break;
      case 'else':
        return new ConditionNode(lex.content.trim());
        break;
      case 'elseif':
        return new ConditionNode(lex.content.trim());
        break;
      case 'for':
        return new EachNode(lex.content.trim());
        break;
    }
    return new ExNode(lex.content);
  }

  String render(){
    return tree.render(tplContext);
  }
}



