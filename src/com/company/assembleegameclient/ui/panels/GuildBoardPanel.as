package com.company.assembleegameclient.ui.panels {
import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.objects.Player;
import com.company.assembleegameclient.ui.board.GuildBoardWindow;
import com.company.assembleegameclient.util.GuildUtil;

import flash.events.MouseEvent;

import kabam.rotmg.text.model.TextKey;

public class GuildBoardPanel extends ButtonPanel {

    public function GuildBoardPanel(_arg_1:GameSprite) {
        super(_arg_1, TextKey.GUILD_BOARD_TITLE, TextKey.PANEL_VIEW_BUTTON);
    }

    override protected function onButtonClick(_arg_1:MouseEvent):void {
        var _local_2:Player = gs_.map.player_;
        if (_local_2 == null) {
            return;
        }
        gs_.addChild(new GuildBoardWindow((_local_2.guildRank_ >= GuildUtil.OFFICER)));
    }


}
}//package com.company.assembleegameclient.ui.panels
