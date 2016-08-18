package com.company.assembleegameclient.mapeditor {
import com.company.assembleegameclient.map.GroundLibrary;
import com.company.util.MoreStringUtil;

class GroundChooser extends Chooser {

    public function GroundChooser() {
        var _local_1:String;
        var _local_3:int;
        var _local_4:GroundElement;
        super(Layer.GROUND);
        var _local_2:Vector.<String> = new Vector.<String>();
        for (_local_1 in GroundLibrary.idToType_) {
            _local_2.push(_local_1);
        }
        _local_2.sort(MoreStringUtil.cmp);
        for each (_local_1 in _local_2) {
            _local_3 = GroundLibrary.idToType_[_local_1];
            _local_4 = new GroundElement(GroundLibrary.xmlLibrary_[_local_3]);
            addElement(_local_4);
        }
    }

}
}//package com.company.assembleegameclient.mapeditor
