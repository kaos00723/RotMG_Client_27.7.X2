package com.company.assembleegameclient.ui.dropdown {
import com.company.ui.BaseSimpleText;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;

public class DropDown extends Sprite {

    protected var strings_:Vector.<String>;
    protected var w_:int;
    protected var h_:int;
    protected var labelText_:BaseSimpleText;
    protected var xOffset_:int = 0;
    protected var selected_:DropDownItem;
    protected var all_:Sprite;

    public function DropDown(_arg_1:Vector.<String>, _arg_2:int, _arg_3:int, _arg_4:String = null) {
        this.all_ = new Sprite();
        super();
        this.strings_ = _arg_1;
        this.w_ = _arg_2;
        this.h_ = _arg_3;
        if (_arg_4 != null) {
            this.labelText_ = new BaseSimpleText(16, 0xFFFFFF, false, 0, 0);
            this.labelText_.setBold(true);
            this.labelText_.text = (_arg_4 + ":");
            this.labelText_.updateMetrics();
            addChild(this.labelText_);
            this.xOffset_ = (this.labelText_.width + 5);
        }
        this.setIndex(0);
    }

    public function getValue():String {
        return (this.selected_.getValue());
    }

    public function setValue(_arg_1:String):void {
        var _local_2:int;
        while (_local_2 < this.strings_.length) {
            if (_arg_1 == this.strings_[_local_2]) {
                this.setIndex(_local_2);
                return;
            }
            _local_2++;
        }
    }

    public function setIndex(_arg_1:int):void {
        this.setSelected(this.strings_[_arg_1]);
    }

    public function getIndex():int {
        var _local_1:int;
        while (_local_1 < this.strings_.length) {
            if (this.selected_.getValue() == this.strings_[_local_1]) {
                return (_local_1);
            }
            _local_1++;
        }
        return (-1);
    }

    private function setSelected(_arg_1:String):void {
        var _local_2:String;
        _local_2 = (((this.selected_) != null) ? this.selected_.getValue() : null);
        this.selected_ = new DropDownItem(_arg_1, this.w_, this.h_);
        this.selected_.x = this.xOffset_;
        this.selected_.y = 0;
        addChild(this.selected_);
        this.selected_.addEventListener(MouseEvent.CLICK, this.onClick);
        if (_arg_1 != _local_2) {
            dispatchEvent(new Event(Event.CHANGE));
        }
    }

    private function onClick(_arg_1:MouseEvent):void {
        _arg_1.stopImmediatePropagation();
        this.selected_.removeEventListener(MouseEvent.CLICK, this.onClick);
        if (contains(this.selected_)) {
            removeChild(this.selected_);
        }
        this.showAll();
    }

    private function showAll():void {
        var _local_1:int;
        var _local_2:Point;
        var _local_4:DropDownItem;
        _local_1 = 0;
        _local_2 = parent.localToGlobal(new Point(x, y));
        this.all_.x = _local_2.x;
        this.all_.y = _local_2.y;
        var _local_3:int;
        while (_local_3 < this.strings_.length) {
            _local_4 = new DropDownItem(this.strings_[_local_3], this.w_, this.h_);
            _local_4.addEventListener(MouseEvent.CLICK, this.onSelect);
            _local_4.x = this.xOffset_;
            _local_4.y = _local_1;
            this.all_.addChild(_local_4);
            _local_1 = (_local_1 + _local_4.h_);
            _local_3++;
        }
        this.all_.addEventListener(MouseEvent.ROLL_OUT, this.onOut);
        stage.addChild(this.all_);
    }

    private function hideAll():void {
        this.all_.removeEventListener(MouseEvent.ROLL_OUT, this.onOut);
        stage.removeChild(this.all_);
    }

    private function onSelect(_arg_1:MouseEvent):void {
        _arg_1.stopImmediatePropagation();
        this.hideAll();
        var _local_2:DropDownItem = (_arg_1.target as DropDownItem);
        this.setSelected(_local_2.getValue());
    }

    private function onOut(_arg_1:MouseEvent):void {
        this.hideAll();
        this.setSelected(this.selected_.getValue());
    }


}
}//package com.company.assembleegameclient.ui.dropdown
