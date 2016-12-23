package {


import flash.display.BitmapData;
import flash.display.Stage;
import flash.display3D.Context3DProfile;
import flash.geom.Rectangle;

import harayoki.starling2.utils.AssetManager;

import misc.ViewportUtil;

import starling.animation.Juggler;

import starling.core.Starling;
import starling.display.BlendMode;
import starling.display.MovieClip;
import starling.display.Sprite;
import starling.events.Event;
import starling.styles.DistanceFieldStyle;
import starling.styles.MeshStyle;
import starling.textures.Texture;

public class StarlingMain extends Sprite {

		private static const DEFAULT_CONTENTS_SIZE:Rectangle = new Rectangle(0, 0, 640 *2 , 480 * 2);

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

			_assetManager.setBeforeTextureCreationCallback(function(name:String,bmd:BitmapData):BitmapData{
				return null;
			});
			_assetManager.addEventListener(Event.TEXTURES_RESTORED, function(ev:Event):void {
				trace("TEXTURES_RESTORED");
			});

			// load main assets
			_assetManager.loadQueue(function(ratio:Number):void {
				if(ratio == 1) {
                    _playAnims();
				}
			});

		}

		private function _playAnims():void {
            _juggler = new Juggler();
            _juggler.timeScale = 0.25; // システム60fpsなのでアニメ15fpsに合わせている
            Starling.juggler.add(_juggler);

			_playAnim('ORG', 50, 100, 4.0);
            //_playAnim('anim', 400, 150, 5.0);
            var style1:DistanceFieldStyle = new DistanceFieldStyle();
            _playAnim('manAnim', 500, 150, 4.0, style1);

		}

		private function _playAnim(imageName:String, xx:int, yy:int, scale:Number, style:MeshStyle=null):void {

            var textures:Vector.<Texture> = _assetManager.getTextures(imageName);
            var mc:MovieClip = new MovieClip(textures, 60);
            mc.x = xx;
            mc.y = yy;
            mc.scale = scale;
            if(style) {
                mc.style = style;
            }
            addChild(mc);

            _juggler.add(mc);

		}

	}
}