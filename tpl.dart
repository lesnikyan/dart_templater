import 'templating/TemplateCore.dart';

void main(){
  String tplSource = '''<%test%>
  <%! singleline comment  %>
  <%! singleline comment 2 %>
  <!-- Between tpl comments block -->
  <%!
   this part
   is multiline comment
   %>
  <html>
    <head></head>
    <body>
      <div class="c1"></div>
      <% if authorized %>
      <h1>Welcome to system <%=user.name%></h1>
      <%end%>
      <div class="c1">
      11 <%= x%><%= y%> 22
      <% for key, val in users %>
        <%! Some comment
        with multi strings %>
        <div class="r1"><%= val.name%></div>
        <div class="r1"><%= val.position%></div>
        <%if val.age > 20%>
          <div class="r1">--33 <%= val.age%> years old, status: <%= val.status%></div>
        <%elseif val.age > 18 %>
          <div> just status --22 <%= val.status%> </div>
        <%else%>
          <div class="r1">--11 Young man, <%= val.status%></div>
        <%end%>
      <%end%>
      <div>Before comment block</div>
      <%! Single string comment %>
      <div>After comment block</div>
      <% for i in range 0, 10 %>
        <div>index = <%= i%> </div>
      <%end%>
      </div>
      Follower: <%= c_user.coworker.friend.name %>
    </body>
  </html>
  ''';
  // name status position age
  List<OptionalUser> users = [];
  for(int i = 1; i<=10; ++i){
    users.add(new OptionalUser("Name_$i", "status_$i", "position_$i", 15+i));
  }
  Map<String,Object> contextData = {
      'user': new TestUser(),
      'c_user': new CUser(),
      'users': users,
      'authorized' : true,
      'x':'First argument X',
      'y':'Second argument Y'
  };
  Template tpl = new Template.from(tplSource, contextData);
  tpl.setContext({'range' : [0,2,3,4,5, 'asd']});
  print(tpl.render());
  //tpl.tree.each(printNodes);
}

// *************************** TEST CLASSES **********************************

class TestUser extends Object{
  String name = 'Vasya Pupkin';
  String status = 'nobles';
  String position = 'manager';
  int age = 25;
  TestUser(){}
}

class OptionalUser extends Object{
  String name = '';
  String status = '';
  String position = '';
  int age = 0;
  OptionalUser(String this.name, String this.status, String this.position, int this.age){}
}
// name status position age

class AUser{
  String name = 'Kolya Bobrov';
}

class BUser{
  AUser friend = new AUser();
}

class CUser{
  BUser coworker = new BUser();
}

// c_user.coworker.friend.name