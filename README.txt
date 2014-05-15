
Author: SergioLesnik@gmail.com

What is it?
Simple templating engine for Dart server.
Was made for learning Dart as server-side platform.
It's not a real serious templater, just result of some fun.
But it works :)

Files:
server.dart - tiny web server.
tpl.dart - testing (or usage example) template.
/templating/ - template engine files.

Used syntax:
<%%> - template includes of logic or values

<%= user.name%> - print value: simple value or field of object.

<% if someBoolValue %> - logic condition block
<% elseif someBoolValue %> - alter logic condition block

<% for key, val in users %> - cycle block

<% for key in actions %> - simplest cycle block

<%end%> - end of block

Values have Dart-like syntax.

Logic conditions 'if'.
Simple bool value or condition (expression).
Available logic conditions: ==, !=, <, >, <=, >=
Logic operands: bound variable, strings (in ' or "), numbers.

Alter condition <%else%>.

Alter <% elseif boolExpression %> - same syntax as 'if'

Cycle 'for'.
Can use Lists.
Variant <% for key, val in listVar %>
	- key - array list index,
	- val - value (any type)
	- listVar - bound List variable.

Variant <% for val in listVar %>
	- val - value of list position.


What next:
	Add comments. Really forget about them :)
	Implement real 'range' method for creating cycle by number of iteration.
	Add cycle for Maps. Not sure that it necessary.
	Users methods. Not sure too.

*****************************************************
testing example of template:
*****************************************************

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
        <div class="r1"><%= val.name%></div>
        <div class="r1"><%= val.position%></div>
        <%if val.age > 18%>
        <div class="r1"><%= val.age%> years old, status: <%= val.status%></div>
        <%else%>
        <div class="r1">Young man, <%= val.status%></div>
        <%end%>
      <%end%>
      <% for i in numbers %>
        <div>index = <%= i%> </div>
      <%end%>
      </div>
      Follower: <%= c_user.coworker.friend.name %>
    </body>
  </html>

*****************************************************

As you see, it have many trash in code. So I think, it is just symptom of unfinished work.