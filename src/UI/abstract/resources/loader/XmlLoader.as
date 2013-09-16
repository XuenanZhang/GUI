package UI.abstract.resources.loader
{
	import UI.abstract.resources.item.LoadObj;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	public class XmlLoader extends BaseLoader
	{
		private var loader : URLLoader;
		public function XmlLoader(loadObj:LoadObj)
		{
			super(loadObj);
			loader = new URLLoader();
			loader.addEventListener( Event.COMPLETE , onComplete );
			loader.addEventListener( IOErrorEvent.IO_ERROR , onIOError );
		}
		override public function load () : void
		{
			loader.load( new URLRequest( loadObj.url ) );
		}
		
		override protected function onComplete ( event : Event ) : void
		{
			_content = loader.data;
			dispatchEvent( new Event( Event.COMPLETE ) );
		}
		
		override protected function onIOError ( event : IOErrorEvent ) : void
		{
			dispatchEvent( new IOErrorEvent( IOErrorEvent.IO_ERROR ) );
		}
		
		override public function dispose () : void
		{
			
			loader.removeEventListener( Event.COMPLETE , onComplete );
			loader.removeEventListener( IOErrorEvent.IO_ERROR , onIOError );
			loader = null;
			super.dispose();
		}
	}
}