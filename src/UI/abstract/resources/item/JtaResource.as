package UI.abstract.resources.item
{
	import UI.App;
	import UI.abstract.resources.ResourceUtil;
	import UI.abstract.resources.loader.BaseLoader;
	
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;

	public class JtaResource extends Resource
	{
		public function JtaResource()
		{
			super();
		}
		
		override public function initialize ( data : BaseLoader ) : void
		{
			super.initialize( data );
			
		}
		
		override public function dispose():void
		{
			for each ( var res : Object in _content )
			{
				if(res is Object && res.hasOwnProperty("dirCount")){
					for(var i:int = 1;i<=res["dirCount"];i++){
						var obj:Object = res["dirData"][i];
						for(var j:int = 0;j<obj["frames"].length;j++){
							App.loader.subtractUseNumber(obj["frames"][j]["imageResource"]);
							obj["frames"][j]["imageResource"] = null;
							
						}
						
					}
				}
				
			}
			
			super.dispose();
		}
	}
}