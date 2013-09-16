package example
{
	import UI.App;
	import UI.abstract.component.control.image.Image;
	import UI.abstract.component.control.mc.Animation;
	import UI.abstract.resources.AnCategory;
	import UI.abstract.resources.ResourceUtil;
	import UI.abstract.resources.item.JtaResource;
	import UI.abstract.tween.TweenManager;
	
	import example.ui.AnimationE;
	import example.ui.MovieClipE;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;

	[SWF(width="1000", height="580",backgroundColor="#222222")]
	public class UIEditor extends Sprite
	{
		
		public function UIEditor()
		{
			super();
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			App.init( this );
			TweenManager.initClass();
			createUi();
			
		}
		
		private function createUi() : void
		{
			var ui:AnimationE = new AnimationE();
			addChild(ui);
			return;
			//var com:MovieClipE = new MovieClipE();
			//addChild(com);
			//return;
			/*
			ui/atlas.atlas?names=flight_
			ui/mySpritesheet.atlas?names=fly_
			*/
			
			var image:Image = new Image();
			image.url = ResourceUtil.getAnimationBitmapData5(ResourceUtil.getAnimationURL(AnCategory.NPC,"500000025",0),2,3,2);
			addChild(image);
			//App.loader.load(ResourceUtil.getAnimationURL(AnCategory.EFFECT,"400000060",0),onComplete);
		}
		private function onComplete(res:JtaResource):void{
			//App.loader.addUseNumber(res);
			
		}
	}
}