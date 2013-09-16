package UI.abstract.resources.item
{
	import UI.App;
	import UI.abstract.resources.loader.BaseLoader;

	public class ImageArrayResource extends Resource
	{
		public var _imageArray:Vector.<ImageResource>;
		public function ImageArrayResource()
		{
			super();
		}
		override public function set content (data:*):void{
			_content = data;
			_imageArray = _content;
			for(var i:int = 0;i<_imageArray.length;i++){
				App.loader.addUseNumber( _imageArray[i] );
			}
			_content = null;
		}
		override public function dispose():void
		{
			if(_imageArray){
				for(var i:int = 0;i<_imageArray.length;i++){
					App.loader.subtractUseNumber( _imageArray[i] );
				}
				_imageArray.length = 0;
				_imageArray = null;
			}
			
			
		}
	}
}