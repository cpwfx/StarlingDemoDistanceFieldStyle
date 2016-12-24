package {


import flash.display.BitmapData;
import flash.display.Stage;
import flash.display3D.Context3DProfile;
import flash.geom.Rectangle;
import flash.text.TextFormatAlign;
import flash.utils.setTimeout;

import harayoki.starling2.filters.PosterizationFilter;
import harayoki.starling2.filters.ScanLineFilter;

import harayoki.starling2.filters.SlashShadedFilter;

import harayoki.starling2.utils.AssetManager;

import misc.ViewportUtil;

import starling.animation.Juggler;
import starling.core.Starling;
import starling.display.BlendMode;
import starling.display.Image;
import starling.display.Mesh;
import starling.display.MovieClip;
import starling.display.Sprite;
import starling.events.EnterFrameEvent;
import starling.events.Event;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.filters.FilterChain;
import starling.filters.GlowFilter;
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

        _assetManager.enqueue('assets/mans.png');
        _assetManager.enqueue('assets/mans.xml');

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
        var image:Image;
        var sp:Sprite;

        style = new DistanceFieldStyle();
        mc = _locateAnim('df_manAnim', 100, 100, 1.0, style);
        _addTitle('等倍 未着色', mc.x, mc.bounds.bottom);

        style = new DistanceFieldStyle();
        mc = _locateAnim('df_manAnim', 200, 100, 2.0, style);
        mc.color = 0x88ff00;
        _addTitle('2倍 着色', mc.x, mc.bounds.bottom);

        style = new DistanceFieldStyle();
        mc = _locateAnim('df_manAnim', 400, 100, 2.0, style);
        mc.color = 0xff00ff;
        _addTitle('2倍 頂点着色', mc.x, mc.bounds.bottom);
        _applyRandomColorToImage(mc);

        style = new DistanceFieldStyle();
        style.setupOutline();
        mc = _locateAnim('df_manAnim', 600, 100, 2.0, style);
        _addTitle('2倍 枠線', mc.x, mc.bounds.bottom);

        style = new DistanceFieldStyle();
        style.setupDropShadow(0.2,4, 4);
        mc = _locateAnim('df_manAnim', 800, 100, 2.0, style);
        _addTitle('2倍 シャドウ', mc.x, mc.bounds.bottom);

        style = new DistanceFieldStyle();
        style.setupGlow();
        mc = _locateAnim('df_manAnim', 1000, 100, 2.0, style);
        _addTitle('2倍 グロウ', mc.x, mc.bounds.bottom);

        style = new DistanceFieldStyle();
        mc = _locateAnim('df_manAnim', 200, 350, 2.0, style);
        mc.color = 0xff00ff;
        mc.filter = new SlashShadedFilter(4, 0xffffff, 1);
        _addTitle('2倍 着色 + my filter1', mc.x, mc.bounds.bottom);

        style = new DistanceFieldStyle();
        mc = _locateAnim('df_manAnim', 400, 350, 2.0, style);
        mc.color = 0xff00ff;
        mc.filter = new ScanLineFilter(1);
        _applyRandomColorToImage(mc);
        _addTitle('2倍 頂点着色 + my filter2', mc.x, mc.bounds.bottom);

        style = new DistanceFieldStyle();
        style.setupOutline();
        mc = _locateAnim('df_manAnim', 600, 350, 2.0, style);
        mc.color = 0xff8800;
        mc.filter = new GlowFilter()
        _addTitle('2倍 枠線 + グロウフィルタ', mc.x, mc.bounds.bottom);

        style = new DistanceFieldStyle();
        style.setupOutline();
        mc = _locateAnim('df_manAnim', 850, 350, 6.0, style);
        mc.color = 0xff8800;
        mc.filter = new FilterChain(new ScanLineFilter(3), new GlowFilter(0x00ffff,1,2));
        _applyRandomColorToImage(mc);
        _addTitle('6倍 頂点着色 + 枠線 + my filter2 + グロウフィルタ', mc.x, mc.bounds.bottom);


        style = new DistanceFieldStyle();
        style.setupOutline();
        image = _addImage("df_manAnim", 100, 600, 1.0);
        image.scale9Grid = new Rectangle(35,60,20,30);
        image.style = style;
        _applyRandomColorToImage(image, 35);
        _addTitle('9スケール + 頂点着色', image.x, image.bounds.bottom);

        style = new DistanceFieldStyle();
        style.setupOutline();
        image = _addImage("df_manAnim", 250, 600, 1.0);
        image.scaleY = 1.5;
        image.scale9Grid = new Rectangle(35,75,20,20);
        image.style = style;
        _applyRandomColorToImage(image, 35);
        _addTitle('9スケール + 拡大 + 頂点着色', image.x, image.bounds.bottom);

        style = new DistanceFieldStyle();
        style.setupOutline();
        mc = _locateAnim('df_manAnim', 500, 600 + 50 , 1.0, style);
        mc.scaleY = 1.5;
        mc.scale9Grid = new Rectangle(35,75,20,20);
        _applyRandomColorToImage(mc, 35);
        _addTitle('9スケール + 拡大 + 頂点着色 + anime', mc.x, mc.bounds.bottom);

    }

    private function _locateAnim(imageName:String, xx:int, yy:int, scale:Number=1.0, style:DistanceFieldStyle = null):MovieClip {

        var textures:Vector.<Texture> = _assetManager.getTextures(imageName);
        var mc:MovieClip = new MovieClip(textures, 60);
        mc.x = xx;
        mc.y = yy;
        mc.pivotX = mc.width >> 2;
        mc.pivotY = mc.height >> 2;
        mc.scale = scale;
        mc.style = style;
        addChild(mc);
        _juggler.add(mc);

        return mc;

    }

    private function _addImage(imageName:String, xx:int, yy:int, scale:Number=1.0, style:MeshStyle = null):Image {
        var textures:Vector.<Texture> = _assetManager.getTextures(imageName);
        var texture:Texture = textures[0];
        var image:Image = new Image(texture);
        image.x = xx;
        image.y = yy;
        image.scale = scale;
        image.style = style;
        addChildAt(image, 0);
        return image;
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


    private function _randomColor():uint {
        var r:int = 255 * (0.1 + Math.random()*0.9);
        var g:int = 255 * (0.1 + Math.random()*0.9);
        var b:int = 255 * (0.1 + Math.random()*0.9);
        return (r << 16) + (g << 8) + b;
    }

    private function _applyRandomColorToImage(image:Image, numVertex:int=4):void {
        while(numVertex--) {
            image.setVertexColor(numVertex, _randomColor());
        }
    }

//    private function _createMeshedImage(imageName:String, px:int, py:int, scale:Number=1.0, style:MeshStyle = null):Sprite {
//        var sp = new Sprite();
//        sp.x = px;
//        sp.y = py;
//        sp.scale = scale;
//        var textures:Vector.<Texture> = _assetManager.getTextures(imageName);
//        var texture:Texture = textures[0];
//        var image:Image;
//        var divX:int = 2;
//        var divY:int = 2;
//        var du:Number = 1 / divX;
//        var dv:Number = 1 / divY;
//        var dw:Number = texture.nativeWidth / divX;
//        var dh:Number = texture.nativeHeight / divY;
//        for (var yy:int=0 ; yy<divY; yy++) {
//            for (var xx:int=0 ; xx<divX; xx++) {
//                image = new Image(texture);
//                image.setTexCoords(0, du * xx, dv * yy);
//                image.setTexCoords(1, du * (1 + xx), dv * yy);
//                image.setTexCoords(2, du * xx, dv * (yy + 1));
//                image.setTexCoords(3, du * (1 + xx), dv * (yy + 1));
//                image.width  = dw;
//                image.height = dh;
//                image.x = dw * xx;
//                image.y = dh * yy;
//                image.style = new DistanceFieldStyle();
//                _applyRandomColorToImage(image);
//                sp.addChild(image);
//            }
//        }
//        addChildAt(sp , 0);
//        return sp;
//    }
}

}