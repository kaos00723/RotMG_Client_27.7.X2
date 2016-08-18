package com.company.assembleegameclient.mapeditor {
import com.company.assembleegameclient.objects.ObjectLibrary;
import com.company.assembleegameclient.ui.tooltip.ToolTip;

import flash.display.Bitmap;
import flash.display.BitmapData;

class ObjectElement extends Element {

    public var objXML_:XML;

    public function ObjectElement(_arg_1:XML) {
        var _local_3:Bitmap;
        super(int(_arg_1.@type));
        this.objXML_ = _arg_1;
        var _local_2:BitmapData = ObjectLibrary.getRedrawnTextureFromType(type_, 100, true, false);
        _local_3 = new Bitmap(_local_2);
        var _local_4:Number = ((WIDTH - 4) / Math.max(_local_3.width, _local_3.height));
        _local_3.scaleX = (_local_3.scaleY = _local_4);
        _local_3.x = ((WIDTH / 2) - (_local_3.width / 2));
        _local_3.y = ((HEIGHT / 2) - (_local_3.height / 2));
        addChild(_local_3);
    }

    override protected function getToolTip():ToolTip {
        return (new ObjectTypeToolTip(this.objXML_));
    }


}
}//package com.company.assembleegameclient.mapeditor
