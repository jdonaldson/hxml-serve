import haxe.web.Dispatch;
import sys.io.Process;
import haxe.io.Bytes;
import haxe.Template;
import neko.io.File;
import neko.Web;
import neko.Sys;
import neko.Lib;
import neko.FileSystem;
using Lambda;
class Index {
    static function main() {
        var r = ~/\.(\w+)$/;
        var uri = Web.getURI();
        var rel_path = "." + uri;
        var ext = r.match(rel_path) ? r.matched(1) : '';

        if (!FileSystem.exists(rel_path)|| FileSystem.isDirectory(rel_path)){
            Web.setHeader("Content-Type",'text/plain');
            Lib.print("File does not exist");
            return;
        } 
        else if (ext != 'hxml'){
            var content_type = Reflect.hasField(ContentType.extension, ext)
                        ? Reflect.field(ContentType.extension, ext)
                        : Reflect.field(ContentType.extension, "*");
            Web.setHeader("Content-Type", content_type);
            var bytes = File.getBytes(rel_path);
            Lib.print(Lib.stringReference(bytes));
        } else {
           Web.setHeader("Content-Type", "text/html");
           var content = File.getContent(rel_path);
           var targets = content.split("--next");
           var target_html = targets.mapi(function(i,hxml){
               var r = ~/^\s*-(cpp|java|js|neko|swf9?)\s*([^\s]+)/;
               var res = '';
               if (r.match(hxml)){
                    var target = r.matched(1);
                    var output_file = r.matched(2);
                    var render = 
                    switch (target ){
                        case 'js': js;
                        case 'swf': swf;
                        case 'neko':neko;
                        default : function(x,y,i) return '';
                    }
                    res = render(hxml,output_file,i);

               }
               return res;
           });
           Lib.print(target_html.join(""));
        }
    }

    public static function swf(hxml:String, output:String,id:Int){
        var tss = new Template('
            <h1>SWF Output</h1>
            <pre>::hxml::</pre>
            <object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000"
            codebase=
            "http://fpdownload.macromedia.com/pub/shockwave/cabs/flash/swflash.cab"
            width="498" height="380" id="test1">
                <param name="movie" value=
                "::output::">
                <embed src="::output::" width="498"
                height="380" name="test1" type="application/x-shockwave-flash"
                pluginspage="http://www.adobe.com/go/getflashplayer">
            </object>
        ');
        return tss.execute({hxml:hxml,output:output, id:id});
    }

    public static function js(hxml:String, output:String, id:Int){
        var tjs = new Template('
                <h1>JS Output</h1>
                <pre>::hxml::</pre>
                <div id="haxe:trace"></div>
                <script>
                    log_override = function(str,pos){
                       console.log(str);
                       var child = document.createTextNode(str);
                       document.getElementById("haxe:trace")
                                .appendChild(child);
                    }
                    console.log = log_override;
                </script>
                <script type="text/javascript" src="::output::"></script>
                <script>
                    document.getElementById("haxe:trace").id = "haxe:trace::id::";
                </script>
                ');
        return tjs.execute({hxml:hxml,output:output, id:id});
    }

    public static function neko(hxml:String, output:String, id:Int){

        var p = new Process('command',['neko ' + output]);
        p.exitCode();
        var result = p.stdout.readAll().toString();
        p.close();
        var tns = new Template('
                <h1>Neko Output</h1>
                <pre>::hxml::</pre>
                <pre>::result::<pre>
                ');
        return tns.execute({hxml:hxml,result:result, id:id});
    }
}

