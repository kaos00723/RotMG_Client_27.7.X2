package com.company.assembleegameclient.map {
import com.company.assembleegameclient.objects.GameObject;

import flash.utils.getTimer;

public class Quest {

    public var map_:Map;
    public var objectId_:int = -1;
    private var questAvailableAt_:int = 0;
    private var questOldAt_:int = 0;

    public function Quest(_arg_1:Map) {
        this.map_ = _arg_1;
    }

    public function setObject(_arg_1:int):void {
        if ((((this.objectId_ == -1)) && (!((_arg_1 == -1))))) {
            this.questAvailableAt_ = (getTimer() + 4000);
            this.questOldAt_ = (this.questAvailableAt_ + 2000);
        }
        this.objectId_ = _arg_1;
    }

    public function completed():void {
        this.questAvailableAt_ = ((getTimer() + 15000) - (Math.random() * 10000));
        this.questOldAt_ = (this.questAvailableAt_ + 2000);
    }

    public function getObject(_arg_1:int):GameObject {
        if (_arg_1 < this.questAvailableAt_) {
            return (null);
        }
        return (this.map_.goDict_[this.objectId_]);
    }

    public function isNew(_arg_1:int):Boolean {
        return ((_arg_1 < this.questOldAt_));
    }


}
}//package com.company.assembleegameclient.map
