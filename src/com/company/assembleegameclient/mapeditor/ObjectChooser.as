package com.company.assembleegameclient.mapeditor {
import com.company.assembleegameclient.objects.ObjectLibrary;
import com.company.util.MoreStringUtil;

class ObjectChooser extends Chooser {

    public function ObjectChooser() {
        var _local_1:String;
        var _local_3:int;
        var _local_4:XML;
        var _local_5:ObjectElement;
        super(Layer.OBJECT);
        var _local_2:Vector.<String> = new Vector.<String>();
        for (_local_1 in ObjectLibrary.idToType_) {
            _local_2.push(_local_1);
        }
        _local_2.sort(MoreStringUtil.cmp);
        for each (_local_1 in _local_2) {
            _local_3 = ObjectLibrary.idToType_[_local_1];
            _local_4 = ObjectLibrary.xmlLibrary_[_local_3];
            if (!((((_local_4.hasOwnProperty("Item")) || (_local_4.hasOwnProperty("Player")))) || ((_local_4.Class == "Projectile")))) {
                _local_5 = new ObjectElement(_local_4);
                addElement(_local_5);
            }
        }
    }

}
}//package com.company.assembleegameclient.mapeditor
