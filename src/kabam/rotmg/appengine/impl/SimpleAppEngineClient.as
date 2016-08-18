package kabam.rotmg.appengine.impl {
import flash.net.URLLoaderDataFormat;

import kabam.rotmg.appengine.api.AppEngineClient;
import kabam.rotmg.appengine.api.RetryLoader;
import kabam.rotmg.application.api.ApplicationSetup;

import org.osflash.signals.OnceSignal;

public class SimpleAppEngineClient implements AppEngineClient {

    [Inject]
    public var loader:RetryLoader;
    [Inject]
    public var setup:ApplicationSetup;
    private var isEncrypted:Boolean;
    private var maxRetries:int;
    private var dataFormat:String;

    public function SimpleAppEngineClient() {
        this.isEncrypted = true;
        this.maxRetries = 0;
        this.dataFormat = URLLoaderDataFormat.TEXT;
    }

    public function get complete():OnceSignal {
        return (this.loader.complete);
    }

    public function setDataFormat(_arg_1:String):void {
        this.loader.setDataFormat(_arg_1);
    }

    public function setSendEncrypted(_arg_1:Boolean):void {
        this.isEncrypted = _arg_1;
    }

    public function setMaxRetries(_arg_1:int):void {
        this.loader.setMaxRetries(_arg_1);
    }

    public function sendRequest(_arg_1:String, _arg_2:Object):void {
        this.loader.sendRequest(this.makeURL(_arg_1), _arg_2);
    }

    private function makeURL(_arg_1:String):String {
        if (_arg_1.charAt(0) != "/") {
            _arg_1 = ("/" + _arg_1);
        }
        return ((this.setup.getAppEngineUrl() + _arg_1));
    }

    public function requestInProgress():Boolean {
        return (this.loader.isInProgress());
    }


}
}//package kabam.rotmg.appengine.impl
