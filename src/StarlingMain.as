package {


import flash.display.BitmapData;
import flash.display.Stage;
import flash.display3D.Context3DProfile;
import flash.geom.Rectangle;
import flash.utils.setTimeout;

import harayoki.starling2.filters.ScanLineFilter;
import harayoki.starling2.filters.SlashShadedFilter;
import harayoki.starling2.utils.AssetManager;

import misc.ViewportUtil;

import starling.animation.Juggler;
import starling.core.Starling;
import starling.display.BlendMode;
import starling.display.Image;
import starling.display.MovieClip;
import starling.display.Sprite;
import starling.events.Event;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.filters.FilterChain;
import starling.filters.GlowFilter;
import starling.styles.DistanceFieldStyle;
import starling.styles.MeshStyle;
import starling.text.TextField;
import starling.textures.Texture;
import starling.utils.Align;

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
    private var _textContainer:Sprite;
    private var _animationContainer:Sprite;

    public function StarlingMain() {


        if (_startCallback) {
            _startCallback.apply(null, [_starling]);
        }

        trace("Stage3D profile:", _starling.profile);

        _assetManager = new AssetManager();
        _assetManager.verbose = true;

        ViewportUtil.setupViewPort(Starling.current, DEFAULT_CONTENTS_SIZE, true);

        _assetManager.enqueue("assets/mans.png");
        _assetManager.enqueue("assets/mans.xml");

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

        _animationContainer = new Sprite();
        addChild(_animationContainer);

        _textContainer = new Sprite();
        addChild(_textContainer);

        var visibleChanged:Boolean = false;
        stage.addEventListener(TouchEvent.TOUCH, function(ev:TouchEvent):void {
            if(ev.touches[0].phase === TouchPhase.BEGAN) {
                visibleChanged = true;
                _textContainer.visible = ! _textContainer.visible;
            }
        });
        setTimeout(function():void{
            if(visibleChanged) {
                return;
            }
            visibleChanged = true;
            _textContainer.visible = ! _textContainer.visible;
        }, 10 * 1000);

        var style:DistanceFieldStyle;
        var mc:MovieClip;
        var image:Image;
        var sp:Sprite;

        style = new DistanceFieldStyle();
        mc = _locateAnim("df_manAnim", 80, 100, 1.0);
        mc.style = style;
        _addTitle("1x", mc.x, mc.bounds.bottom);

        style = new DistanceFieldStyle();
        mc = _locateAnim("df_manAnim", 200, 100, 2.0);
        mc.style = style;
        mc.color = 0x88ff00;
        _addTitle("2x, colored", mc.x, mc.bounds.bottom);

        style = new DistanceFieldStyle();
        mc = _locateAnim("df_manAnim", 400, 100, 2.0);
        mc.style = style;
        mc.color = 0xff00ff;
        _addTitle("2x, vertex colored", mc.x, mc.bounds.bottom);
        _applyRandomColorToImage(mc);

        style = new DistanceFieldStyle();
        style.setupOutline();
        mc = _locateAnim("df_manAnim", 600, 100, 2.0);
        mc.style = style;
        _addTitle("2x, border(DistanceField)", mc.x, mc.bounds.bottom);

        style = new DistanceFieldStyle();
        style.setupDropShadow(0.2,4, 4);
        mc = _locateAnim("df_manAnim", 800, 100, 2.0);
        mc.style = style;
        _addTitle("2x, shadow(DistanceField)", mc.x, mc.bounds.bottom);

        style = new DistanceFieldStyle();
        style.setupGlow();
        mc = _locateAnim("df_manAnim", 1000, 100, 2.0);
        mc.style = style;
        _addTitle("2x, glow(DistanceField)", mc.x, mc.bounds.bottom);

        style = new DistanceFieldStyle();
        mc = _locateAnim("df_manAnim", 150, 400, 2.0);
        mc.style = style;
        mc.color = 0xff00ff;
        mc.filter = new SlashShadedFilter(4, 0xffffff, 1);
        _addTitle("2x, colored, CustomFilter1", mc.x, mc.bounds.bottom);

        style = new DistanceFieldStyle();
        mc = _locateAnim("df_manAnim", 350, 400, 2.0);
        mc.style = style;
        mc.color = 0xff00ff;
        mc.filter = new ScanLineFilter(1);
        _applyRandomColorToImage(mc);
        _addTitle("2x, vertex colored,\nCustomFilter2", mc.x, mc.bounds.bottom);

        style = new DistanceFieldStyle();
        style.setupOutline();
        mc = _locateAnim("df_manAnim", 550, 400, 2.0);
        mc.style = style;
        mc.color = 0xff8800;
        mc.filter = new GlowFilter()
        _addTitle("2x, border(DistanceField),\n GlowFilter", mc.x, mc.bounds.bottom);

        style = new DistanceFieldStyle();
        style.setupOutline();
        mc = _locateAnim("df_manAnim", 850, 350, 6.0);
        mc.style = style;
        mc.color = 0xff8800;
        mc.filter = new FilterChain(new ScanLineFilter(4, 30 , 3, 0x993366, 1.0), new GlowFilter(0x00ffff,1,2));
        _applyRandomColorToImage(mc);
        _addTitle("6x, vertex colored, border(DistanceField), CustomFilter2, GlowFilter", mc.x, mc.bounds.bottom, 0);

        //////////

        style = new DistanceFieldStyle();
        style.setupOutline();
        image = _addImage("df_manAnim", 80, 650, 1.0);
        image.scale9Grid = new Rectangle(35,60,20,30);
        image.style = style;
        _applyRandomColorToImage(image, 35);
        _addTitle("9scaleGrid(Image),\n vertex colored", image.x, image.bounds.bottom);

        style = new DistanceFieldStyle();
        style.setupOutline();
        image = _addImage("df_manAnim", 200, 650, 1.0);
        image.scaleY = 1.9;
        image.scale9Grid = new Rectangle(35,80,15,20);
        image.style = style;
        image.color = 0x33ffcc;
        _addTitle("9scaleGrid(Image), border(DistanceField),\n scaling(Y), colored", image.x, image.bounds.bottom);

        style = new DistanceFieldStyle();
        style.setupOutline();
        mc = _locateAnim("df_manAnim", 500, 650 + 50 , 1.0);
        mc.style = style;
        mc.scaleY = 1.5;
        mc.scale9Grid = new Rectangle(35,75,20,20);
        _applyRandomColorToImage(mc, 35);
        _addTitle("9scaleGrid(MovieClip), border(DistanceField),\n scaling(Y), vertex colored", mc.x, mc.bounds.bottom);

    }

    private function _locateAnim(imageName:String, xx:int, yy:int, scale:Number=1.0):MovieClip {

        var textures:Vector.<Texture> = _assetManager.getTextures(imageName);
        var mc:MovieClip = new MovieClip(textures, 60);
        mc.x = xx;
        mc.y = yy;
        mc.pivotX = mc.width >> 2;
        mc.pivotY = mc.height >> 2;
        mc.scale = scale;
        _animationContainer.addChild(mc);
        _juggler.add(mc);

        return mc;

    }

    private function _addImage(imageName:String, xx:int, yy:int, scale:Number=1.0):Image {
        var textures:Vector.<Texture> = _assetManager.getTextures(imageName);
        var texture:Texture = textures[0];
        var image:Image = new Image(texture);
        image.x = xx;
        image.y = yy;
        image.scale = scale;
        _animationContainer.addChild(image);
        return image;
    }

    private function _addTitle(title:String, xx:int, yy:int, dy:int = 70, color:Number= 0xccffff):void {

        var tf:TextField = new TextField(500, 100, title);
        tf.x = xx;
        tf.y = yy + dy;
        tf.format.color = color;
        tf.alignPivot(Align.CENTER, Align.BOTTOM);
        tf.batchable = true;
        _textContainer.addChild(tf);

    }


    private function _getRandomColor():uint {
        var r:int = 255 * (0.1 + Math.random()*0.9);
        var g:int = 255 * (0.1 + Math.random()*0.9);
        var b:int = 255 * (0.1 + Math.random()*0.9);
        return (r << 16) + (g << 8) + b;
    }

    private function _applyRandomColorToImage(image:Image, numVertex:int=4):void {
        while(numVertex--) {
            image.setVertexColor(numVertex, _getRandomColor());
        }
    }

}

}