package UI.abstract.resources.loader
{
	import UI.App;
	import UI.abstract.resources.ResourceManager;
	import UI.abstract.resources.item.ImageResource;
	import UI.abstract.resources.item.LoadObj;
	import UI.abstract.resources.item.XmlResource;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	public class ImageAtlasLoader extends BaseLoader
	{
		
		public function ImageAtlasLoader(loadObj:LoadObj)
		{
			super(loadObj);
			_content = new Object();
			
		}
		override public function load () : void
		{
			var str : String = ResourceManager.unFormatResourceName(loadObj.url.substr(0, loadObj.url.lastIndexOf( "." ) ));
			App.loader.load(str+".xml",onCompleteXML,{onField:onIOErrorXML});
			
		}
		
		protected function onCompleteXML ( res : XmlResource ) : void
		{
			_content.xmlResource = res;
			App.loader.load(res.xml.attribute("imagePath")[0],onCompleteImage,{onField:onIOErrorImage});
		}
		
		protected function onIOErrorXML ( ) : void
		{
			dispatchEvent( new IOErrorEvent( IOErrorEvent.IO_ERROR ) );
		}
		protected function onCompleteImage ( res : ImageResource ) : void
		{
			_content.imageResource = res;
			dispatchEvent( new Event( Event.COMPLETE ) );
		}
		
		protected function onIOErrorImage ( ) : void
		{
			dispatchEvent( new IOErrorEvent( IOErrorEvent.IO_ERROR ) );
		}
		
		override public function dispose () : void
		{
			super.dispose();
		}
	}
}