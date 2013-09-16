package UI.abstract.resources.item
{
	import UI.abstract.resources.loader.BaseLoader;

	public class XmlResource extends Resource
	{
		public function XmlResource()
		{
			super();
		}
		override public function initialize ( data : BaseLoader ) : void
		{
			super.initialize( data );
			_content = XML(data.content);
		}
		/**
		 * 获取bitmapData
		 */
		public function get xml () : XML
		{
			return _content ? (content as XML) : null;
		}
		override public function dispose():void
		{
			
			if ( _content )
			{
				_content = null;
			}
			super.dispose();
		}
	}
}