import haxe.web.Dispatch;
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
    public function doHxml(?file:String){
        var hxmls = new List<String>();
        if (file == '' || file == null){
            var dirs = FileSystem.readDirectory(Sys.getCwd());
            hxmls = dirs.filter(function(x) return ~/\.hxml$/.match(x));
        }
        Lib.print(hxmls.join(", "));
    }
    public function doDefault(){
        trace('default');
    }
}
