package {


import flash.display.BitmapData;
import flash.display.Stage;
import flash.display3D.Context3DProfile;
import flash.geom.Rectangle;
import flash.text.TextFormatAlign;
import flash.text.TextFormatAlign;
import flash.utils.setTimeout;

import harayoki.starling2.utils.AssetManager;

import misc.ViewportUtil;

import starling.animation.Juggler;
import starling.core.Starling;
import starling.display.BlendMode;
import starling.display.MovieClip;
import starling.display.Sprite;
import starling.events.EnterFrameEvent;
import starling.events.Event;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.styles.DistanceFieldStyle;
import starling.styles.MeshStyle;
import starling.text.TextField;
import starling.textures.Texture;

public class StarlingMain extends Sprite {

    private static const DEFAULT_CONTENTS_SIZE:Rectangle = new Rectangle(0, 0, 640 * 2, 480 * 2);

    private static var _starling:Starling;
    private static var _startCallback:Function;

    public static function start(nativeStage:Stage, startCallback:Function = null):void {
        trace("Starling version :", Starling.VERSION);

        _startCallback = startCallback;

        _starling = new Starling(
                StarlingMain,
                nativeStage,
                DEFAULT_CONTENTS_SIZE,
                null,
                "auto",
                Context3DProfile.STANDARD_CONSTRAINED // for 2016 smart phone
        );
        _starling.enableErrorChecking = false;
        _starling.skipUnchangedFrames = true;
        _starling.stage.blendMode = BlendMode.AUTO; // NONE?
        _starling.start();

    }

    private var _assetManager:AssetManager;
    private var _juggler:Juggler;

    public function StarlingMain() {


        if (_startCallback) {
            _startCallback.apply(null, [_starling]);
        }

        trace("Stage3D profile:", _starling.profile);

        _assetManager = new AssetManager();
        _assetManager.verbose = true;

        ViewportUtil.setupViewPort(Starling.current, DEFAULT_CONTENTS_SIZE, true);

        _assetManager.enqueue('assets/whiteMan_org.png');
        _assetManager.enqueue('assets/whiteMan_org.xml');
        _assetManager.enqueue('assets/whiteMan_df.png');
        _assetManager.enqueue('assets/whiteMan_df.xml');

        _assetManager.setBeforeTextureCreationCallback(function (name:String, bmd:BitmapData):BitmapData {
            return null;
        });
        _assetManager.addEventListener(Event.TEXTURES_RESTORED, function (ev:Event):void {
            trace("TEXTURES_RESTORED");
        });

        // load main assets
        _assetManager.loadQueue(function (ratio:Number):void {
            if (ratio == 1) {
                _locateAnims();
            }
        });

    }

    private function _locateAnims():void {
        _juggler = new Juggler();
        _juggler.timeScale = 0.25; // システム60fpsなのでアニメ15fpsに合わせている
        Starling.juggler.add(_juggler);

        var style:DistanceFieldStyle;
        var mc:MovieClip;

        mc = _locateAnim('ORG', 100, 40, 0xcccccc, 1.0);
        _addTitle('ノーマルレンダリング 等倍', mc.x, mc.y);
        style = new DistanceFieldStyle();
        mc = _locateAnim('manAnim', 250, 40, 0xcccccc, 1.0, style);
        _addTitle('DistanceFieldレンダリング 等倍', mc.x, mc.y);

        mc = _locateAnim('ORG', 200, 200, 0xffffff, 4.0);
        _addTitle('ノーマルレンダリング 拡大', mc.x, mc.y);
        _scaleMc(mc);
        style = new DistanceFieldStyle();
        mc = _locateAnim('manAnim', 750, 200, 0xffffff, 4.0, style);
        _addTitle('DistanceFieldレンダリング 拡大', mc.x, mc.y);
        _scaleMc(mc);

        _addTitle('タッチで大きさが変わります', 640, 850, 0xff00ff);

    }

    private function _locateAnim(imageName:String, xx:int, yy:int, color:Number= 0x00ffff, scale:Number=1.0, style:MeshStyle = null):MovieClip {

        var textures:Vector.<Texture> = _assetManager.getTextures(imageName);
        var mc:MovieClip = new MovieClip(textures, 60);
        mc.x = xx;
        mc.y = yy;
        mc.pivotX = mc.width >> 2;
        mc.pivotY = mc.height >> 2;
		mc.color = color;
        mc.scale = scale;
        if (style) {
            mc.style = style;
        }
        addChildAt(mc, 0);
        _juggler.add(mc);

        return mc;

    }

    private function _addTitle(title:String, xx:int, yy:int, color:Number= 0x00ffff, autoDispose:Boolean=true):void {

        var tf:TextField = new TextField(300, 20, title);
        tf.x = xx;
        tf.y = yy;
        tf.format.color = color;
        tf.alignPivot(TextFormatAlign.CENTER, TextFormatAlign.CENTER);
        tf.batchable = true;
        addChild(tf);
		if(autoDispose) {
            // しばらくしたら消す
            setTimeout(function () {
                tf.dispose();
            }, 10 * 1000);
		}

    }

	private function _scaleMc(mc:MovieClip):void {
        var theta:Number = 0;
		var scale = mc.scale;
        var orgScale = mc.scale;
        mc.addEventListener(TouchEvent.TOUCH, function (ev:TouchEvent):void {
            var phase:String = ev.touches[0].phase;
            if (phase == TouchPhase.BEGAN) {
                theta += 0.7;
            }
        });
		addEventListener(EnterFrameEvent.ENTER_FRAME, function(ev):void {
            theta += 0.001;
			scale = orgScale + ( 1 + Math.sin(-theta) ) * orgScale;
            mc.scale = scale;
        });
    }

}

}