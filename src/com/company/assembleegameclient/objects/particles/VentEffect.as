package com.company.assembleegameclient.objects.particles {
import com.company.assembleegameclient.objects.GameObject;
import com.company.assembleegameclient.util.FreeList;

public class VentEffect extends ParticleEffect {

    private static const BUBBLE_PERIOD:int = 50;

    public var go_:GameObject;
    public var lastUpdate_:int = -1;

    public function VentEffect(_arg_1:GameObject) {
        this.go_ = _arg_1;
    }

    override public function update(_arg_1:int, _arg_2:int):Boolean {
        var _local_4:int;
        var _local_5:VentParticle;
        var _local_6:Number;
        var _local_7:Number;
        var _local_8:Number;
        var _local_9:Number;
        if (this.go_.map_ == null) {
            return (false);
        }
        if (this.lastUpdate_ < 0) {
            this.lastUpdate_ = Math.max(0, (_arg_1 - 400));
        }
        x_ = this.go_.x_;
        y_ = this.go_.y_;
        var _local_3:int = int((this.lastUpdate_ / BUBBLE_PERIOD));
        while (_local_3 < int((_arg_1 / BUBBLE_PERIOD))) {
            _local_4 = (_local_3 * BUBBLE_PERIOD);
            _local_5 = (FreeList.newObject(VentParticle) as VentParticle);
            _local_5.restart(_local_4, _arg_1);
            _local_6 = (Math.random() * Math.PI);
            _local_7 = (Math.random() * 0.4);
            _local_8 = (this.go_.x_ + (_local_7 * Math.cos(_local_6)));
            _local_9 = (this.go_.y_ + (_local_7 * Math.sin(_local_6)));
            map_.addObj(_local_5, _local_8, _local_9);
            _local_3++;
        }
        this.lastUpdate_ = _arg_1;
        return (true);
    }


}
}//package com.company.assembleegameclient.objects.particles

import com.company.assembleegameclient.objects.particles.Particle;
import com.company.assembleegameclient.util.FreeList;

class VentParticle extends Particle {

    public var startTime_:int;
    public var speed_:int;

    public function VentParticle() {
        var _local_1:Number = Math.random();
        super(2542335, 0, (75 + (_local_1 * 50)));
        this.speed_ = (2.5 - (_local_1 * 1.5));
    }

    public function restart(_arg_1:int, _arg_2:int):void {
        this.startTime_ = _arg_1;
        var _local_3:Number = ((_arg_2 - this.startTime_) / 1000);
        z_ = (0 + (this.speed_ * _local_3));
    }

    override public function removeFromMap():void {
        super.removeFromMap();
        FreeList.deleteObject(this);
    }

    override public function update(_arg_1:int, _arg_2:int):Boolean {
        var _local_3:Number = ((_arg_1 - this.startTime_) / 1000);
        z_ = (0 + (this.speed_ * _local_3));
        return ((z_ < 1));
    }


}
