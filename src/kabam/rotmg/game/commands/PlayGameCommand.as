package kabam.rotmg.game.commands {
import com.company.assembleegameclient.appengine.SavedCharacter;
import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.parameters.Parameters;

import flash.utils.ByteArray;

import kabam.lib.net.impl.SocketServerModel;
import kabam.lib.tasks.TaskMonitor;
import kabam.rotmg.account.core.services.GetCharListTask;
import kabam.rotmg.core.model.PlayerModel;
import kabam.rotmg.core.signals.SetScreenSignal;
import kabam.rotmg.game.model.GameInitData;
import kabam.rotmg.pets.data.PetsModel;
import kabam.rotmg.servers.api.Server;
import kabam.rotmg.servers.api.ServerModel;

public class PlayGameCommand {

    public static const RECONNECT_DELAY:int = 2000;

    [Inject]
    public var setScreen:SetScreenSignal;
    [Inject]
    public var data:GameInitData;
    [Inject]
    public var model:PlayerModel;
    [Inject]
    public var petsModel:PetsModel;
    [Inject]
    public var servers:ServerModel;
    [Inject]
    public var task:GetCharListTask;
    [Inject]
    public var monitor:TaskMonitor;
    [Inject]
    public var socketServerModel:SocketServerModel;


    public function execute():void {
        if (!this.data.isNewGame) {
            this.socketServerModel.connectDelayMS = PlayGameCommand.RECONNECT_DELAY;
        }
        this.recordCharacterUseInSharedObject();
        this.makeGameView();
        this.updatePet();
    }

    private function updatePet():void {
        var _local_1:SavedCharacter = this.model.getCharacterById(this.model.currentCharId);
        if (_local_1) {
            this.petsModel.setActivePet(_local_1.getPetVO());
        }
        else {
            if (((((this.model.currentCharId) && (this.petsModel.getActivePet()))) && (!(this.data.isNewGame)))) {
                return;
            }
            this.petsModel.setActivePet(null);
        }
    }

    private function recordCharacterUseInSharedObject():void {
        Parameters.data_.charIdUseMap[this.data.charId] = new Date().getTime();
        Parameters.save();
    }

    private function makeGameView():void {
        var _local_1:Server = ((this.data.server) || (this.servers.getServer()));
        var _local_2:int = ((this.data.isNewGame) ? this.getInitialGameId() : this.data.gameId);
        var _local_3:Boolean = this.data.createCharacter;
        var _local_4:int = this.data.charId;
        var _local_5:int = ((this.data.isNewGame) ? -1 : this.data.keyTime);
        var _local_6:ByteArray = this.data.key;
        this.model.currentCharId = _local_4;
        this.setScreen.dispatch(new GameSprite(_local_1, _local_2, _local_3, _local_4, _local_5, _local_6, this.model, null, this.data.isFromArena));
    }

    private function getInitialGameId():int {
        var _local_1:int;
        if (Parameters.data_.needsTutorial) {
            _local_1 = Parameters.TUTORIAL_GAMEID;
        }
        else {
            if (Parameters.data_.needsRandomRealm) {
                _local_1 = Parameters.RANDOM_REALM_GAMEID;
            }
            else {
                _local_1 = Parameters.NEXUS_GAMEID;
            }
        }
        return (_local_1);
    }


}
}//package kabam.rotmg.game.commands
