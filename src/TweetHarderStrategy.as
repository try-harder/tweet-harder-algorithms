package {
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import skins.TweetHarderStrategySkin;
	
	public class TweetHarderStrategy extends Sprite {

		public function TweetHarderStrategy() {
			addChild(new TweetHarderStrategySkin.ProjectSprouts() as DisplayObject);
			trace("TweetHarderStrategy instantiated!");
		}
	}
}
