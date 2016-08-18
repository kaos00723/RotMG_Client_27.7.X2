package com.company.assembleegameclient.account.ui {
import com.company.ui.BaseSimpleText;

import flash.display.CapsStyle;
import flash.display.JointStyle;
import flash.display.LineScaleMode;
import flash.display.Sprite;
import flash.events.Event;
import flash.filters.DropShadowFilter;

import kabam.rotmg.text.view.TextFieldDisplayConcrete;
import kabam.rotmg.text.view.stringBuilder.LineBuilder;
import kabam.rotmg.text.view.stringBuilder.StaticStringBuilder;

public class TextInputField extends Sprite {

    public static const HEIGHT:int = 88;

    public var nameText_:TextFieldDisplayConcrete;
    public var inputText_:BaseSimpleText;
    public var errorText_:TextFieldDisplayConcrete;

    public function TextInputField(_arg_1:String, _arg_2:Boolean) {
        this.nameText_ = new TextFieldDisplayConcrete().setSize(18).setColor(0xB3B3B3);
        this.nameText_.setBold(true);
        this.nameText_.setStringBuilder(new LineBuilder().setParams(_arg_1));
        this.nameText_.filters = [new DropShadowFilter(0, 0, 0)];
        addChild(this.nameText_);
        this.inputText_ = new BaseSimpleText(20, 0xB3B3B3, true, 238, 30);
        this.inputText_.y = 30;
        this.inputText_.x = 6;
        this.inputText_.border = false;
        this.inputText_.displayAsPassword = _arg_2;
        this.inputText_.updateMetrics();
        addChild(this.inputText_);
        graphics.lineStyle(2, 0x454545, 1, false, LineScaleMode.NORMAL, CapsStyle.ROUND, JointStyle.ROUND);
        graphics.beginFill(0x333333, 1);
        graphics.drawRect(0, this.inputText_.y, 238, 30);
        graphics.endFill();
        graphics.lineStyle();
        this.inputText_.addEventListener(Event.CHANGE, this.onInputChange);
        this.errorText_ = new TextFieldDisplayConcrete().setSize(12).setColor(16549442);
        this.errorText_.y = (this.inputText_.y + 32);
        this.errorText_.filters = [new DropShadowFilter(0, 0, 0)];
        addChild(this.errorText_);
    }

    public function text():String {
        return (this.inputText_.text);
    }

    public function clearText():void {
        this.inputText_.text = "";
    }

    public function setError(_arg_1:String, _arg_2:Object = null):void {
        this.errorText_.setStringBuilder(new LineBuilder().setParams(_arg_1, _arg_2));
    }

    public function clearError():void {
        this.errorText_.setStringBuilder(new StaticStringBuilder(""));
    }

    public function onInputChange(_arg_1:Event):void {
        this.errorText_.setStringBuilder(new StaticStringBuilder(""));
    }


}
}//package com.company.assembleegameclient.account.ui
