package kabam.rotmg.ui.view {
import com.company.assembleegameclient.screens.ServersScreen;

import kabam.rotmg.core.signals.SetScreenSignal;
import kabam.rotmg.servers.api.ServerModel;

import robotlegs.bender.bundles.mvcs.Mediator;

public class ServersMediator extends Mediator {

    [Inject]
    public var view:ServersScreen;
    [Inject]
    public var servers:ServerModel;
    [Inject]
    public var setScreen:SetScreenSignal;


    override public function initialize():void {
        this.view.gotoTitle.add(this.onGotoTitle);
        this.view.initialize(this.servers.getServers());
    }

    override public function destroy():void {
        this.view.gotoTitle.remove(this.onGotoTitle);
    }

    private function onGotoTitle():void {
        this.setScreen.dispatch(new TitleView());
    }


}
}//package kabam.rotmg.ui.view
