package kabam.rotmg.game.view.components {
import com.company.assembleegameclient.objects.ImageFactory;
import com.company.assembleegameclient.ui.icons.IconButton;
import com.company.assembleegameclient.ui.icons.IconButtonFactory;
import com.company.ui.BaseSimpleText;
import com.company.util.GraphicsUtil;

import flash.display.Bitmap;
import flash.display.GraphicsPath;
import flash.display.GraphicsSolidFill;
import flash.display.IGraphicsData;
import flash.display.Sprite;
import flash.events.MouseEvent;

import kabam.rotmg.text.model.TextKey;

import org.osflash.signals.Signal;

public class TabStripView extends Sprite {

    public const tabSelected:Signal = new Signal(String);
    public const WIDTH:Number = 186;
    public const HEIGHT:Number = 153;
    private const tabSprite:Sprite = new Sprite();
    private const background:Sprite = new Sprite();
    private const containerSprite:Sprite = new Sprite();

    public var iconButtonFactory:IconButtonFactory;
    public var imageFactory:ImageFactory;
    private var _width:Number;
    private var _height:Number;
    public var tabs:Vector.<TabView>;
    private var contents:Vector.<Sprite>;
    public var currentTabIndex:int;
    public var friendsBtn:IconButton;

    public function TabStripView(_arg_1:Number = 186, _arg_2:Number = 153) {
        this.tabs = new Vector.<TabView>();
        this.contents = new Vector.<Sprite>();
        super();
        this._width = _arg_1;
        this._height = _arg_2;
        this.tabSprite.addEventListener(MouseEvent.CLICK, this.onTabClicked);
        addChild(this.tabSprite);
        this.drawBackground();
        addChild(this.containerSprite);
        this.containerSprite.y = TabConstants.TAB_TOP_OFFSET;
    }

    public function initFriendList(_arg_1:ImageFactory, _arg_2:IconButtonFactory, _arg_3:Function):void {
        this.friendsBtn = _arg_2.create(_arg_1.getImageFromSet("lofiInterfaceBig", 13), "", TextKey.OPTIONS_FRIEND, "");
        this.friendsBtn.x = 160;
        this.friendsBtn.y = 6;
        this.friendsBtn.addEventListener(MouseEvent.CLICK, _arg_3);
        addChild(this.friendsBtn);
    }

    private function onTabClicked(_arg_1:MouseEvent):void {
        this.selectTab((_arg_1.target.parent as TabView));
    }

    public function setSelectedTab(_arg_1:uint):void {
        this.selectTab(this.tabs[_arg_1]);
    }

    private function selectTab(_arg_1:TabView):void {
        var _local_2:TabView;
        if (_arg_1) {
            _local_2 = this.tabs[this.currentTabIndex];
            if (_local_2.index != _arg_1.index) {
                _local_2.setSelected(false);
                _arg_1.setSelected(true);
                this.showContent(_arg_1.index);
                this.tabSelected.dispatch(this.contents[_arg_1.index].name);
            }
        }
    }

    public function drawBackground():void {
        var _local_1:GraphicsSolidFill = new GraphicsSolidFill(TabConstants.BACKGROUND_COLOR, 1);
        var _local_2:GraphicsPath = new GraphicsPath(new Vector.<int>(), new Vector.<Number>());
        var _local_3:Vector.<IGraphicsData> = new <IGraphicsData>[_local_1, _local_2, GraphicsUtil.END_FILL];
        GraphicsUtil.drawCutEdgeRect(0, 0, this._width, (this._height - TabConstants.TAB_TOP_OFFSET), 6, [1, 1, 1, 1], _local_2);
        this.background.graphics.drawGraphicsData(_local_3);
        this.background.y = TabConstants.TAB_TOP_OFFSET;
        addChild(this.background);
    }

    public function clearTabs():void {
        var _local_1:uint;
        this.currentTabIndex = 0;
        var _local_2:uint = this.tabs.length;
        _local_1 = 0;
        while (_local_1 < _local_2) {
            this.tabSprite.removeChild(this.tabs[_local_1]);
            this.containerSprite.removeChild(this.contents[_local_1]);
            _local_1++;
        }
        this.tabs = new Vector.<TabView>();
        this.contents = new Vector.<Sprite>();
    }

    public function addTab(_arg_1:*, _arg_2:Sprite):void {
        var _local_4:TabView;
        var _local_3:int = this.tabs.length;
        if ((_arg_1 is Bitmap)) {
            _local_4 = this.addIconTab(_local_3, (_arg_1 as Bitmap));
        }
        else {
            if ((_arg_1 is BaseSimpleText)) {
                _local_4 = this.addTextTab(_local_3, (_arg_1 as BaseSimpleText));
            }
        }
        this.tabs.push(_local_4);
        this.tabSprite.addChild(_local_4);
        this.contents.push(_arg_2);
        this.containerSprite.addChild(_arg_2);
        if (_local_3 > 0) {
            _arg_2.visible = false;
        }
        else {
            _local_4.setSelected(true);
            this.showContent(0);
            this.tabSelected.dispatch(_arg_2.name);
        }
    }

    public function removeTab():void {
    }

    private function addIconTab(_arg_1:int, _arg_2:Bitmap):TabIconView {
        var _local_4:TabIconView;
        var _local_3:Sprite = new TabBackground();
        _local_4 = new TabIconView(_arg_1, _local_3, _arg_2);
        _local_4.x = (_arg_1 * (_local_3.width + TabConstants.PADDING));
        _local_4.y = TabConstants.TAB_Y_POS;
        return (_local_4);
    }

    private function addTextTab(_arg_1:int, _arg_2:BaseSimpleText):TabTextView {
        var _local_3:Sprite = new TabBackground();
        var _local_4:TabTextView = new TabTextView(_arg_1, _local_3, _arg_2);
        _local_4.x = (_arg_1 * (_local_3.width + TabConstants.PADDING));
        _local_4.y = TabConstants.TAB_Y_POS;
        return (_local_4);
    }

    private function showContent(_arg_1:int):void {
        var _local_2:Sprite;
        var _local_3:Sprite;
        if (_arg_1 != this.currentTabIndex) {
            _local_2 = this.contents[this.currentTabIndex];
            _local_3 = this.contents[_arg_1];
            _local_2.visible = false;
            _local_3.visible = true;
            this.currentTabIndex = _arg_1;
        }
    }


}
}//package kabam.rotmg.game.view.components
