package com.company.assembleegameclient.background {
import com.company.assembleegameclient.map.Camera;
import com.company.util.AssetLibrary;
import com.company.util.ImageSet;
import com.company.util.PointUtil;

import flash.display.IGraphicsData;

public class StarBackground extends Background {

    public var stars_:Vector.<Star>;
    protected var graphicsData_:Vector.<IGraphicsData>;

    public function StarBackground() {
        this.stars_ = new Vector.<Star>();
        this.graphicsData_ = new Vector.<IGraphicsData>();
        super();
        var _local_1:int;
        while (_local_1 < 100) {
            this.tryAddStar();
            _local_1++;
        }
    }

    override public function draw(_arg_1:Camera, _arg_2:int):void {
        var _local_3:Star;
        this.graphicsData_.length = 0;
        for each (_local_3 in this.stars_) {
            _local_3.draw(this.graphicsData_, _arg_1, _arg_2);
        }
        graphics.clear();
        graphics.drawGraphicsData(this.graphicsData_);
    }

    private function tryAddStar():void {
        var _local_3:Star;
        var _local_1:ImageSet = AssetLibrary.getImageSet("stars");
        var _local_2:Star = new Star(((Math.random() * 1000) - 500), ((Math.random() * 1000) - 500), (4 * (0.5 + (0.5 * Math.random()))), _local_1.images_[int((_local_1.images_.length * Math.random()))]);
        for each (_local_3 in this.stars_) {
            if (PointUtil.distanceXY(_local_2.x_, _local_2.y_, _local_3.x_, _local_3.y_) < 3) {
                return;
            }
        }
        this.stars_.push(_local_2);
    }


}
}//package com.company.assembleegameclient.background

import com.company.assembleegameclient.map.Camera;

import flash.display.BitmapData;
import flash.display.GraphicsBitmapFill;
import flash.display.GraphicsEndFill;
import flash.display.GraphicsPath;
import flash.display.GraphicsPathCommand;
import flash.display.IGraphicsData;
import flash.geom.Matrix;

class Star {

    protected static const sqCommands:Vector.<int> = new <int>[GraphicsPathCommand.MOVE_TO, GraphicsPathCommand.LINE_TO, GraphicsPathCommand.LINE_TO, GraphicsPathCommand.LINE_TO];
    protected static const END_FILL:GraphicsEndFill = new GraphicsEndFill();

    public var x_:Number;
    public var y_:Number;
    public var scale_:Number;
    public var bitmap_:BitmapData;
    /*private*/
    var w_:Number;
    /*private*/
    var h_:Number;
    protected var bitmapFill_:GraphicsBitmapFill;
    protected var path_:GraphicsPath;

    public function Star(_arg_1:Number, _arg_2:Number, _arg_3:Number, _arg_4:BitmapData):void {
        this.bitmapFill_ = new GraphicsBitmapFill(null, new Matrix(), false, false);
        this.path_ = new GraphicsPath(sqCommands, new Vector.<Number>());
        super();
        this.x_ = _arg_1;
        this.y_ = _arg_2;
        this.scale_ = _arg_3;
        this.bitmap_ = _arg_4;
        this.w_ = (this.bitmap_.width * this.scale_);
        this.h_ = (this.bitmap_.height * this.scale_);
    }

    public function draw(_arg_1:Vector.<IGraphicsData>, _arg_2:Camera, _arg_3:int):void {
        var _local_4:Number = ((this.x_ * Math.cos(-(_arg_2.angleRad_))) - (this.y_ * Math.sin(-(_arg_2.angleRad_))));
        var _local_5:Number = ((this.x_ * Math.sin(-(_arg_2.angleRad_))) + (this.y_ * Math.cos(-(_arg_2.angleRad_))));
        var _local_6:Matrix = this.bitmapFill_.matrix;
        _local_6.identity();
        _local_6.translate((-(this.bitmap_.width) / 2), (-(this.bitmap_.height) / 2));
        _local_6.scale(this.scale_, this.scale_);
        _local_6.translate(_local_4, _local_5);
        this.bitmapFill_.bitmapData = this.bitmap_;
        this.path_.data.length = 0;
        var _local_7:Number = (_local_4 - (this.w_ / 2));
        var _local_8:Number = (_local_5 - (this.h_ / 2));
        this.path_.data.push(_local_7, _local_8, (_local_7 + this.w_), _local_8, (_local_7 + this.w_), (_local_8 + this.h_), _local_7, (_local_8 + this.h_));
        _arg_1.push(this.bitmapFill_);
        _arg_1.push(this.path_);
        _arg_1.push(END_FILL);
    }


}
