package misc {
	import flash.events.Event;
	import flash.geom.Rectangle;

	import starling.core.Starling;
	import starling.utils.Align;
	import starling.utils.RectangleUtil;
	import starling.utils.ScaleMode;

	public class ViewportUtil {

		// Statsの横表示位置
		public static var SHOW_STATS_VALIGN:String = Align.LEFT;
		// Statsの縦表示位置
		public static var SHOW_STATS_HALIGN:String = Align.TOP;

		/**
		 * viewportをスクリーンサイズに合わせて真ん中合わせで調整する
		 * @param starling Starling参照
		 * @param contentsSize 基本となるコンテンツのサイズ
		 * @param pixcelPerfectForUpperScale 画面の大きさを1,2,3,4..倍に吸着するか
		 *        (小さい場合は吸着させると見えなくなってしまうのでそのまま)
		 * @param showStats Statsを表示するか
		 */
		public static function setupViewPort(
			starling:Starling,
			contentsSize:Rectangle,
			pixcelPerfectForUpperScale:Boolean=false,
			showStats:Boolean=true
		):void {

			// 吸着して真ん中寄せ
			var updateViewPort:Function = function(ev:Event=null):void {
				var w:int = starling.nativeStage.stageWidth;
				var h:int = starling.nativeStage.stageHeight;
				var scale:Number = Math.min(w/contentsSize.width,h/contentsSize.height);
				// 注意：scale==0だとエラーになります
				if(pixcelPerfectForUpperScale) {
					if(scale > 1.0) scale = Math.floor(scale);
				}
				trace(['stage', w,h],'scale to', scale);
				starling.viewPort = RectangleUtil.fit(
					contentsSize,
					new Rectangle(
						(w - contentsSize.width*scale)>>1,
						(h - contentsSize.height*scale)>>1,
						contentsSize.width*scale,
						contentsSize.height*scale
					),
					ScaleMode.SHOW_ALL
				);
				if(showStats) {
					starling.showStatsAt(SHOW_STATS_VALIGN, SHOW_STATS_HALIGN);
				}
			}

			starling.nativeStage.addEventListener(Event.RESIZE, updateViewPort);
			starling.showStats = showStats;
			updateViewPort();

		}
	}
}
