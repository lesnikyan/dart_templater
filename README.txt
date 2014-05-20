
Author: SergioLesnik@gmail.com

1. What is it?
Simple templating engine for Dart server.
Was made for learning Dart as server-side platform.
It's not a real serious templater, just result of some fun.
But it works :)

2. Files:
server.dart - tiny web server.
tpl.dart - testing (or usage example) template.
/templating/ - template engine files.

3. Used syntax:
<%%> - template includes of logic or values

<%! comment text %> - text of comment, single or multi line

<%= user.name%> - print value: simple value or field of object.

<% if someBoolValue %> - logic condition block
<% elseif someBoolValue %> - alter logic condition block

<% for key, val in users %> - cycle block

<% for key in actions %> - simplest cycle block

<%end%> - end of block

Values have Dart-like syntax.

4. Syntax specification of elements.

- Logic conditions 'if'.
Simple bool value or condition (expression).
Available logic conditions: ==, !=, <, >, <=, >=
Logic operands: bound variable, strings (in ' or "), numbers.

- Alter condition <%else%>.

- Alter <% elseif boolExpression %> - same syntax as 'if'

- Cycle 'for'. Can use Lists.
-- Variant <% for key, val in listVar %>
	- key - array list index,
	- val - value (any type)
	- listVar - bound List variable.

-- Variant <% for val in listVar %>
	- val - value of list position.


5. What next:
	Add comments. Really forget about them :)
	Implement real 'range' method for creating cycle by number of iteration.
	Add cycle for Maps. Not sure that it necessary.
	Users methods. Not sure too.

*****************************************************
testing example of template:
*****************************************************

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

*****************************************************

As you see, it have many trash comments in code.
So I think (I hope), it is just symptom of unfinished work.
