import haxe.web.Dispatch;
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

        if (!FileSystem.exists(rel_path)){
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
           var target_html = targets.map(function(text){
               var r = ~/^\s*-(cpp|java|js|neko|swf9?)\s*([^\s]+)/;
               var res = '';
               if (r.match(text)){
                    var target = r.matched(1);
                    var output = r.matched(2);
                    var render = 
                    switch (target ){
                        case 'js': js;
                        case 'swf': swf;
                        default : function(x,y) return '';
                    }
                    res = render(text,output);

               }
               return res;
           });
           Lib.print(target_html.join(""));
        }
    }

    public static function swf(text:String, output:String){
        var tss = new Template('
            <h1>SWF Output</h1>
            <pre>::text::</pre>
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
        return tss.execute({text:text,output:output});
    }

    public static function js(text:String, output:String){
        var tjs = new Template('
                <h1>JS Output</h1>
                <pre>::text::</pre>
                <link rel="javascript" type="text/javascript" href="::output::">
                ');
        return tjs.execute({text:text,output:output});
    }

    public static function neko(target:String, output:String){
        var tns = new Template('
                <h1>Neko Output</h1>
                <pre>::target::</pre>
                <link rel="javascript" type="text/javascript" href="::output::">
                ');
        return tns.execute({target:target,output:output});
    }
}

