import 'dart:io';

// Browser C:\Users\Less\Downloads\install\darteditor-windows-x64-last\dart\chromium\chrome.exe
main() {
  HttpServer.bind('127.0.0.1', 3031).then((server) {
    server.listen((HttpRequest request) {
      void out(Object x){
        request.response.write(x);
        request.response.write("\n");
      }
      void error(Object x){
        request.response.write(x.toString());
        request.response.close();
      }
//Out out = new Out(request.response);
      HttpHeaders h =  request.response.headers;

      if(true){

// C:\Users\Less\Documents\Projects\dart\baseweb\server
// http://127.0.0.1:3031/web/baseanimation.html

        RegExp reg = new RegExp(r'^[^?]+\.(html|js|dart|css|png|jpg|gif|json)$');
        Iterable matches = reg.allMatches(request.uri.path);
//out(matches.length);
        String basePath = 'C://Users/Less/IdeaProjects/testDart';
        String path;
        String type;
        if(true){
        if(matches != null && matches.length > 0){
          path = basePath + "/web/" + request.uri.path;
          type = matches.elementAt(0).group(1);
        } else {
          path = basePath + "/web/main.html";
          type = "html";
        }

//print(path);




          Map<String,List> types = {
              "html":	["text","html"],
              "js":		["text","javascript"],
              "json":		["application","json"],
              "css":	["text","css"],
              "dart":	["application","dart"],
              "gif":	["image","gif"],
              "jpg":	["image","jpeg"],
              "png":	["image","png"]
          };
//out(types[type]);

          File file = new File(path);
          if(types[type] == null){
            return error("Incorrect file type!");
          }
          if(file.existsSync()){
//h.contentType = new ContentType( types[type][0], types[type][1]);
//out("${HttpHeaders.CONTENT_TYPE}:${types[type][0]}/${types[type][1]}");
//request.response.headers.add(HttpHeaders.CONTENT_TYPE, "${types[type][0]}/${types[type][1]}");
//File image = new File(path);
            file.readAsBytes().then(
                    (raw){
                  request.response.headers.set('Content-Type', "${types[type][0]}/${types[type][1]}");
                  request.response.headers.set('Content-Length', raw.length);
                  request.response.add(raw);
                  request.response.close();
                });
          } else {
            return error("err 404\n<br>File '$path' not found!");
          }
        }
      }
// request.response.close();
    });
  });
}
