package {
  import flash.display.Shape;
  import flash.display.Sprite;
  import flash.events.MouseEvent;
  import flash.external.ExternalInterface;
  import flash.geom.ColorTransform;
  import flash.text.TextField;
  import flash.text.TextFormat;

  public class KeyboardBtn extends Sprite {
    public static const CLICK_SOUND:String = "Play_ui_button_select";
    private static const TEXT_FORMAT_DEFAULT:TextFormat = new TextFormat("Open Sans",9,16250871,false,false,false,false,false,"center");
    public var format:TextFormat;
    private var _text:TextField;
    private var bg:Shape;
    private var listeners:Array = [];
    private var _msg:String;
    private var _count:int = 0;
    private var border:Boolean = false;

    private var width:int;
    private var height:int;

    public function KeyboardBtn(w:int = 64, h:int = 12, txt:String = "", x:int = 0, y:int = 0, flag:Boolean = false) {
      super();
      this.border = !flag;

      this.width = w;
      this.height = h;

      this._msg = txt;
      this.format = TEXT_FORMAT_DEFAULT;

      renderer.rectangle(this, 0, 0, w, h, 0, 0);
      this.bg = new Shape();
      if (this.border) this.bg = renderer.rectangle(this.bg, -1, -1, w, h, renderer.GRAY_12, 1);
      this.bg = renderer.rectangle(this.bg, 0, 0, w - (this.border ? 2 : 0), h - (this.border ? 2 : 0), renderer.GRAY_28, 1);

      this._text = renderer.text(-(this.border ? 1 : 0), 0, this.format, "", true, txt);
      this._text.height = 14;
      this._text.width = w;
      this._text.y = ((h - this._text.height - (this.border ? 2 : 0)) / 2) - 1;

      this.addChild(this.bg);
      this.addChild(this._text);

      this.addMouseEventListeners();

      this.x = x;
      this.y = y;
    }

    public function get count() : int {
      return this._count;
    }

    public function set count(num:int) : void {
      this._text.text = this._msg + " (" + num + ")";
      this._count = num;
    }

    private function addMouseEventListeners() : void {
      this.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
      this.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
      this.addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
      this.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
      this.addEventListener(MouseEvent.CLICK,this.onClick);
    }

    private function onMouseOver() : void {
      this.bg.graphics.clear();
      if (this.border) renderer.rectangle(this.bg, -1, -1, this.width, this.height, renderer.WHITE, 1);
      renderer.rectangle(this.bg, 0, 0, this.width - (this.border ? 2 : 0), this.height - (this.border ? 2 : 0), renderer.GRAY_28, 1);
    }

    private function onMouseOut() : void {
      this.bg.graphics.clear();
      if (this.border) renderer.rectangle(this.bg, -1, -1, this.width, this.height, renderer.GRAY_12, 1);
      renderer.rectangle(this.bg, 0, 0, this.width - (this.border ? 2 : 0), this.height - (this.border ? 2 : 0), renderer.GRAY_28, 1);
    }

    private function onMouseDown() : void {
      ExternalInterface.call("POST_SOUND_EVENT",CLICK_SOUND);
      this.bg.graphics.clear();
      if (this.border) renderer.rectangle(this.bg, -1, -1, this.width, this.height, renderer.WHITE, 1);
      renderer.rectangle(this.bg, 0, 0, this.width - (this.border ? 2 : 0), this.height - (this.border ? 2 : 0), renderer.GRAY_22, 1);
    }

    private function onMouseUp() : void {
      this.bg.graphics.clear();
      if (this.border) renderer.rectangle(this.bg, -1, -1, this.width, this.height, renderer.WHITE, 1);
      renderer.rectangle(this.bg, 0, 0, this.width - (this.border ? 2 : 0), this.height - (this.border ? 2 : 0), renderer.GRAY_28, 1);
    }

    private function onClick() : void {
      var idx:int = 0;
      var len:int = int(this.listeners.length);
      while(idx < len) {
        this.listeners[idx].call();
        idx++;
      }
    }

    public function get text() : String {
      return this._text.text;
    }
  }
}
