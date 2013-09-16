package UI.abstract.resources.item
{
	import UI.App;
	import UI.abstract.resources.ResourceManager;
	import UI.abstract.resources.ResourceUtil;
	import UI.abstract.resources.loader.BaseLoader;
	
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	public class ImageAtlasResource extends Resource
	{
		private var imageResource:ImageResource;
		private var mTextureRegions:Dictionary;
		private var mTextureFrames:Dictionary;
		
		private var sNames:Vector.<String> = new Vector.<String>();
		public function ImageAtlasResource()
		{
			super();
			mTextureRegions = new Dictionary();
			mTextureFrames  = new Dictionary();
		}
		override public function initialize ( data : BaseLoader ) : void
		{
			super.initialize( data );
			imageResource = data.content.imageResource;
			App.loader.addUseNumber( imageResource );
			parseAtlasXml(data.content.xmlResource.xml);
			_content.imageResource = null;
			_content.xmlResource = null;
			_content = null;
			
			
		}
		protected function parseAtlasXml(atlasXml:XML):void
		{
			
			for each (var subTexture:XML in atlasXml.SubTexture)
			{
				var name:String        = subTexture.attribute("name");
				var x:Number           = parseFloat(subTexture.attribute("x"));
				var y:Number           = parseFloat(subTexture.attribute("y"));
				var width:Number       = parseFloat(subTexture.attribute("width"));
				var height:Number      = parseFloat(subTexture.attribute("height"));
				var frameX:Number      = parseFloat(subTexture.attribute("frameX"));
				var frameY:Number      = parseFloat(subTexture.attribute("frameY"));
				var frameWidth:Number  = parseFloat(subTexture.attribute("frameWidth"));
				var frameHeight:Number = parseFloat(subTexture.attribute("frameHeight"));
				
				var region:Rectangle = new Rectangle(x, y, width, height);
				var frame:Rectangle  = frameWidth > 0 && frameHeight > 0 ?
					new Rectangle(frameX, frameY, frameWidth, frameHeight) : null;
				
				addRegion(name, region, frame);
			}
		}
		public function addRegion(name:String, region:Rectangle, frame:Rectangle=null):void
		{
			mTextureRegions[name] = region;
			mTextureFrames[name]  = frame;
		}
		public function getTexture(name:String):ImageResource
		{
			//有可能图片集被清除了，图片并没有被清除，在获取图片的事件，直接返回，增加重复资源
			if(App.loader.getResource( ResourceManager.unFormatResourceName( url+"?"+ResourceUtil.IMAGE+"="+name ))){
				return App.loader.getResource( ResourceManager.unFormatResourceName( url+"?"+ResourceUtil.IMAGE+"="+name )) as ImageResource;
			}
			var region:Rectangle = mTextureRegions[name];
			var bmd : BitmapData = new BitmapData( region.width , region.height , true , 0 );
			bmd.copyPixels( imageResource.bitmapData , region , new Point( 0 , 0 ) );
			
			var newImageResource:ImageResource = new ImageResource();
			newImageResource.content = bmd;
			newImageResource.parent = this;
			newImageResource.frame = mTextureFrames[name];
			newImageResource.url = url+"?"+ResourceUtil.IMAGE+"="+name;
			App.loader.addResource(ResourceManager.unFormatResourceName( newImageResource.url ) , newImageResource);
			return newImageResource;
		}
		public function getTextures(prefix:String):ImageArrayResource
		{
			var result:Vector.<ImageResource> = new Vector.<ImageResource>();
			
			for each (var name:String in getNames(prefix, sNames)) 
				result.push(getTexture(name)); 
			
			sNames.length = 0;
			
			var imageArrayResource:ImageArrayResource = new ImageArrayResource();
			imageArrayResource.content = result;
			imageArrayResource.url = url+"?"+ResourceUtil.MC+"="+prefix;
			App.loader.addResource(ResourceManager.unFormatResourceName( imageArrayResource.url ) , imageArrayResource);
			return imageArrayResource;
		}
		public function getNames(prefix:String="", result:Vector.<String>=null):Vector.<String>
		{
			if (result == null) result = new Vector.<String>();
			
			for (var name:String in mTextureRegions)
				if (name.indexOf(prefix) == 0)
					result.push(name);
			
			result.sort(Array.CASEINSENSITIVE);
			return result;
		}
		override public function dispose():void
		{
			
			App.loader.subtractUseNumber( imageResource );
			imageResource = null;
			mTextureRegions = null;
			mTextureFrames = null;
			super.dispose();
		}
	}
}