import haxe.web.Dispatch;
import neko.io.File;
import neko.Web;
import neko.Sys;
import neko.Lib;
import neko.FileSystem;
using Lambda;
class Index {
    static function main() {
        Dispatch.run(Web.getURI(), Web.getParams(), new Api());
    }
}

class Api{
    public function new(){}
    public function doDefault(?file:String){
        var html = "<html><body>";
        var path = '.' + Web.getURI();
        var dirs = FileSystem.readDirectory(Sys.getCwd());
        var path = Sys.getCwd() + file;
        if (FileSystem.exists(path)){
            var file_str = File.getContent(path);
            var targets = file_str.split("--next");
            var r = ~/-(js|swf)\s*([\w\.\\\/]+)/;

            for (t in targets){
                if (r.match(t)){
                    var target = r.matched(1);
                    var file = r.matched(2);
                    if (target == 'js'){
                        var stub = '<link rel="javascript" type="text/javascript" href="'+file+'" />';
                        html += stub;
                    }
                }
            }

        }
        html += "</body></html>";
        Lib.print(html);
    }
}
