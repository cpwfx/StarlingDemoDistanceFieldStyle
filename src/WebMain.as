package {

import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageQuality;
import flash.display.StageScaleMode;
import flash.events.Event;

import starling.core.Starling;

[SWF(width = "1280", height = "960", frameRate = "60", backgroundColor = "#111111")]
public class WebMain extends Sprite {
    public function WebMain() {
        stage.align = StageAlign.TOP_LEFT;
        stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.frameRate = 60;
        stage.quality = StageQuality.LOW;
        stage.color = 0x333333;
        addEventListener(Event.ADDED_TO_STAGE, _init);
    }

    private function _init(ev:Event=null):void {
        StarlingMain.start(stage, _handleStartStarling);
    }

    private function _handleStartStarling(starling:Starling):void {
        trace("_handleStartStarling");
    }
}
}

