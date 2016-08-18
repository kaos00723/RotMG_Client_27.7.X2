package com.company.assembleegameclient.background {
import com.company.assembleegameclient.map.Camera;
import com.company.util.GraphicsUtil;

import flash.display.BitmapData;
import flash.display.BitmapDataChannel;
import flash.display.GraphicsBitmapFill;
import flash.display.GraphicsPath;
import flash.display.IGraphicsData;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

public class NexusBackground extends Background {

    public static const MOVEMENT:Point = new Point(0.01, 0.01);

    private var water_:BitmapData;
    private var islands_:Vector.<Island>;
    protected var graphicsData_:Vector.<IGraphicsData>;
    private var bitmapFill_:GraphicsBitmapFill;
    private var path_:GraphicsPath;

    public function NexusBackground() {
        this.islands_ = new Vector.<Island>();
        this.graphicsData_ = new Vector.<IGraphicsData>();
        this.bitmapFill_ = new GraphicsBitmapFill(null, new Matrix(), true, false);
        this.path_ = new GraphicsPath(GraphicsUtil.QUAD_COMMANDS, new Vector.<Number>());
        super();
        this.water_ = new BitmapDataSpy(0x0400, 0x0400, false, 0);
        this.water_.perlinNoise(0x0400, 0x0400, 8, Math.random(), true, true, BitmapDataChannel.BLUE, false, null);
    }

    override public function draw(_arg_1:Camera, _arg_2:int):void {
        this.graphicsData_.length = 0;
        var _local_3:Matrix = this.bitmapFill_.matrix;
        _local_3.identity();
        _local_3.translate((_arg_2 * MOVEMENT.x), (_arg_2 * MOVEMENT.y));
        _local_3.rotate(-(_arg_1.angleRad_));
        this.bitmapFill_.bitmapData = this.water_;
        this.graphicsData_.push(this.bitmapFill_);
        this.path_.data.length = 0;
        var _local_4:Rectangle = _arg_1.clipRect_;
        this.path_.data.push(_local_4.left, _local_4.top, _local_4.right, _local_4.top, _local_4.right, _local_4.bottom, _local_4.left, _local_4.bottom);
        this.graphicsData_.push(this.path_);
        this.graphicsData_.push(GraphicsUtil.END_FILL);
        this.drawIslands(_arg_1, _arg_2);
        graphics.clear();
        graphics.drawGraphicsData(this.graphicsData_);
    }

    private function drawIslands(_arg_1:Camera, _arg_2:int):void {
        var _local_4:Island;
        var _local_3:int;
        while (_local_3 < this.islands_.length) {
            _local_4 = this.islands_[_local_3];
            _local_4.draw(_arg_1, _arg_2, this.graphicsData_);
            _local_3++;
        }
    }


}
}//package com.company.assembleegameclient.background

import com.company.assembleegameclient.background.NexusBackground;
import com.company.assembleegameclient.map.Camera;
import com.company.util.AssetLibrary;
import com.company.util.GraphicsUtil;

import flash.display.BitmapData;
import flash.display.GraphicsBitmapFill;
import flash.display.GraphicsPath;
import flash.display.IGraphicsData;
import flash.geom.Matrix;
import flash.geom.Point;

class Island {

    public var center_:Point;
    public var startTime_:int;
    public var bitmapData_:BitmapData;
    /*private*/
    var bitmapFill_:GraphicsBitmapFill;
    /*private*/
    var path_:GraphicsPath;

    public function Island(_arg_1:Number, _arg_2:Number, _arg_3:int):void {
        this.bitmapFill_ = new GraphicsBitmapFill(null, new Matrix(), true, false);
        this.path_ = new GraphicsPath(GraphicsUtil.QUAD_COMMANDS, new Vector.<Number>());
        super();
        this.center_ = new Point(_arg_1, _arg_2);
        this.startTime_ = _arg_3;
        this.bitmapData_ = AssetLibrary.getImage("stars");
    }

    public function draw(_arg_1:Camera, _arg_2:int, _arg_3:Vector.<IGraphicsData>):void {
        var _local_4:int = (_arg_2 - this.startTime_);
        var _local_5:Number = (this.center_.x + (_local_4 * NexusBackground.MOVEMENT.x));
        var _local_6:Number = (this.center_.y + (_local_4 * NexusBackground.MOVEMENT.y));
        var _local_7:Matrix = this.bitmapFill_.matrix;
        _local_7.identity();
        _local_7.translate(_local_5, _local_6);
        _local_7.rotate(-(_arg_1.angleRad_));
        this.bitmapFill_.bitmapData = this.bitmapData_;
        _arg_3.push(this.bitmapFill_);
        this.path_.data.length = 0;
        var _local_8:Point = _local_7.transformPoint(new Point(_local_5, _local_6));
        var _local_9:Point = _local_7.transformPoint(new Point((_local_5 + this.bitmapData_.width), (_local_6 + this.bitmapData_.height)));
        this.path_.data.push(_local_8.x, _local_8.y, _local_9.x, _local_8.y, _local_9.x, _local_9.y, _local_8.x, _local_9.y);
        _arg_3.push(this.path_);
        _arg_3.push(GraphicsUtil.END_FILL);
    }


}
