package UI.abstract.resources.loader
{
	import UI.abstract.resources.item.LoadObj;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	public class JtasLoader extends BaseLoader
	{
		private var loader : Loader;
		public function JtasLoader(loadObj:LoadObj)
		{
			super(loadObj);
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener( Event.COMPLETE , onComplete );
			loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR , onIOError );
		}
		override public function load () : void
		{
			loader.loadBytes(  loadObj.byteArray  );
		}
		
		override protected function onComplete ( event : Event ) : void
		{
			_content = Bitmap(loader.content).bitmapData;
			dispatchEvent( new Event( Event.COMPLETE ) );
		}
		
		override protected function onIOError ( event : IOErrorEvent ) : void
		{
			dispatchEvent( new IOErrorEvent( IOErrorEvent.IO_ERROR ) );
		}
		
		override public function dispose () : void
		{
			
			loader.contentLoaderInfo.removeEventListener( Event.COMPLETE , onComplete );
			loader.contentLoaderInfo.removeEventListener( IOErrorEvent.IO_ERROR , onIOError );
			loader.unloadAndStop(false);
			loader.unload();
			loader = null;
			super.dispose();
		}
	}
}