package kabam.rotmg.friends.controller {
import com.company.assembleegameclient.ui.dialogs.ErrorDialog;

import kabam.rotmg.account.core.Account;
import kabam.rotmg.appengine.api.AppEngineClient;
import kabam.rotmg.dialogs.control.OpenDialogSignal;
import kabam.rotmg.friends.model.FriendConstant;
import kabam.rotmg.friends.model.FriendRequestVO;

public class FriendActionCommand {

    [Inject]
    public var client:AppEngineClient;
    [Inject]
    public var account:Account;
    [Inject]
    public var vo:FriendRequestVO;
    [Inject]
    public var openDialog:OpenDialogSignal;


    public function execute():void {
        var _local_1:String = FriendConstant.getURL(this.vo.request);
        var _local_2:Object = this.account.getCredentials();
        _local_2["targetName"] = this.vo.target;
        this.client.complete.addOnce(this.onComplete);
        this.client.sendRequest(_local_1, _local_2);
    }

    private function onComplete(_arg_1:Boolean, _arg_2:*):void {
        if (this.vo.callback) {
            this.vo.callback(_arg_1, _arg_2, this.vo.target);
        }
        else {
            if (!_arg_1) {
                this.openDialog.dispatch(new ErrorDialog(_arg_2));
            }
        }
    }


}
}//package kabam.rotmg.friends.controller
