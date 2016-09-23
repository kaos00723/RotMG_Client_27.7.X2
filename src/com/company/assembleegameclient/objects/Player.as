package com.company.assembleegameclient.objects {
import com.company.assembleegameclient.map.Camera;
import com.company.assembleegameclient.map.Square;
import com.company.assembleegameclient.map.mapoverlay.CharacterStatusText;
import com.company.assembleegameclient.objects.particles.HealingEffect;
import com.company.assembleegameclient.objects.particles.LevelUpEffect;
import com.company.assembleegameclient.parameters.Parameters;
import com.company.assembleegameclient.sound.SoundEffectLibrary;
import com.company.assembleegameclient.tutorial.Tutorial;
import com.company.assembleegameclient.tutorial.doneAction;
import com.company.assembleegameclient.util.AnimatedChar;
import com.company.assembleegameclient.util.ConditionEffect;
import com.company.assembleegameclient.util.FameUtil;
import com.company.assembleegameclient.util.FreeList;
import com.company.assembleegameclient.util.MaskedImage;
import com.company.assembleegameclient.util.TextureRedrawer;
import com.company.assembleegameclient.util.redrawers.GlowRedrawer;
import com.company.util.CachingColorTransformer;
import com.company.util.ConversionUtil;
import com.company.util.GraphicsUtil;
import com.company.util.IntPoint;
import com.company.util.MoreColorUtil;
import com.company.util.PointUtil;
import com.company.util.Trig;

import flash.display.BitmapData;
import flash.display.GraphicsPath;
import flash.display.GraphicsSolidFill;
import flash.display.IGraphicsData;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Vector3D;
import flash.utils.Dictionary;
import flash.utils.getTimer;

import kabam.rotmg.assets.services.CharacterFactory;
import kabam.rotmg.chat.model.ChatMessage;
import kabam.rotmg.constants.ActivationType;
import kabam.rotmg.constants.GeneralConstants;
import kabam.rotmg.constants.UseType;
import kabam.rotmg.core.StaticInjectorContext;
import kabam.rotmg.game.model.PotionInventoryModel;
import kabam.rotmg.game.signals.AddTextLineSignal;
import kabam.rotmg.game.view.components.QueuedStatusText;
import kabam.rotmg.stage3D.GraphicsFillExtra;
import kabam.rotmg.text.model.TextKey;
import kabam.rotmg.text.view.BitmapTextFactory;
import kabam.rotmg.text.view.stringBuilder.LineBuilder;
import kabam.rotmg.text.view.stringBuilder.StaticStringBuilder;
import kabam.rotmg.text.view.stringBuilder.StringBuilder;
import kabam.rotmg.ui.model.TabStripModel;

import org.swiftsuspenders.Injector;

public class Player extends Character {

    public static const MS_BETWEEN_TELEPORT:int = 10000;
    private static const MOVE_THRESHOLD:Number = 0.4;
    public static var isAdmin:Boolean = false;
    private static const NEARBY:Vector.<Point> = new <Point>[new Point(0, 0), new Point(1, 0), new Point(0, 1), new Point(1, 1)];
    private static var newP:Point = new Point();
    private static const RANK_OFFSET_MATRIX:Matrix = new Matrix(1, 0, 0, 1, 2, 2);
    private static const NAME_OFFSET_MATRIX:Matrix = new Matrix(1, 0, 0, 1, 20, 1);
    private static const MIN_MOVE_SPEED:Number = 0.004;
    private static const MAX_MOVE_SPEED:Number = 0.0096;
    private static const MIN_ATTACK_FREQ:Number = 0.0015;
    private static const MAX_ATTACK_FREQ:Number = 0.008;
    private static const MIN_ATTACK_MULT:Number = 0.5;
    private static const MAX_ATTACK_MULT:Number = 2;

    public var xpTimer:int;
    public var skinId:int;
    public var skin:AnimatedChar;
    public var isShooting:Boolean;
    public var accountId_:String = "";
    public var credits_:int = 0;
    public var tokens_:int = 0;
    public var numStars_:int = 0;
    public var fame_:int = 0;
    public var nameChosen_:Boolean = false;
    public var currFame_:int = 0;
    public var nextClassQuestFame_:int = -1;
    public var legendaryRank_:int = -1;
    public var guildName_:String = null;
    public var guildRank_:int = -1;
    public var isFellowGuild_:Boolean = false;
    public var breath_:int = -1;
    public var maxMP_:int = 200;
    public var mp_:Number = 0;
    public var nextLevelExp_:int = 1000;
    public var exp_:int = 0;
    public var attack_:int = 0;
    public var speed_:int = 0;
    public var dexterity_:int = 0;
    public var vitality_:int = 0;
    public var wisdom_:int = 0;
    public var maxHPBoost_:int = 0;
    public var maxMPBoost_:int = 0;
    public var attackBoost_:int = 0;
    public var defenseBoost_:int = 0;
    public var speedBoost_:int = 0;
    public var vitalityBoost_:int = 0;
    public var wisdomBoost_:int = 0;
    public var dexterityBoost_:int = 0;
    public var xpBoost_:int = 0;
    public var healthPotionCount_:int = 0;
    public var magicPotionCount_:int = 0;
    public var attackMax_:int = 0;
    public var defenseMax_:int = 0;
    public var speedMax_:int = 0;
    public var dexterityMax_:int = 0;
    public var vitalityMax_:int = 0;
    public var wisdomMax_:int = 0;
    public var maxHPMax_:int = 0;
    public var maxMPMax_:int = 0;
    public var hasBackpack_:Boolean = false;
    public var starred_:Boolean = false;
    public var ignored_:Boolean = false;
    public var distSqFromThisPlayer_:Number = 0;
    protected var rotate_:Number = 0;
    protected var relMoveVec_:Point = null;
    protected var moveMultiplier_:Number = 1;
    public var attackPeriod_:int = 0;
    public var nextAltAttack_:int = 0;
    public var nextTeleportAt_:int = 0;
    public var dropBoost:int = 0;
    public var tierBoost:int = 0;
    protected var healingEffect_:HealingEffect = null;
    protected var nearestMerchant_:Merchant = null;
    public var isDefaultAnimatedChar:Boolean = true;
    public var projectileIdSetOverrideNew:String = "";
    public var projectileIdSetOverrideOld:String = "";
    private var addTextLine:AddTextLineSignal;
    private var factory:CharacterFactory;
    private var ip_:IntPoint;
    private var breathBackFill_:GraphicsSolidFill = null;
    private var breathBackPath_:GraphicsPath = null;
    private var breathFill_:GraphicsSolidFill = null;
    private var breathPath_:GraphicsPath = null;

    public function Player(_arg_1:XML) {
        this.ip_ = new IntPoint();
        var _local_2:Injector = StaticInjectorContext.getInjector();
        this.addTextLine = _local_2.getInstance(AddTextLineSignal);
        this.factory = _local_2.getInstance(CharacterFactory);
        super(_arg_1);
        this.attackMax_ = int(_arg_1.Attack.@max);
        this.defenseMax_ = int(_arg_1.Defense.@max);
        this.speedMax_ = int(_arg_1.Speed.@max);
        this.dexterityMax_ = int(_arg_1.Dexterity.@max);
        this.vitalityMax_ = int(_arg_1.HpRegen.@max);
        this.wisdomMax_ = int(_arg_1.MpRegen.@max);
        this.maxHPMax_ = int(_arg_1.MaxHitPoints.@max);
        this.maxMPMax_ = int(_arg_1.MaxMagicPoints.@max);
        texturingCache_ = new Dictionary();
    }

    public static function fromPlayerXML(_arg_1:String, _arg_2:XML):Player {
        var _local_3:int = int(_arg_2.ObjectType);
        var _local_4:XML = ObjectLibrary.xmlLibrary_[_local_3];
        var _local_5:Player = new Player(_local_4);
        _local_5.name_ = _arg_1;
        _local_5.level_ = int(_arg_2.Level);
        _local_5.exp_ = int(_arg_2.Exp);
        _local_5.equipment_ = ConversionUtil.toIntVector(_arg_2.Equipment);
        _local_5.maxHP_ = int(_arg_2.MaxHitPoints);
        _local_5.hp_ = int(_arg_2.HitPoints);
        _local_5.maxMP_ = int(_arg_2.MaxMagicPoints);
        _local_5.mp_ = int(_arg_2.MagicPoints);
        _local_5.attack_ = int(_arg_2.Attack);
        _local_5.defense_ = int(_arg_2.Defense);
        _local_5.speed_ = int(_arg_2.Speed);
        _local_5.dexterity_ = int(_arg_2.Dexterity);
        _local_5.vitality_ = int(_arg_2.HpRegen);
        _local_5.wisdom_ = int(_arg_2.MpRegen);
        _local_5.tex1Id_ = int(_arg_2.Tex1);
        _local_5.tex2Id_ = int(_arg_2.Tex2);
        return (_local_5);
    }


    public function setRelativeMovement(_arg_1:Number, _arg_2:Number, _arg_3:Number):void {
        var _local_4:Number;
        if (this.relMoveVec_ == null) {
            this.relMoveVec_ = new Point();
        }
        this.rotate_ = _arg_1;
        this.relMoveVec_.x = _arg_2;
        this.relMoveVec_.y = _arg_3;
        if (isConfused()) {
            _local_4 = this.relMoveVec_.x;
            this.relMoveVec_.x = -(this.relMoveVec_.y);
            this.relMoveVec_.y = -(_local_4);
            this.rotate_ = -(this.rotate_);
        }
    }

    public function setCredits(_arg_1:int):void {
        this.credits_ = _arg_1;
    }

    public function setTokens(_arg_1:int):void {
        this.tokens_ = _arg_1;
    }

    public function setGuildName(_arg_1:String):void {
        var _local_3:GameObject;
        var _local_4:Player;
        var _local_5:Boolean;
        this.guildName_ = _arg_1;
        var _local_2:Player = map_.player_;
        if (_local_2 == this) {
            for each (_local_3 in map_.goDict_) {
                _local_4 = (_local_3 as Player);
                if (((!((_local_4 == null))) && (!((_local_4 == this))))) {
                    _local_4.setGuildName(_local_4.guildName_);
                }
            }
        }
        else {
            _local_5 = ((((((!((_local_2 == null))) && (!((_local_2.guildName_ == null))))) && (!((_local_2.guildName_ == ""))))) && ((_local_2.guildName_ == this.guildName_)));
            if (_local_5 != this.isFellowGuild_) {
                this.isFellowGuild_ = _local_5;
                nameBitmapData_ = null;
            }
        }
    }

    public function isTeleportEligible(_arg_1:Player):Boolean {
        return (!(((_arg_1.isPaused()) || (_arg_1.isInvisible()))));
    }

    public function msUtilTeleport():int {
        var _local_1:int = getTimer();
        return (Math.max(0, (this.nextTeleportAt_ - _local_1)));
    }

    public function teleportTo(_arg_1:Player):Boolean {
        if (isPaused()) {
            this.addTextLine.dispatch(this.makeErrorMessage(TextKey.PLAYER_NOTELEPORTWHILEPAUSED));
            return (false);
        }
        var _local_2:int = this.msUtilTeleport();
        if (_local_2 > 0) {
            this.addTextLine.dispatch(this.makeErrorMessage(TextKey.PLAYER_TELEPORT_COOLDOWN, {"seconds": int(((_local_2 / 1000) + 1))}));
            return (false);
        }
        if (!this.isTeleportEligible(_arg_1)) {
            if (_arg_1.isInvisible()) {
                this.addTextLine.dispatch(this.makeErrorMessage(TextKey.TELEPORT_INVISIBLE_PLAYER, {"player": _arg_1.name_}));
            }
            else {
                this.addTextLine.dispatch(this.makeErrorMessage(TextKey.PLAYER_TELEPORT_TO_PLAYER, {"player": _arg_1.name_}));
            }
            return (false);
        }
        map_.gs_.gsc_.teleport(_arg_1.objectId_);
        this.nextTeleportAt_ = (getTimer() + MS_BETWEEN_TELEPORT);
        return (true);
    }

    private function makeErrorMessage(_arg_1:String, _arg_2:Object = null):ChatMessage {
        return (ChatMessage.make(Parameters.ERROR_CHAT_NAME, _arg_1, -1, -1, "", false, _arg_2));
    }

    public function levelUpEffect(_arg_1:String, _arg_2:Boolean = true):void {
        if (_arg_2) {
            this.levelUpParticleEffect();
        }
        var _local_3:QueuedStatusText = new QueuedStatusText(this, new LineBuilder().setParams(_arg_1), 0xFF00, 2000);
        map_.mapOverlay_.addQueuedText(_local_3);
    }

    public function handleLevelUp(_arg_1:Boolean):void {
        SoundEffectLibrary.play("level_up");
        if (_arg_1) {
            this.levelUpEffect(TextKey.PLAYER_NEWCLASSUNLOCKED, false);
            this.levelUpEffect(TextKey.PLAYER_LEVELUP);
        }
        else {
            this.levelUpEffect(TextKey.PLAYER_LEVELUP);
        }
    }

    public function levelUpParticleEffect(_arg_1:uint = 0xFF00FF00):void {
        map_.addObj(new LevelUpEffect(this, _arg_1, 20), x_, y_);
    }

    public function handleExpUp(_arg_1:int):void {
        if (level_ == 20) {
            return;
        }
        var _local_2:CharacterStatusText = new CharacterStatusText(this, 0xFF00, 1000);
        _local_2.setStringBuilder(new LineBuilder().setParams(TextKey.PLAYER_EXP, {"exp": _arg_1}));
        map_.mapOverlay_.addStatusText(_local_2);
    }

    private function getNearbyMerchant():Merchant {
        var _local_3:Point;
        var _local_4:Merchant;
        var _local_1:int = ((((x_ - int(x_))) > 0.5) ? 1 : -1);
        var _local_2:int = ((((y_ - int(y_))) > 0.5) ? 1 : -1);
        for each (_local_3 in NEARBY) {
            this.ip_.x_ = (x_ + (_local_1 * _local_3.x));
            this.ip_.y_ = (y_ + (_local_2 * _local_3.y));
            _local_4 = map_.merchLookup_[this.ip_];
            if (_local_4 != null) {
                return ((((PointUtil.distanceSquaredXY(_local_4.x_, _local_4.y_, x_, y_) < 1)) ? _local_4 : null));
            }
        }
        return (null);
    }

    public function walkTo(_arg_1:Number, _arg_2:Number):Boolean {
        this.modifyMove(_arg_1, _arg_2, newP);
        return (this.moveTo(newP.x, newP.y));
    }

    override public function moveTo(_arg_1:Number, _arg_2:Number):Boolean {
        var _local_3:Boolean = super.moveTo(_arg_1, _arg_2);
        if (map_.gs_.evalIsNotInCombatMapArea()) {
            this.nearestMerchant_ = this.getNearbyMerchant();
        }
        return (_local_3);
    }

    public function modifyMove(_arg_1:Number, _arg_2:Number, _arg_3:Point):void {
        if (((isParalyzed()) || (isPetrified()))) {
            _arg_3.x = x_;
            _arg_3.y = y_;
            return;
        }
        var _local_4:Number = (_arg_1 - x_);
        var _local_5:Number = (_arg_2 - y_);
        if ((((((((_local_4 < MOVE_THRESHOLD)) && ((_local_4 > -(MOVE_THRESHOLD))))) && ((_local_5 < MOVE_THRESHOLD)))) && ((_local_5 > -(MOVE_THRESHOLD))))) {
            this.modifyStep(_arg_1, _arg_2, _arg_3);
            return;
        }
        var _local_6:Number = (MOVE_THRESHOLD / Math.max(Math.abs(_local_4), Math.abs(_local_5)));
        var _local_7:Number = 0;
        _arg_3.x = x_;
        _arg_3.y = y_;
        var _local_8:Boolean;
        while (!(_local_8)) {
            if ((_local_7 + _local_6) >= 1) {
                _local_6 = (1 - _local_7);
                _local_8 = true;
            }
            this.modifyStep((_arg_3.x + (_local_4 * _local_6)), (_arg_3.y + (_local_5 * _local_6)), _arg_3);
            _local_7 = (_local_7 + _local_6);
        }
    }

    public function modifyStep(_arg_1:Number, _arg_2:Number, _arg_3:Point):void {
        var _local_6:Number;
        var _local_7:Number;
        var _local_4:Boolean = ((((((x_ % 0.5) == 0)) && (!((_arg_1 == x_))))) || (!((int((x_ / 0.5)) == int((_arg_1 / 0.5))))));
        var _local_5:Boolean = ((((((y_ % 0.5) == 0)) && (!((_arg_2 == y_))))) || (!((int((y_ / 0.5)) == int((_arg_2 / 0.5))))));
        if (((((!(_local_4)) && (!(_local_5)))) || (this.isValidPosition(_arg_1, _arg_2)))) {
            _arg_3.x = _arg_1;
            _arg_3.y = _arg_2;
            return;
        }
        if (_local_4) {
            _local_6 = (((_arg_1) > x_) ? (int((_arg_1 * 2)) / 2) : (int((x_ * 2)) / 2));
            if (int(_local_6) > int(x_)) {
                _local_6 = (_local_6 - 0.01);
            }
        }
        if (_local_5) {
            _local_7 = (((_arg_2) > y_) ? (int((_arg_2 * 2)) / 2) : (int((y_ * 2)) / 2));
            if (int(_local_7) > int(y_)) {
                _local_7 = (_local_7 - 0.01);
            }
        }
        if (!_local_4) {
            _arg_3.x = _arg_1;
            _arg_3.y = _local_7;
            if (((!((square_ == null))) && (!((square_.props_.slideAmount_ == 0))))) {
                this.resetMoveVector(false);
            }
            return;
        }
        if (!_local_5) {
            _arg_3.x = _local_6;
            _arg_3.y = _arg_2;
            if (((!((square_ == null))) && (!((square_.props_.slideAmount_ == 0))))) {
                this.resetMoveVector(true);
            }
            return;
        }
        var _local_8:Number = (((_arg_1) > x_) ? (_arg_1 - _local_6) : (_local_6 - _arg_1));
        var _local_9:Number = (((_arg_2) > y_) ? (_arg_2 - _local_7) : (_local_7 - _arg_2));
        if (_local_8 > _local_9) {
            if (this.isValidPosition(_arg_1, _local_7)) {
                _arg_3.x = _arg_1;
                _arg_3.y = _local_7;
                return;
            }
            if (this.isValidPosition(_local_6, _arg_2)) {
                _arg_3.x = _local_6;
                _arg_3.y = _arg_2;
                return;
            }
        }
        else {
            if (this.isValidPosition(_local_6, _arg_2)) {
                _arg_3.x = _local_6;
                _arg_3.y = _arg_2;
                return;
            }
            if (this.isValidPosition(_arg_1, _local_7)) {
                _arg_3.x = _arg_1;
                _arg_3.y = _local_7;
                return;
            }
        }
        _arg_3.x = _local_6;
        _arg_3.y = _local_7;
    }

    private function resetMoveVector(_arg_1:Boolean):void {
        moveVec_.scaleBy(-0.5);
        if (_arg_1) {
            moveVec_.y = (moveVec_.y * -1);
        }
        else {
            moveVec_.x = (moveVec_.x * -1);
        }
    }

    public function isValidPosition(_arg_1:Number, _arg_2:Number):Boolean {
        var _local_3:Square = map_.getSquare(_arg_1, _arg_2);
        if (((!((square_ == _local_3))) && ((((_local_3 == null)) || (!(_local_3.isWalkable())))))) {
            return (false);
        }
        var _local_4:Number = (_arg_1 - int(_arg_1));
        var _local_5:Number = (_arg_2 - int(_arg_2));
        if (_local_4 < 0.5) {
            if (this.isFullOccupy((_arg_1 - 1), _arg_2)) {
                return (false);
            }
            if (_local_5 < 0.5) {
                if (((this.isFullOccupy(_arg_1, (_arg_2 - 1))) || (this.isFullOccupy((_arg_1 - 1), (_arg_2 - 1))))) {
                    return (false);
                }
            }
            else {
                if (_local_5 > 0.5) {
                    if (((this.isFullOccupy(_arg_1, (_arg_2 + 1))) || (this.isFullOccupy((_arg_1 - 1), (_arg_2 + 1))))) {
                        return (false);
                    }
                }
            }
        }
        else {
            if (_local_4 > 0.5) {
                if (this.isFullOccupy((_arg_1 + 1), _arg_2)) {
                    return (false);
                }
                if (_local_5 < 0.5) {
                    if (((this.isFullOccupy(_arg_1, (_arg_2 - 1))) || (this.isFullOccupy((_arg_1 + 1), (_arg_2 - 1))))) {
                        return (false);
                    }
                }
                else {
                    if (_local_5 > 0.5) {
                        if (((this.isFullOccupy(_arg_1, (_arg_2 + 1))) || (this.isFullOccupy((_arg_1 + 1), (_arg_2 + 1))))) {
                            return (false);
                        }
                    }
                }
            }
            else {
                if (_local_5 < 0.5) {
                    if (this.isFullOccupy(_arg_1, (_arg_2 - 1))) {
                        return (false);
                    }
                }
                else {
                    if (_local_5 > 0.5) {
                        if (this.isFullOccupy(_arg_1, (_arg_2 + 1))) {
                            return (false);
                        }
                    }
                }
            }
        }
        return (true);
    }

    public function isFullOccupy(_arg_1:Number, _arg_2:Number):Boolean {
        var _local_3:Square = map_.lookupSquare(_arg_1, _arg_2);
        return ((((((_local_3 == null)) || ((_local_3.tileType_ == 0xFF)))) || (((!((_local_3.obj_ == null))) && (_local_3.obj_.props_.fullOccupy_)))));
    }

    override public function update(_arg_1:int, _arg_2:int):Boolean {
        var _local_3:Number;
        var _local_4:Number;
        var _local_5:Number;
        var _local_6:Vector3D;
        var _local_7:Number;
        var _local_8:int;
        var _local_9:Vector.<uint>;
        if (((this.tierBoost) && (!(isPaused())))) {
            this.tierBoost = (this.tierBoost - _arg_2);
            if (this.tierBoost < 0) {
                this.tierBoost = 0;
            }
        }
        if (((this.dropBoost) && (!(isPaused())))) {
            this.dropBoost = (this.dropBoost - _arg_2);
            if (this.dropBoost < 0) {
                this.dropBoost = 0;
            }
        }
        if (((this.xpTimer) && (!(isPaused())))) {
            this.xpTimer = (this.xpTimer - _arg_2);
            if (this.xpTimer < 0) {
                this.xpTimer = 0;
            }
        }
        if (((isHealing()) && (!(isPaused())))) {
            if (this.healingEffect_ == null) {
                this.healingEffect_ = new HealingEffect(this);
                map_.addObj(this.healingEffect_, x_, y_);
            }
        }
        else {
            if (this.healingEffect_ != null) {
                map_.removeObj(this.healingEffect_.objectId_);
                this.healingEffect_ = null;
            }
        }
        if ((((map_.player_ == this)) && (isPaused()))) {
            return (true);
        }
        if (this.relMoveVec_ != null) {
            _local_3 = Parameters.data_.cameraAngle;
            if (this.rotate_ != 0) {
                _local_3 = (_local_3 + ((_arg_2 * Parameters.PLAYER_ROTATE_SPEED) * this.rotate_));
                Parameters.data_.cameraAngle = _local_3;
            }
            if (((!((this.relMoveVec_.x == 0))) || (!((this.relMoveVec_.y == 0))))) {
                _local_4 = this.getMoveSpeed();
                _local_5 = Math.atan2(this.relMoveVec_.y, this.relMoveVec_.x);
                if (square_.props_.slideAmount_ > 0) {
                    _local_6 = new Vector3D();
                    _local_6.x = (_local_4 * Math.cos((_local_3 + _local_5)));
                    _local_6.y = (_local_4 * Math.sin((_local_3 + _local_5)));
                    _local_6.z = 0;
                    _local_7 = _local_6.length;
                    _local_6.scaleBy((-1 * (square_.props_.slideAmount_ - 1)));
                    moveVec_.scaleBy(square_.props_.slideAmount_);
                    if (moveVec_.length < _local_7) {
                        moveVec_ = moveVec_.add(_local_6);
                    }
                }
                else {
                    moveVec_.x = (_local_4 * Math.cos((_local_3 + _local_5)));
                    moveVec_.y = (_local_4 * Math.sin((_local_3 + _local_5)));
                }
            }
            else {
                if ((((moveVec_.length > 0.00012)) && ((square_.props_.slideAmount_ > 0)))) {
                    moveVec_.scaleBy(square_.props_.slideAmount_);
                }
                else {
                    moveVec_.x = 0;
                    moveVec_.y = 0;
                }
            }
            if (((!((square_ == null))) && (square_.props_.push_))) {
                moveVec_.x = (moveVec_.x - (square_.props_.animate_.dx_ / 1000));
                moveVec_.y = (moveVec_.y - (square_.props_.animate_.dy_ / 1000));
            }
            this.walkTo((x_ + (_arg_2 * moveVec_.x)), (y_ + (_arg_2 * moveVec_.y)));
        }
        else {
            if (!super.update(_arg_1, _arg_2)) {
                return (false);
            }
        }
        if ((((((((((map_.player_ == this)) && ((square_.props_.maxDamage_ > 0)))) && (((square_.lastDamage_ + 500) < _arg_1)))) && (!(isInvincible())))) && ((((square_.obj_ == null)) || (!(square_.obj_.props_.protectFromGroundDamage_)))))) {
            _local_8 = map_.gs_.gsc_.getNextDamage(square_.props_.minDamage_, square_.props_.maxDamage_);
            _local_9 = new Vector.<uint>();
            _local_9.push(ConditionEffect.GROUND_DAMAGE);
            damage(-1, _local_8, _local_9, (hp_ <= _local_8), null);
            map_.gs_.gsc_.groundDamage(_arg_1, x_, y_);
            square_.lastDamage_ = _arg_1;
        }
        return (true);
    }

    public function onMove():void {
        if (map_ == null) {
            return;
        }
        var _local_1:Square = map_.getSquare(x_, y_);
        if (_local_1.props_.sinking_) {
            sinkLevel_ = Math.min((sinkLevel_ + 1), Parameters.MAX_SINK_LEVEL);
            this.moveMultiplier_ = (0.1 + ((1 - (sinkLevel_ / Parameters.MAX_SINK_LEVEL)) * (_local_1.props_.speed_ - 0.1)));
        }
        else {
            sinkLevel_ = 0;
            this.moveMultiplier_ = _local_1.props_.speed_;
        }
    }

    override protected function makeNameBitmapData():BitmapData {
        var _local_1:StringBuilder = new StaticStringBuilder(name_);
        var _local_2:BitmapTextFactory = StaticInjectorContext.getInjector().getInstance(BitmapTextFactory);
        var _local_3:BitmapData = _local_2.make(_local_1, 16, this.getNameColor(), true, NAME_OFFSET_MATRIX, true);
        _local_3.draw(FameUtil.numStarsToIcon(this.numStars_), RANK_OFFSET_MATRIX);
        return (_local_3);
    }

    private function getNameColor():uint {
        if (this.isFellowGuild_) {
            return (Parameters.FELLOW_GUILD_COLOR);
        }
        if (this.nameChosen_) {
            return (Parameters.NAME_CHOSEN_COLOR);
        }
        return (0xFFFFFF);
    }

    protected function drawBreathBar(_arg_1:Vector.<IGraphicsData>, _arg_2:int):void {
        var _local_7:Number;
        var _local_8:Number;
        if (this.breathPath_ == null) {
            this.breathBackFill_ = new GraphicsSolidFill();
            this.breathBackPath_ = new GraphicsPath(GraphicsUtil.QUAD_COMMANDS, new Vector.<Number>());
            this.breathFill_ = new GraphicsSolidFill(2542335);
            this.breathPath_ = new GraphicsPath(GraphicsUtil.QUAD_COMMANDS, new Vector.<Number>());
        }
        if (this.breath_ <= Parameters.BREATH_THRESH) {
            _local_7 = ((Parameters.BREATH_THRESH - this.breath_) / Parameters.BREATH_THRESH);
            this.breathBackFill_.color = MoreColorUtil.lerpColor(0x545454, 0xFF0000, (Math.abs(Math.sin((_arg_2 / 300))) * _local_7));
        }
        else {
            this.breathBackFill_.color = 0x545454;
        }
        var _local_3:int = 20;
        var _local_4:int = 8;
        var _local_5:int = 6;
        var _local_6:Vector.<Number> = (this.breathBackPath_.data as Vector.<Number>);
        _local_6.length = 0;
        _local_6.push((posS_[0] - _local_3), (posS_[1] + _local_4), (posS_[0] + _local_3), (posS_[1] + _local_4), (posS_[0] + _local_3), ((posS_[1] + _local_4) + _local_5), (posS_[0] - _local_3), ((posS_[1] + _local_4) + _local_5));
        _arg_1.push(this.breathBackFill_);
        _arg_1.push(this.breathBackPath_);
        _arg_1.push(GraphicsUtil.END_FILL);
        if (this.breath_ > 0) {
            _local_8 = (((this.breath_ / 100) * 2) * _local_3);
            this.breathPath_.data.length = 0;
            _local_6 = (this.breathPath_.data as Vector.<Number>);
            _local_6.length = 0;
            _local_6.push((posS_[0] - _local_3), (posS_[1] + _local_4), ((posS_[0] - _local_3) + _local_8), (posS_[1] + _local_4), ((posS_[0] - _local_3) + _local_8), ((posS_[1] + _local_4) + _local_5), (posS_[0] - _local_3), ((posS_[1] + _local_4) + _local_5));
            _arg_1.push(this.breathFill_);
            _arg_1.push(this.breathPath_);
            _arg_1.push(GraphicsUtil.END_FILL);
        }
        GraphicsFillExtra.setSoftwareDrawSolid(this.breathFill_, true);
        GraphicsFillExtra.setSoftwareDrawSolid(this.breathBackFill_, true);
    }

    override public function draw(_arg_1:Vector.<IGraphicsData>, _arg_2:Camera, _arg_3:int):void {
        super.draw(_arg_1, _arg_2, _arg_3);
        if (this != map_.player_) {
            if (!Parameters.screenShotMode_) {
                drawName(_arg_1, _arg_2);
            }
        }
        else {
            if (this.breath_ >= 0) {
                this.drawBreathBar(_arg_1, _arg_3);
            }
        }
    }

    private function getMoveSpeed():Number {
        if (isSlowed()) {
            return ((MIN_MOVE_SPEED * this.moveMultiplier_));
        }
        var _local_1:Number = (MIN_MOVE_SPEED + ((this.speed_ / 75) * (MAX_MOVE_SPEED - MIN_MOVE_SPEED)));
        if (((isSpeedy()) || (isNinjaSpeedy()))) {
            _local_1 = (_local_1 * 1.5);
        }
        return ((_local_1 * this.moveMultiplier_));
    }

    public function attackFrequency():Number {
        if (isDazed()) {
            return (MIN_ATTACK_FREQ);
        }
        var _local_1:Number = (MIN_ATTACK_FREQ + ((this.dexterity_ / 75) * (MAX_ATTACK_FREQ - MIN_ATTACK_FREQ)));
        if (isBerserk()) {
            _local_1 = (_local_1 * 1.5);
        }
        return (_local_1);
    }

    private function attackMultiplier():Number {
        if (isWeak()) {
            return (MIN_ATTACK_MULT);
        }
        var _local_1:Number = (MIN_ATTACK_MULT + ((this.attack_ / 75) * (MAX_ATTACK_MULT - MIN_ATTACK_MULT)));
        if (isDamaging()) {
            _local_1 = (_local_1 * 1.5);
        }
        return (_local_1);
    }

    private function makeSkinTexture():void {
        var _local_1:MaskedImage = this.skin.imageFromAngle(0, AnimatedChar.STAND, 0);
        animatedChar_ = this.skin;
        texture_ = _local_1.image_;
        mask_ = _local_1.mask_;
        this.isDefaultAnimatedChar = true;
    }

    private function setToRandomAnimatedCharacter():void {
        var _local_1:Vector.<XML> = ObjectLibrary.hexTransforms_;
        var _local_2:uint = Math.floor((Math.random() * _local_1.length));
        var _local_3:int = int(_local_1[_local_2].@type);
        var _local_4:TextureData = ObjectLibrary.typeToTextureData_[_local_3];
        texture_ = _local_4.texture_;
        mask_ = _local_4.mask_;
        animatedChar_ = _local_4.animatedChar_;
        this.isDefaultAnimatedChar = false;
    }

    override protected function getTexture(_arg_1:Camera, _arg_2:int):BitmapData {
        var _local_5:MaskedImage;
        var _local_10:int;
        var _local_11:Dictionary;
        var _local_12:Number;
        var _local_13:int;
        var _local_14:ColorTransform;
        var _local_3:Number = 0;
        var _local_4:int = AnimatedChar.STAND;
        if (((this.isShooting) || ((_arg_2 < (attackStart_ + this.attackPeriod_))))) {
            facing_ = attackAngle_;
            _local_3 = (((_arg_2 - attackStart_) % this.attackPeriod_) / this.attackPeriod_);
            _local_4 = AnimatedChar.ATTACK;
        }
        else {
            if (((!((moveVec_.x == 0))) || (!((moveVec_.y == 0))))) {
                _local_10 = (3.5 / this.getMoveSpeed());
                if (((!((moveVec_.y == 0))) || (!((moveVec_.x == 0))))) {
                    facing_ = Math.atan2(moveVec_.y, moveVec_.x);
                }
                _local_3 = ((_arg_2 % _local_10) / _local_10);
                _local_4 = AnimatedChar.WALK;
            }
        }
        if (this.isHexed()) {
            ((this.isDefaultAnimatedChar) && (this.setToRandomAnimatedCharacter()));
        }
        else {
            if (!this.isDefaultAnimatedChar) {
                this.makeSkinTexture();
            }
        }
        if (_arg_1.isHallucinating_) {
            _local_5 = new MaskedImage(getHallucinatingTexture(), null);
        }
        else {
            _local_5 = animatedChar_.imageFromFacing(facing_, _arg_1, _local_4, _local_3);
        }
        var _local_6:int = tex1Id_;
        var _local_7:int = tex2Id_;
        var _local_8:BitmapData;
        if (this.nearestMerchant_) {
            _local_11 = texturingCache_[this.nearestMerchant_];
            if (_local_11 == null) {
                texturingCache_[this.nearestMerchant_] = new Dictionary();
            }
            else {
                _local_8 = _local_11[_local_5];
            }
            _local_6 = this.nearestMerchant_.getTex1Id(tex1Id_);
            _local_7 = this.nearestMerchant_.getTex2Id(tex2Id_);
        }
        else {
            _local_8 = texturingCache_[_local_5];
        }
        if (_local_8 == null) {
            _local_8 = TextureRedrawer.resize(_local_5.image_, _local_5.mask_, size_, false, _local_6, _local_7);
            if (this.nearestMerchant_ != null) {
                texturingCache_[this.nearestMerchant_][_local_5] = _local_8;
            }
            else {
                texturingCache_[_local_5] = _local_8;
            }
        }
        if (hp_ < (maxHP_ * 0.2)) {
            _local_12 = (int((Math.abs(Math.sin((_arg_2 / 200))) * 10)) / 10);
            _local_13 = 128;
            _local_14 = new ColorTransform(1, 1, 1, 1, (_local_12 * _local_13), (-(_local_12) * _local_13), (-(_local_12) * _local_13));
            _local_8 = CachingColorTransformer.transformBitmapData(_local_8, _local_14);
        }
        var _local_9:BitmapData = texturingCache_[_local_8];
        if (_local_9 == null) {
            _local_9 = GlowRedrawer.outlineGlow(_local_8, (((this.legendaryRank_ == -1)) ? 0 : 0xFF0000));
            texturingCache_[_local_8] = _local_9;
        }
        if (((((isPaused()) || (isStasis()))) || (isPetrified()))) {
            _local_9 = CachingColorTransformer.filterBitmapData(_local_9, PAUSED_FILTER);
        }
        else {
            if (isInvisible()) {
                _local_9 = CachingColorTransformer.alphaBitmapData(_local_9, 0.4);
            }
        }
        return (_local_9);
    }

    override public function getPortrait():BitmapData {
        var _local_1:MaskedImage;
        var _local_2:int;
        if (portrait_ == null) {
            _local_1 = animatedChar_.imageFromDir(AnimatedChar.RIGHT, AnimatedChar.STAND, 0);
            _local_2 = ((4 / _local_1.image_.width) * 100);
            portrait_ = TextureRedrawer.resize(_local_1.image_, _local_1.mask_, _local_2, true, tex1Id_, tex2Id_);
            portrait_ = GlowRedrawer.outlineGlow(portrait_, 0);
        }
        return (portrait_);
    }

    public function useAltWeapon(_arg_1:Number, _arg_2:Number, _arg_3:int):Boolean {
        var _local_7:XML;
        var _local_8:int;
        var _local_9:Number;
        var _local_10:int;
        var _local_11:int;
        if ((((map_ == null)) || (isPaused()))) {
            return (false);
        }
        var _local_4:int = equipment_[1];
        if (_local_4 == -1) {
            return (false);
        }
        var _local_5:XML = ObjectLibrary.xmlLibrary_[_local_4];
        if ((((_local_5 == null)) || (!(_local_5.hasOwnProperty("Usable"))))) {
            return (false);
        }
        var _local_6:Point = map_.pSTopW(_arg_1, _arg_2);
        if (_local_6 == null) {
            SoundEffectLibrary.play("error");
            return (false);
        }
        for each (_local_7 in _local_5.Activate) {
            if (_local_7.toString() == ActivationType.TELEPORT) {
                if (!this.isValidPosition(_local_6.x, _local_6.y)) {
                    SoundEffectLibrary.play("error");
                    return (false);
                }
            }
        }
        _local_8 = getTimer();
        if (_arg_3 == UseType.START_USE) {
            if (_local_8 < this.nextAltAttack_) {
                SoundEffectLibrary.play("error");
                return (false);
            }
            _local_10 = int(_local_5.MpCost);
            if (_local_10 > this.mp_) {
                SoundEffectLibrary.play("no_mana");
                return (false);
            }
            _local_11 = 500;
            if (_local_5.hasOwnProperty("Cooldown")) {
                _local_11 = (Number(_local_5.Cooldown) * 1000);
            }
            this.nextAltAttack_ = (_local_8 + _local_11);
            map_.gs_.gsc_.useItem(_local_8, objectId_, 1, _local_4, _local_6.x, _local_6.y, _arg_3);
            if (_local_5.Activate == ActivationType.SHOOT) {
                _local_9 = Math.atan2(_arg_2, _arg_1);
                this.doShoot(_local_8, _local_4, _local_5, (Parameters.data_.cameraAngle + _local_9), false);
            }
        }
        else {
            if (_local_5.hasOwnProperty("MultiPhase")) {
                map_.gs_.gsc_.useItem(_local_8, objectId_, 1, _local_4, _local_6.x, _local_6.y, _arg_3);
                _local_10 = int(_local_5.MpEndCost);
                if (_local_10 <= this.mp_) {
                    _local_9 = Math.atan2(_arg_2, _arg_1);
                    this.doShoot(_local_8, _local_4, _local_5, (Parameters.data_.cameraAngle + _local_9), false);
                }
            }
        }
        return (true);
    }

    public function attemptAttackAngle(_arg_1:Number):void {
        this.shoot((Parameters.data_.cameraAngle + _arg_1));
    }

    override public function setAttack(_arg_1:int, _arg_2:Number):void {
        var _local_3:XML = ObjectLibrary.xmlLibrary_[_arg_1];
        if ((((_local_3 == null)) || (!(_local_3.hasOwnProperty("RateOfFire"))))) {
            return;
        }
        var _local_4:Number = Number(_local_3.RateOfFire);
        this.attackPeriod_ = ((1 / this.attackFrequency()) * (1 / _local_4));
        super.setAttack(_arg_1, _arg_2);
    }

    private function shoot(_arg_1:Number):void {
        if ((((((((map_ == null)) || (isStunned()))) || (isPaused()))) || (isPetrified()))) {
            return;
        }
        var _local_2:int = equipment_[0];
        if (_local_2 == -1) {
            this.addTextLine.dispatch(ChatMessage.make(Parameters.ERROR_CHAT_NAME, TextKey.PLAYER_NO_WEAPON_EQUIPPED));
            return;
        }
        var _local_3:XML = ObjectLibrary.xmlLibrary_[_local_2];
        var _local_4:int = getTimer();
        var _local_5:Number = Number(_local_3.RateOfFire);
        this.attackPeriod_ = ((1 / this.attackFrequency()) * (1 / _local_5));
        if (_local_4 < (attackStart_ + this.attackPeriod_)) {
            return;
        }
        doneAction(map_.gs_, Tutorial.ATTACK_ACTION);
        attackAngle_ = _arg_1;
        attackStart_ = _local_4;
        this.doShoot(attackStart_, _local_2, _local_3, attackAngle_, true);
    }

    private function doShoot(_arg_1:int, _arg_2:int, _arg_3:XML, _arg_4:Number, _arg_5:Boolean):void {
        var _local_11:uint;
        var _local_12:Projectile;
        var _local_13:int;
        var _local_14:int;
        var _local_15:Number;
        var _local_16:int;
        var _local_6:int = ((_arg_3.hasOwnProperty("NumProjectiles")) ? int(_arg_3.NumProjectiles) : 1);
        var _local_7:Number = (((_arg_3.hasOwnProperty("ArcGap")) ? Number(_arg_3.ArcGap) : 11.25) * Trig.toRadians);
        var _local_8:Number = (_local_7 * (_local_6 - 1));
        var _local_9:Number = (_arg_4 - (_local_8 / 2));
        this.isShooting = _arg_5;
        var _local_10:int;
        while (_local_10 < _local_6) {
            _local_11 = getBulletId();
            _local_12 = (FreeList.newObject(Projectile) as Projectile);
            if (((_arg_5) && (!((this.projectileIdSetOverrideNew == ""))))) {
                _local_12.reset(_arg_2, 0, objectId_, _local_11, _local_9, _arg_1, this.projectileIdSetOverrideNew, this.projectileIdSetOverrideOld);
            }
            else {
                _local_12.reset(_arg_2, 0, objectId_, _local_11, _local_9, _arg_1);
            }
            _local_13 = int(_local_12.projProps_.minDamage_);
            _local_14 = int(_local_12.projProps_.maxDamage_);
            _local_15 = ((_arg_5) ? this.attackMultiplier() : 1);
            _local_16 = (map_.gs_.gsc_.getNextDamage(_local_13, _local_14) * _local_15);
            if (_arg_1 > (map_.gs_.moveRecords_.lastClearTime_ + 600)) {
                _local_16 = 0;
            }
            _local_12.setDamage(_local_16);
            if ((((_local_10 == 0)) && (!((_local_12.sound_ == null))))) {
                SoundEffectLibrary.play(_local_12.sound_, 0.75, false);
            }
            map_.addObj(_local_12, (x_ + (Math.cos(_arg_4) * 0.3)), (y_ + (Math.sin(_arg_4) * 0.3)));
            map_.gs_.gsc_.playerShoot(_arg_1, _local_12);
            _local_9 = (_local_9 + _local_7);
            _local_10++;
        }
    }

    public function isHexed():Boolean {
        return (!(((condition_[ConditionEffect.CE_FIRST_BATCH] & ConditionEffect.HEXED_BIT) == 0)));
    }

    public function isInventoryFull():Boolean {
        var _local_1:int = equipment_.length;
        var _local_2:uint = 4;
        while (_local_2 < _local_1) {
            if (equipment_[_local_2] <= 0) {
                return (false);
            }
            _local_2++;
        }
        return (true);
    }

    public function nextAvailableInventorySlot():int {
        var _local_1:int = ((this.hasBackpack_) ? equipment_.length : (equipment_.length - GeneralConstants.NUM_INVENTORY_SLOTS));
        var _local_2:uint = 4;
        while (_local_2 < _local_1) {
            if (equipment_[_local_2] <= 0) {
                return (_local_2);
            }
            _local_2++;
        }
        return (-1);
    }

    public function numberOfAvailableSlots():int {
        var _local_1:int = ((this.hasBackpack_) ? equipment_.length : (equipment_.length - GeneralConstants.NUM_INVENTORY_SLOTS));
        var _local_2:int;
        var _local_3:uint = 4;
        while (_local_3 < _local_1) {
            if (equipment_[_local_3] <= 0) {
                _local_2++;
            }
            _local_3++;
        }
        return (_local_2);
    }

    public function swapInventoryIndex(_arg_1:String):int {
        var _local_2:int;
        var _local_3:int;
        if (!this.hasBackpack_) {
            return (-1);
        }
        if (_arg_1 == TabStripModel.BACKPACK) {
            _local_2 = GeneralConstants.NUM_EQUIPMENT_SLOTS;
            _local_3 = (GeneralConstants.NUM_EQUIPMENT_SLOTS + GeneralConstants.NUM_INVENTORY_SLOTS);
        }
        else {
            _local_2 = (GeneralConstants.NUM_EQUIPMENT_SLOTS + GeneralConstants.NUM_INVENTORY_SLOTS);
            _local_3 = equipment_.length;
        }
        var _local_4:uint = _local_2;
        while (_local_4 < _local_3) {
            if (equipment_[_local_4] <= 0) {
                return (_local_4);
            }
            _local_4++;
        }
        return (-1);
    }

    public function getPotionCount(_arg_1:int):int {
        switch (_arg_1) {
            case PotionInventoryModel.HEALTH_POTION_ID:
                return (this.healthPotionCount_);
            case PotionInventoryModel.MAGIC_POTION_ID:
                return (this.magicPotionCount_);
        }
        return (0);
    }

    public function getTex1():int {
        return (tex1Id_);
    }

    public function getTex2():int {
        return (tex2Id_);
    }


}
}//package com.company.assembleegameclient.objects
