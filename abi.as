package {
  import flash.external.ExternalInterface;

  public class abi {
    public static const MOD_NAME:String = "ayu-friends";
    public static const FILE_NAME:String = "friendslist.swf";
    public static const DEBUG:int = 0;

    public static var M:*;

    public static const CType:Object = {
      "BOOL": 0,
      "UINT": 1,
      "INT": 2,
      "FLOAT": 3,
      "STRING": 4,
      "LIST": 5,
      "MAP": 6
    };

    public static var cfg:Object = {
      "max_rows":16,
      "drop_nameless":true,
      "default_tab":0,
      "vertical_offset":0
    };

    private static const convar_types:Object = {
      "default_tab":[CType.UINT,0,3],
      "drop_namepless":[CType.BOOL],
      "vertical_offset":[CType.INT,-1000,1000],
      "max_rows":[CType.UINT,1,25]
    };

    public static var msg:Object = {
      "MASTERY_RANK_FORMAT":IggyFunctions.translate("$MasteryRankFormat").substring(0,IggyFunctions.translate("$MasteryRankFormat").indexOf("{0}")),
      "REQUEST_OUTGOING":IggyFunctions.translate("$FriendRequest_WaitOnOther"),
      "REQUEST_INCOMING":IggyFunctions.translate("$FriendRequest_WaitOnAccept"),
      "FRIEND":IggyFunctions.translate("$geodian_circle_name"),
      "FRIENDS":IggyFunctions.translate("$FriendsList_FriendTab"),
      "ONLINE":IggyFunctions.translate("$Online"),
      "ADD":IggyFunctions.translate("$FriendsList_Add"),
      "JOIN":IggyFunctions.translate("$FriendRequest_Join").toUpperCase(),
      "INVITE":IggyFunctions.translate("$FriendRequest_JoinMe").toUpperCase(),
      "ACCEPT":IggyFunctions.translate("$FriendRequest_Accept")
    };

    public static var favs:Object = {};
    public static var alts:Object = {};
    public static var quick:Object = {};
    public static var cleaners:Object = {};
    public static var leechers:Object = {};

    public function abi() {
      super();
    }

    public static function onLoadModConfig(key:String, val:String) : void {
      if(key.indexOf(MOD_NAME + ":") == 0) configRead(key.substring(MOD_NAME.length + 1).replace("-","_"),val);
    }

    private static function configRead(key:String, val:String) : void {
      var arr:Array = null;
      if(cfg[key] != null) {
        switch(convar_types[key][0]) {
        case CType.BOOL:
          cfg[key] = val.toLowerCase() == "true" || Number(val) == 1;
          break;
        case CType.UINT:
          cfg[key] = uint(clamp(Number(val),convar_types[key][1],convar_types[key][2]));
          break;
        case CType.INT:
          cfg[key] = int(clamp(Number(val),convar_types[key][1],convar_types[key][2]));
          break;
        case CType.FLOAT:
          cfg[key] = clamp(Number(val),convar_types[key][1],convar_types[key][2]);
          break;
        case CType.STRING:
          cfg[key] = val;
          break;
        case CType.LIST:
          cfg[key] = processConfigList(val);
          break;
        default:
          cfg[key] = val;
        }
      } else if(key == "favorites") {
        arr = processConfigList(val);
        if(arr) favs = arrayToObject(arr);
      } else if(key == "alts") {
        arr = processConfigList(val);
        if(arr) alts = arrayToObject(arr);
      } else if(key == "quick_list") {
        arr = processConfigList(val);
        if(arr) quick = arrayToObject(arr);
      } else if(key == "list_cleaners") {
        arr = processConfigList(val);
        if(arr) cleaners = arrayToObject(arr);
      } else if(key == "list_leechers") {
        arr = processConfigList(val);
        if(arr) leechers = arrayToObject(arr);
      }
    }

    public static function configWrite(key:String) : void {
      var out:String = "";
      var val:* = cfg[key];
      if(cfg[key] != null) {
        switch(convar_types[key][0]) {
        case CType.BOOL:
          out = !!val ? "true" : "false";
          break;
        case CType.UINT:
          out = Number(val).toString();
          break;
        case CType.INT:
          out = Number(val).toString();
          break;
        case CType.FLOAT:
          out = String(val.toString());
          break;
        case CType.STRING:
          out = val;
          break;
        case CType.LIST:
          out = "[" + val.join(",") + "]";
          break;
        default:
          out = String(val.toString());
        }
      } else if(key == "favorites") out = "[" + objectToArray(favs).join(",") + "]";
      else if(key == "alts") out = "[" + objectToArray(alts).join(",") + "]";
      else if(key == "quick_list") out = "[" + objectToArray(quick).join(",") + "]";
      else if(key == "list_cleaners") out = "[" + objectToArray(cleaners).join(",") + "]";
      else if(key == "list_leechers") out = "[" + objectToArray(leechers).join(",") + "]";

      if(out != "") ExternalInterface.call("UIComponent.OnSaveConfig",FILE_NAME,MOD_NAME + ":" + key.replace("_","-"),out);
    }

    private static function processConfigList(val:String) : Array {
      val = val.split(" ").join("");
      if(val.charAt(0) == "[" && val.charAt(val.length - 1) == "]" && val != "[]") return val.slice(1,-1).split(",");
      return new Array();
    }

    private static function arrayToObject(arr:Array) : Object {
      var obj:Object = {};
      var idx:int = int(arr.length);
      while(idx--) obj[Number(uint(Number(arr.pop())) ^ 77777777 ^ 48813).toString()] = true;
      return obj;
    }

    private static function objectToArray(obj:Object) : Array {
      var key:* = null;
      var arr:Array = [];
      for(key in obj) {
        if(obj[key]) arr.push(Number(uint(Number(key)) ^ 48813 ^ 77777777).toString());
      }
      return arr;
    }

    public static function easeOutCirc(x:Number) : Number {
      return Math.max(0,Math.min(1,Math.sqrt(1 - Math.pow(x - 1,2))));
    }

    public static function getScrubberSize(num_friends:int, min_size:int) : int {
      var max_size:int = abi.cfg.max_rows * 40;
      if(num_friends <= abi.cfg.max_rows) return max_size;
      return int(Math.max(min_size,Math.min(max_size,max_size - easeOutCirc(num_friends / 700) * max_size)));
    }

    public static function scale(s:*, scale:Number = 1) : * {
      s.scaleX = scale;
      s.scaleY = scale;
      return s;
    }

    public static function clamp(p:Number, min:Number, max:Number) : Number {
      return Math.max(min,Math.min(max,p));
    }

    public static function within(min:Number, p:Number, max:Number) : Boolean {
      return min <= p && p <= max;
    }
  }
}
