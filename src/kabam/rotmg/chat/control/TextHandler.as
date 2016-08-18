package kabam.rotmg.chat.control {
import com.company.assembleegameclient.objects.GameObject;
import com.company.assembleegameclient.objects.TextureDataConcrete;
import com.company.assembleegameclient.parameters.Parameters;

import kabam.rotmg.account.core.Account;
import kabam.rotmg.account.core.view.ConfirmEmailModal;
import kabam.rotmg.chat.model.ChatMessage;
import kabam.rotmg.chat.model.TellModel;
import kabam.rotmg.chat.view.ChatListItemFactory;
import kabam.rotmg.core.StaticInjectorContext;
import kabam.rotmg.dialogs.control.OpenDialogSignal;
import kabam.rotmg.fortune.services.FortuneModel;
import kabam.rotmg.friends.model.FriendModel;
import kabam.rotmg.game.model.AddSpeechBalloonVO;
import kabam.rotmg.game.model.GameModel;
import kabam.rotmg.game.signals.AddSpeechBalloonSignal;
import kabam.rotmg.game.signals.AddTextLineSignal;
import kabam.rotmg.language.model.StringMap;
import kabam.rotmg.messaging.impl.incoming.Text;
import kabam.rotmg.news.view.NewsTicker;
import kabam.rotmg.servers.api.ServerModel;
import kabam.rotmg.text.view.stringBuilder.LineBuilder;
import kabam.rotmg.ui.model.HUDModel;

public class TextHandler {

    private const NORMAL_SPEECH_COLORS:TextColors = new TextColors(14802908, 0xFFFFFF, 0x545454);
    private const ENEMY_SPEECH_COLORS:TextColors = new TextColors(5644060, 16549442, 13484223);
    private const TELL_SPEECH_COLORS:TextColors = new TextColors(2493110, 61695, 13880567);
    private const GUILD_SPEECH_COLORS:TextColors = new TextColors(0x3E8A00, 10944349, 13891532);

    [Inject]
    public var account:Account;
    [Inject]
    public var model:GameModel;
    [Inject]
    public var addTextLine:AddTextLineSignal;
    [Inject]
    public var addSpeechBalloon:AddSpeechBalloonSignal;
    [Inject]
    public var stringMap:StringMap;
    [Inject]
    public var tellModel:TellModel;
    [Inject]
    public var spamFilter:SpamFilter;
    [Inject]
    public var openDialogSignal:OpenDialogSignal;
    [Inject]
    public var hudModel:HUDModel;
    [Inject]
    public var friendModel:FriendModel;


    public function execute(_arg_1:Text):void {
        var _local_3:String;
        var _local_4:String;
        var _local_5:String;
        var _local_2:Boolean = (((_arg_1.numStars_ == -1)) || ((_arg_1.objectId_ == -1)));
        if ((((((((_arg_1.numStars_ < Parameters.data_.chatStarRequirement)) && (!((_arg_1.name_ == this.model.player.name_))))) && (!(_local_2)))) && (!(this.isSpecialRecipientChat(_arg_1.recipient_))))) {
            return;
        }
        if (((((!((_arg_1.recipient_ == ""))) && (Parameters.data_.chatFriend))) && (!(this.friendModel.isMyFriend(_arg_1.recipient_))))) {
            return;
        }
        if (((((((!(Parameters.data_.chatAll)) && (!((_arg_1.name_ == this.model.player.name_))))) && (!(_local_2)))) && (!(this.isSpecialRecipientChat(_arg_1.recipient_))))) {
            if (!(((_arg_1.recipient_ == Parameters.GUILD_CHAT_NAME)) && (Parameters.data_.chatGuild))) {
                if (!((!((_arg_1.recipient_ == ""))) && (Parameters.data_.chatWhisper))) {
                    return;
                }
            }
        }
        if (this.useCleanString(_arg_1)) {
            _local_3 = _arg_1.cleanText_;
            _arg_1.cleanText_ = this.replaceIfSlashServerCommand(_arg_1.cleanText_);
        }
        else {
            _local_3 = _arg_1.text_;
            _arg_1.text_ = this.replaceIfSlashServerCommand(_arg_1.text_);
        }
        if (((_local_2) && (this.isToBeLocalized(_local_3)))) {
            _local_3 = this.getLocalizedString(_local_3);
        }
        if (((!(_local_2)) && (this.spamFilter.isSpam(_local_3)))) {
            if (_arg_1.name_ == this.model.player.name_) {
                this.addTextLine.dispatch(ChatMessage.make(Parameters.ERROR_CHAT_NAME, "This message has been flagged as spam."));
            }
            return;
        }
        if (_arg_1.recipient_) {
            if (((!((_arg_1.recipient_ == this.model.player.name_))) && (!(this.isSpecialRecipientChat(_arg_1.recipient_))))) {
                this.tellModel.push(_arg_1.recipient_);
                this.tellModel.resetRecipients();
            }
            else {
                if (_arg_1.recipient_ == this.model.player.name_) {
                    this.tellModel.push(_arg_1.name_);
                    this.tellModel.resetRecipients();
                }
            }
        }
        if (((_local_2) && ((TextureDataConcrete.remoteTexturesUsed == true)))) {
            TextureDataConcrete.remoteTexturesUsed = false;
            _local_4 = _arg_1.name_;
            _local_5 = _arg_1.text_;
            _arg_1.name_ = "";
            _arg_1.text_ = "Remote Textures used in this build";
            this.addTextAsTextLine(_arg_1);
            _arg_1.name_ = _local_4;
            _arg_1.text_ = _local_5;
        }
        if (_local_2) {
            if ((((((((_arg_1.text_ == "Please verify your email before chat")) && (!((this.hudModel == null))))) && ((this.hudModel.gameSprite.map.name_ == "Nexus")))) && (!((this.openDialogSignal == null))))) {
                this.openDialogSignal.dispatch(new ConfirmEmailModal());
            }
            else {
                if (_arg_1.name_ == "@ANNOUNCEMENT") {
                    if (((((!((this.hudModel == null))) && (!((this.hudModel.gameSprite == null))))) && (!((this.hudModel.gameSprite.newsTicker == null))))) {
                        this.hudModel.gameSprite.newsTicker.activateNewScrollText(_arg_1.text_);
                    }
                    else {
                        NewsTicker.setPendingScrollText(_arg_1.text_);
                    }
                }
                else {
                    if ((((_arg_1.name_ == "#{objects.ft_shopkeep}")) && (!(FortuneModel.HAS_FORTUNES)))) {
                        return;
                    }
                }
            }
        }
        if (_arg_1.objectId_ >= 0) {
            this.showSpeechBaloon(_arg_1, _local_3);
        }
        if (((_local_2) || (((this.account.isRegistered()) && (((!(Parameters.data_["hidePlayerChat"])) || (this.isSpecialRecipientChat(_arg_1.name_)))))))) {
            this.addTextAsTextLine(_arg_1);
        }
    }

    private function isSpecialRecipientChat(_arg_1:String):Boolean {
        return ((((_arg_1.length > 0)) && ((((_arg_1.charAt(0) == "#")) || ((_arg_1.charAt(0) == "*"))))));
    }

    public function addTextAsTextLine(_arg_1:Text):void {
        var _local_2:ChatMessage = new ChatMessage();
        _local_2.name = _arg_1.name_;
        _local_2.objectId = _arg_1.objectId_;
        _local_2.numStars = _arg_1.numStars_;
        _local_2.recipient = _arg_1.recipient_;
        _local_2.isWhisper = ((_arg_1.recipient_) && (!(this.isSpecialRecipientChat(_arg_1.recipient_))));
        _local_2.isToMe = (_arg_1.recipient_ == this.model.player.name_);
        this.addMessageText(_arg_1, _local_2);
        this.addTextLine.dispatch(_local_2);
    }

    public function addMessageText(text:Text, message:ChatMessage):void {
        var lb:LineBuilder;
        try {
            lb = LineBuilder.fromJSON(text.text_);
            message.text = lb.key;
            message.tokens = lb.tokens;
        }
        catch (error:Error) {
            message.text = ((useCleanString(text)) ? text.cleanText_ : text.text_);
        }
    }

    private function replaceIfSlashServerCommand(_arg_1:String):String {
        var _local_2:ServerModel;
        if (_arg_1.substr(0, 7) == "74026S9") {
            _local_2 = StaticInjectorContext.getInjector().getInstance(ServerModel);
            if (((_local_2) && (_local_2.getServer()))) {
                return (_arg_1.replace("74026S9", (_local_2.getServer().name + ", ")));
            }
        }
        return (_arg_1);
    }

    private function isToBeLocalized(_arg_1:String):Boolean {
        return ((((_arg_1.charAt(0) == "{")) && ((_arg_1.charAt((_arg_1.length - 1)) == "}"))));
    }

    private function getLocalizedString(_arg_1:String):String {
        var _local_2:LineBuilder = LineBuilder.fromJSON(_arg_1);
        _local_2.setStringMap(this.stringMap);
        return (_local_2.getString());
    }

    private function showSpeechBaloon(_arg_1:Text, _arg_2:String):void {
        var _local_4:TextColors;
        var _local_5:Boolean;
        var _local_6:Boolean;
        var _local_7:AddSpeechBalloonVO;
        var _local_3:GameObject = this.model.getGameObject(_arg_1.objectId_);
        if (_local_3 != null) {
            _local_4 = this.getColors(_arg_1, _local_3);
            _local_5 = ChatListItemFactory.isTradeMessage(_arg_1.numStars_, _arg_1.objectId_, _arg_2);
            _local_6 = ChatListItemFactory.isGuildMessage(_arg_1.name_);
            _local_7 = new AddSpeechBalloonVO(_local_3, _arg_2, _arg_1.name_, _local_5, _local_6, _local_4.back, 1, _local_4.outline, 1, _local_4.text, _arg_1.bubbleTime_, false, true);
            this.addSpeechBalloon.dispatch(_local_7);
        }
    }

    private function getColors(_arg_1:Text, _arg_2:GameObject):TextColors {
        if (_arg_2.props_.isEnemy_) {
            return (this.ENEMY_SPEECH_COLORS);
        }
        if (_arg_1.recipient_ == Parameters.GUILD_CHAT_NAME) {
            return (this.GUILD_SPEECH_COLORS);
        }
        if (_arg_1.recipient_ != "") {
            return (this.TELL_SPEECH_COLORS);
        }
        return (this.NORMAL_SPEECH_COLORS);
    }

    private function useCleanString(_arg_1:Text):Boolean {
        return (((((Parameters.data_.filterLanguage) && ((_arg_1.cleanText_.length > 0)))) && (!((_arg_1.objectId_ == this.model.player.objectId_)))));
    }


}
}//package kabam.rotmg.chat.control
