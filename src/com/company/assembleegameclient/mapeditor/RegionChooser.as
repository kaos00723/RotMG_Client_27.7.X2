package com.company.assembleegameclient.mapeditor {
import com.company.assembleegameclient.map.RegionLibrary;

public class RegionChooser extends Chooser {

    public function RegionChooser() {
        var _local_1:XML;
        var _local_2:RegionElement;
        super(Layer.REGION);
        for each (_local_1 in RegionLibrary.xmlLibrary_) {
            _local_2 = new RegionElement(_local_1);
            addElement(_local_2);
        }
    }

}
}//package com.company.assembleegameclient.mapeditor
