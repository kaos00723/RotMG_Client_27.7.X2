package com.company.assembleegameclient.ui.panels.itemgrids.itemtiles {
import com.company.assembleegameclient.objects.ObjectLibrary;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.filters.ColorMatrixFilter;
import flash.geom.Matrix;

import kabam.rotmg.constants.ItemConstants;
import kabam.rotmg.text.view.BitmapTextFactory;
import kabam.rotmg.text.view.stringBuilder.StaticStringBuilder;

public class ItemTileSprite extends Sprite {

    protected static const DIM_FILTER:Array = [new ColorMatrixFilter([0.4, 0, 0, 0, 0, 0, 0.4, 0, 0, 0, 0, 0, 0.4, 0, 0, 0, 0, 0, 1, 0])];
    private static const IDENTITY_MATRIX:Matrix = new Matrix();
    private static const DOSE_MATRIX:Matrix = function ():Matrix {
        var _local_1:* = new Matrix();
        _local_1.translate(10, 5);
        return (_local_1);
    }();

    public var itemId:int;
    public var itemBitmap:Bitmap;
    private var bitmapFactory:BitmapTextFactory;

    public function ItemTileSprite() {
        this.itemBitmap = new Bitmap();
        addChild(this.itemBitmap);
        this.itemId = -1;
    }

    public function setDim(_arg_1:Boolean):void {
        filters = ((_arg_1) ? DIM_FILTER : null);
    }

    public function setType(_arg_1:int):void {
        this.itemId = _arg_1;
        this.drawTile();
    }

    public function drawTile():void {
        var _local_1:BitmapData;
        var _local_2:XML;
        var _local_3:BitmapData;
        if (this.itemId != ItemConstants.NO_ITEM) {
            _local_1 = ObjectLibrary.getRedrawnTextureFromType(this.itemId, 80, true);
            _local_2 = ObjectLibrary.xmlLibrary_[this.itemId];
            if (((((_local_2) && (_local_2.hasOwnProperty("Doses")))) && (this.bitmapFactory))) {
                _local_1 = _local_1.clone();
                _local_3 = this.bitmapFactory.make(new StaticStringBuilder(String(_local_2.Doses)), 12, 0xFFFFFF, false, IDENTITY_MATRIX, false);
                _local_1.draw(_local_3, DOSE_MATRIX);
            }
            this.itemBitmap.bitmapData = _local_1;
            this.itemBitmap.x = (-(_local_1.width) / 2);
            this.itemBitmap.y = (-(_local_1.height) / 2);
            visible = true;
        }
        else {
            visible = false;
        }
    }

    public function setBitmapFactory(_arg_1:BitmapTextFactory):void {
        this.bitmapFactory = _arg_1;
    }


}
}//package com.company.assembleegameclient.ui.panels.itemgrids.itemtiles
