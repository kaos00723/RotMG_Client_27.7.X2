package com.company.assembleegameclient.mapeditor {
import com.company.assembleegameclient.editor.CommandEvent;
import com.company.assembleegameclient.editor.CommandList;
import com.company.assembleegameclient.editor.CommandQueue;
import com.company.assembleegameclient.map.GroundLibrary;
import com.company.assembleegameclient.map.RegionLibrary;
import com.company.assembleegameclient.objects.ObjectLibrary;
import com.company.assembleegameclient.screens.AccountScreen;
import com.company.assembleegameclient.ui.dropdown.DropDown;
import com.company.util.IntPoint;
import com.company.util.SpriteUtil;
import com.hurlant.util.Base64;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.geom.Rectangle;
import flash.net.FileFilter;
import flash.net.FileReference;
import flash.utils.ByteArray;

import kabam.lib.json.JsonParser;
import kabam.rotmg.core.StaticInjectorContext;
import kabam.rotmg.ui.view.components.ScreenBase;

import net.hires.debug.Stats;

public class EditingScreen extends Sprite {

    private static const MAP_Y:int = ((600 - MEMap.SIZE) - 10);//78
    public static const stats_:Stats = new Stats();

    public var commandMenu_:MECommandMenu;
    private var commandQueue_:CommandQueue;
    public var meMap_:MEMap;
    public var infoPane_:InfoPane;
    public var chooserDrowDown_:DropDown;
    public var groundChooser_:GroundChooser;
    public var objChooser_:ObjectChooser;
    public var regionChooser_:RegionChooser;
    public var chooser_:Chooser;
    public var filename_:String = null;
    private var json:JsonParser;
    private var tilesBackup:Vector.<METile>;
    private var loadedFile_:FileReference = null;

    public function EditingScreen() {
        addChild(new ScreenBase());
        addChild(new AccountScreen());
        this.json = StaticInjectorContext.getInjector().getInstance(JsonParser);
        this.commandMenu_ = new MECommandMenu();
        this.commandMenu_.x = 15;
        this.commandMenu_.y = (MAP_Y - 30);
        this.commandMenu_.addEventListener(CommandEvent.UNDO_COMMAND_EVENT, this.onUndo);
        this.commandMenu_.addEventListener(CommandEvent.REDO_COMMAND_EVENT, this.onRedo);
        this.commandMenu_.addEventListener(CommandEvent.CLEAR_COMMAND_EVENT, this.onClear);
        this.commandMenu_.addEventListener(CommandEvent.LOAD_COMMAND_EVENT, this.onLoad);
        this.commandMenu_.addEventListener(CommandEvent.SAVE_COMMAND_EVENT, this.onSave);
        this.commandMenu_.addEventListener(CommandEvent.TEST_COMMAND_EVENT, this.onTest);
        this.commandMenu_.addEventListener(CommandEvent.SELECT_COMMAND_EVENT, this.onMenuSelect);
        addChild(this.commandMenu_);
        this.commandQueue_ = new CommandQueue();
        this.meMap_ = new MEMap();
        this.meMap_.addEventListener(TilesEvent.TILES_EVENT, this.onTilesEvent);
        this.meMap_.x = ((800 / 2) - (MEMap.SIZE / 2));
        this.meMap_.y = MAP_Y;
        addChild(this.meMap_);
        this.infoPane_ = new InfoPane(this.meMap_);
        this.infoPane_.x = 4;
        this.infoPane_.y = ((600 - InfoPane.HEIGHT) - 10);
        addChild(this.infoPane_);
        this.chooserDrowDown_ = new DropDown(new <String>["Ground", "Objects", "Regions"], Chooser.WIDTH, 26);
        this.chooserDrowDown_.x = ((this.meMap_.x + MEMap.SIZE) + 4);
        this.chooserDrowDown_.y = MAP_Y;
        this.chooserDrowDown_.addEventListener(Event.CHANGE, this.onDropDownChange);
        addChild(this.chooserDrowDown_);
        this.groundChooser_ = new GroundChooser();
        this.groundChooser_.x = this.chooserDrowDown_.x;
        this.groundChooser_.y = ((this.chooserDrowDown_.y + this.chooserDrowDown_.height) + 4);
        this.chooser_ = this.groundChooser_;
        addChild(this.groundChooser_);
        this.objChooser_ = new ObjectChooser();
        this.objChooser_.x = this.chooserDrowDown_.x;
        this.objChooser_.y = ((this.chooserDrowDown_.y + this.chooserDrowDown_.height) + 4);
        this.regionChooser_ = new RegionChooser();
        this.regionChooser_.x = this.chooserDrowDown_.x;
        this.regionChooser_.y = ((this.chooserDrowDown_.y + this.chooserDrowDown_.height) + 4);
    }

    private function onTilesEvent(_arg_1:TilesEvent):void {
        var _local_2:IntPoint;
        var _local_3:METile;
        var _local_4:int;
        var _local_5:String;
        var _local_6:EditTileProperties;
        var _local_7:Vector.<METile>;
        _local_2 = _arg_1.tiles_[0];
        switch (this.commandMenu_.getCommand()) {
            case MECommandMenu.DRAW_COMMAND:
                this.addModifyCommandList(_arg_1.tiles_, this.chooser_.layer_, this.chooser_.selectedType());
                break;
            case MECommandMenu.ERASE_COMMAND:
                this.addModifyCommandList(_arg_1.tiles_, this.chooser_.layer_, -1);
                break;
            case MECommandMenu.SAMPLE_COMMAND:
                _local_4 = this.meMap_.getType(_local_2.x_, _local_2.y_, this.chooser_.layer_);
                if (_local_4 == -1) {
                    return;
                }
                this.chooser_.setSelectedType(_local_4);
                this.commandMenu_.setCommand(MECommandMenu.DRAW_COMMAND);
                break;
            case MECommandMenu.EDIT_COMMAND:
                _local_5 = this.meMap_.getObjectName(_local_2.x_, _local_2.y_);
                _local_6 = new EditTileProperties(_arg_1.tiles_, _local_5);
                _local_6.addEventListener(Event.COMPLETE, this.onEditComplete);
                addChild(_local_6);
                break;
            case MECommandMenu.CUT_COMMAND:
                this.tilesBackup = new Vector.<METile>();
                _local_7 = new Vector.<METile>();
                for each (_local_2 in _arg_1.tiles_) {
                    _local_3 = this.meMap_.getTile(_local_2.x_, _local_2.y_);
                    if (_local_3 != null) {
                        _local_3 = _local_3.clone();
                    }
                    this.tilesBackup.push(_local_3);
                    _local_7.push(null);
                }
                this.addPasteCommandList(_arg_1.tiles_, _local_7);
                this.meMap_.freezeSelect();
                this.commandMenu_.setCommand(MECommandMenu.PASTE_COMMAND);
                break;
            case MECommandMenu.COPY_COMMAND:
                this.tilesBackup = new Vector.<METile>();
                for each (_local_2 in _arg_1.tiles_) {
                    _local_3 = this.meMap_.getTile(_local_2.x_, _local_2.y_);
                    if (_local_3 != null) {
                        _local_3 = _local_3.clone();
                    }
                    this.tilesBackup.push(_local_3);
                }
                this.meMap_.freezeSelect();
                this.commandMenu_.setCommand(MECommandMenu.PASTE_COMMAND);
                break;
            case MECommandMenu.PASTE_COMMAND:
                this.addPasteCommandList(_arg_1.tiles_, this.tilesBackup);
                break;
        }
        this.meMap_.draw();
    }

    private function onEditComplete(_arg_1:Event):void {
        var _local_2:EditTileProperties = (_arg_1.currentTarget as EditTileProperties);
        this.addObjectNameCommandList(_local_2.tiles_, _local_2.getObjectName());
    }

    private function addModifyCommandList(_arg_1:Vector.<IntPoint>, _arg_2:int, _arg_3:int):void {
        var _local_5:IntPoint;
        var _local_6:int;
        var _local_4:CommandList = new CommandList();
        for each (_local_5 in _arg_1) {
            _local_6 = this.meMap_.getType(_local_5.x_, _local_5.y_, _arg_2);
            if (_local_6 != _arg_3) {
                _local_4.addCommand(new MEModifyCommand(this.meMap_, _local_5.x_, _local_5.y_, _arg_2, _local_6, _arg_3));
            }
        }
        if (_local_4.empty()) {
            return;
        }
        this.commandQueue_.addCommandList(_local_4);
    }

    private function addPasteCommandList(_arg_1:Vector.<IntPoint>, _arg_2:Vector.<METile>):void {
        var _local_5:IntPoint;
        var _local_6:METile;
        var _local_3:CommandList = new CommandList();
        var _local_4:int;
        for each (_local_5 in _arg_1) {
            if (_local_4 >= _arg_2.length) break;
            _local_6 = this.meMap_.getTile(_local_5.x_, _local_5.y_);
            _local_3.addCommand(new MEReplaceCommand(this.meMap_, _local_5.x_, _local_5.y_, _local_6, _arg_2[_local_4]));
            _local_4++;
        }
        if (_local_3.empty()) {
            return;
        }
        this.commandQueue_.addCommandList(_local_3);
    }

    private function addObjectNameCommandList(_arg_1:Vector.<IntPoint>, _arg_2:String):void {
        var _local_4:IntPoint;
        var _local_5:String;
        var _local_3:CommandList = new CommandList();
        for each (_local_4 in _arg_1) {
            _local_5 = this.meMap_.getObjectName(_local_4.x_, _local_4.y_);
            if (_local_5 != _arg_2) {
                _local_3.addCommand(new MEObjectNameCommand(this.meMap_, _local_4.x_, _local_4.y_, _local_5, _arg_2));
            }
        }
        if (_local_3.empty()) {
            return;
        }
        this.commandQueue_.addCommandList(_local_3);
    }

    private function onDropDownChange(_arg_1:Event):void {
        switch (this.chooserDrowDown_.getValue()) {
            case "Ground":
                SpriteUtil.safeAddChild(this, this.groundChooser_);
                SpriteUtil.safeRemoveChild(this, this.objChooser_);
                SpriteUtil.safeRemoveChild(this, this.regionChooser_);
                this.chooser_ = this.groundChooser_;
                return;
            case "Objects":
                SpriteUtil.safeRemoveChild(this, this.groundChooser_);
                SpriteUtil.safeAddChild(this, this.objChooser_);
                SpriteUtil.safeRemoveChild(this, this.regionChooser_);
                this.chooser_ = this.objChooser_;
                return;
            case "Regions":
                SpriteUtil.safeRemoveChild(this, this.groundChooser_);
                SpriteUtil.safeRemoveChild(this, this.objChooser_);
                SpriteUtil.safeAddChild(this, this.regionChooser_);
                this.chooser_ = this.regionChooser_;
                return;
        }
    }

    private function onUndo(_arg_1:CommandEvent):void {
        this.commandQueue_.undo();
        this.meMap_.draw();
    }

    private function onRedo(_arg_1:CommandEvent):void {
        this.commandQueue_.redo();
        this.meMap_.draw();
    }

    private function onClear(_arg_1:CommandEvent):void {
        var _local_4:IntPoint;
        var _local_5:METile;
        var _local_2:Vector.<IntPoint> = this.meMap_.getAllTiles();
        var _local_3:CommandList = new CommandList();
        for each (_local_4 in _local_2) {
            _local_5 = this.meMap_.getTile(_local_4.x_, _local_4.y_);
            if (_local_5 != null) {
                _local_3.addCommand(new MEClearCommand(this.meMap_, _local_4.x_, _local_4.y_, _local_5));
            }
        }
        if (_local_3.empty()) {
            return;
        }
        this.commandQueue_.addCommandList(_local_3);
        this.meMap_.draw();
        this.filename_ = null;
    }

    private function createMapJSON():String {
        var _local_7:int;
        var _local_8:METile;
        var _local_9:Object;
        var _local_10:String;
        var _local_11:int;
        var _local_1:Rectangle = this.meMap_.getTileBounds();
        if (_local_1 == null) {
            return (null);
        }
        var _local_2:Object = {};
        _local_2["width"] = int(_local_1.width);
        _local_2["height"] = int(_local_1.height);
        var _local_3:Object = {};
        var _local_4:Array = [];
        var _local_5:ByteArray = new ByteArray();
        var _local_6:int = _local_1.y;
        while (_local_6 < _local_1.bottom) {
            _local_7 = _local_1.x;
            while (_local_7 < _local_1.right) {
                _local_8 = this.meMap_.getTile(_local_7, _local_6);
                _local_9 = this.getEntry(_local_8);
                _local_10 = this.json.stringify(_local_9);
                if (!_local_3.hasOwnProperty(_local_10)) {
                    _local_11 = _local_4.length;
                    _local_3[_local_10] = _local_11;
                    _local_4.push(_local_9);
                }
                else {
                    _local_11 = _local_3[_local_10];
                }
                _local_5.writeShort(_local_11);
                _local_7++;
            }
            _local_6++;
        }
        _local_2["dict"] = _local_4;
        _local_5.compress();
        _local_2["data"] = Base64.encodeByteArray(_local_5);
        return (this.json.stringify(_local_2));
    }

    private function onSave(_arg_1:CommandEvent):void {
        var _local_2:String = this.createMapJSON();
        if (_local_2 == null) {
            return;
        }
        new FileReference().save(_local_2, (((this.filename_ == null)) ? "map.jm" : this.filename_));
    }

    private function getEntry(_arg_1:METile):Object {
        var _local_3:Vector.<int>;
        var _local_4:String;
        var _local_5:Object;
        var _local_2:Object = {};
        if (_arg_1 != null) {
            _local_3 = _arg_1.types_;
            if (_local_3[Layer.GROUND] != -1) {
                _local_4 = GroundLibrary.getIdFromType(_local_3[Layer.GROUND]);
                _local_2["ground"] = _local_4;
            }
            if (_local_3[Layer.OBJECT] != -1) {
                _local_4 = ObjectLibrary.getIdFromType(_local_3[Layer.OBJECT]);
                _local_5 = {"id": _local_4};
                if (_arg_1.objName_ != null) {
                    _local_5["name"] = _arg_1.objName_;
                }
                _local_2["objs"] = [_local_5];
            }
            if (_local_3[Layer.REGION] != -1) {
                _local_4 = RegionLibrary.getIdFromType(_local_3[Layer.REGION]);
                _local_2["regions"] = [{"id": _local_4}];
            }
        }
        return (_local_2);
    }

    private function onLoad(_arg_1:CommandEvent):void {
        this.loadedFile_ = new FileReference();
        this.loadedFile_.addEventListener(Event.SELECT, this.onFileBrowseSelect);
        this.loadedFile_.browse([new FileFilter("JSON Map (*.jm)", "*.jm")]);
    }

    private function onFileBrowseSelect(event:Event):void {
        var loadedFile:FileReference = (event.target as FileReference);
        loadedFile.addEventListener(Event.COMPLETE, this.onFileLoadComplete);
        loadedFile.addEventListener(IOErrorEvent.IO_ERROR, this.onFileLoadIOError);
        try {
            loadedFile.load();
        }
        catch (e:Error) {
        }
    }

    private function onFileLoadComplete(_arg_1:Event):void {
        var _local_9:int;
        var _local_11:int;
        var _local_12:Object;
        var _local_13:Array;
        var _local_14:Array;
        var _local_15:Object;
        var _local_16:Object;
        var _local_2:FileReference = (_arg_1.target as FileReference);
        this.filename_ = _local_2.name;
        var _local_3:Object = this.json.parse(_local_2.data.toString());
        var _local_4:int = _local_3["width"];
        var _local_5:int = _local_3["height"];
        var _local_6:Rectangle = new Rectangle(int(((MEMap.NUM_SQUARES / 2) - (_local_4 / 2))), int(((MEMap.NUM_SQUARES / 2) - (_local_5 / 2))), _local_4, _local_5);
        this.meMap_.clear();
        this.commandQueue_.clear();
        var _local_7:Array = _local_3["dict"];
        var _local_8:ByteArray = Base64.decodeToByteArray(_local_3["data"]);
        _local_8.uncompress();
        var _local_10:int = _local_6.y;
        while (_local_10 < _local_6.bottom) {
            _local_11 = _local_6.x;
            while (_local_11 < _local_6.right) {
                _local_12 = _local_7[_local_8.readShort()];
                if (_local_12.hasOwnProperty("ground")) {
                    _local_9 = GroundLibrary.idToType_[_local_12["ground"]];
                    this.meMap_.modifyTile(_local_11, _local_10, Layer.GROUND, _local_9);
                }
                _local_13 = _local_12["objs"];
                if (_local_13 != null) {
                    for each (_local_15 in _local_13) {
                        if (ObjectLibrary.idToType_.hasOwnProperty(_local_15["id"])) {
                            _local_9 = ObjectLibrary.idToType_[_local_15["id"]];
                            this.meMap_.modifyTile(_local_11, _local_10, Layer.OBJECT, _local_9);
                            if (_local_15.hasOwnProperty("name")) {
                                this.meMap_.modifyObjectName(_local_11, _local_10, _local_15["name"]);
                            }
                        }
                    }
                }
                _local_14 = _local_12["regions"];
                if (_local_14 != null) {
                    for each (_local_16 in _local_14) {
                        _local_9 = RegionLibrary.idToType_[_local_16["id"]];
                        this.meMap_.modifyTile(_local_11, _local_10, Layer.REGION, _local_9);
                    }
                }
                _local_11++;
            }
            _local_10++;
        }
        this.meMap_.draw();
    }

    private function onFileLoadIOError(_arg_1:Event):void {
    }

    private function onTest(_arg_1:Event):void {
        dispatchEvent(new MapTestEvent(this.createMapJSON()));
    }

    private function onMenuSelect(_arg_1:Event):void {
        if (this.meMap_ != null) {
            this.meMap_.clearSelect();
        }
    }


}
}//package com.company.assembleegameclient.mapeditor
