package com.company.assembleegameclient.screens {
import com.company.assembleegameclient.parameters.Parameters;

import flash.display.Sprite;
import flash.events.MouseEvent;

import kabam.rotmg.servers.api.Server;

public class ServerBoxes extends Sprite {

    private var boxes_:Vector.<ServerBox>;

    public function ServerBoxes(_arg_1:Vector.<Server>) {
        var _local_2:ServerBox;
        var _local_3:int;
        var _local_4:Server;
        this.boxes_ = new Vector.<ServerBox>();
        super();
        _local_2 = new ServerBox(null);
        _local_2.setSelected(true);
        _local_2.x = ((ServerBox.WIDTH / 2) + 2);
        _local_2.addEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
        addChild(_local_2);
        this.boxes_.push(_local_2);
        _local_3 = 2;
        for each (_local_4 in _arg_1) {
            _local_2 = new ServerBox(_local_4);
            if (_local_4.name == Parameters.data_.preferredServer) {
                this.setSelected(_local_2);
            }
            _local_2.x = ((_local_3 % 2) * (ServerBox.WIDTH + 4));
            _local_2.y = (int((_local_3 / 2)) * (ServerBox.HEIGHT + 4));
            _local_2.addEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
            addChild(_local_2);
            this.boxes_.push(_local_2);
            _local_3++;
        }
    }

    private function onMouseDown(_arg_1:MouseEvent):void {
        var _local_2:ServerBox = (_arg_1.currentTarget as ServerBox);
        if (_local_2 == null) {
            return;
        }
        this.setSelected(_local_2);
        Parameters.data_.preferredServer = _local_2.value_;
        Parameters.save();
    }

    private function setSelected(_arg_1:ServerBox):void {
        var _local_2:ServerBox;
        for each (_local_2 in this.boxes_) {
            _local_2.setSelected(false);
        }
        _arg_1.setSelected(true);
    }


}
}//package com.company.assembleegameclient.screens
