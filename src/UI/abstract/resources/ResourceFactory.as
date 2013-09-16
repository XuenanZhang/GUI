package UI.abstract.resources
{
	import UI.abstract.resources.item.BinaryResource;
	import UI.abstract.resources.item.ImageAtlasResource;
	import UI.abstract.resources.item.ImageResource;
	import UI.abstract.resources.item.JtaResource;
	import UI.abstract.resources.item.LoadObj;
	import UI.abstract.resources.item.MCResource;
	import UI.abstract.resources.item.Resource;
	import UI.abstract.resources.item.XmlResource;
	import UI.abstract.resources.loader.BaseLoader;
	import UI.abstract.resources.loader.BinaryLoader;
	import UI.abstract.resources.loader.ImageAtlasLoader;
	import UI.abstract.resources.loader.ImageLoader;
	import UI.abstract.resources.loader.JtaLoader;
	import UI.abstract.resources.loader.JtasLoader;
	import UI.abstract.resources.loader.MCLoader;
	import UI.abstract.resources.loader.XmlLoader;
	
	public class ResourceFactory
	{
		/** 加载器类映射 **/
		private static var loaderClass : Object       = {
			png: ImageLoader ,
			jpg: ImageLoader ,
			gif: ImageLoader ,
			jpeg: ImageLoader ,
			swf: MCLoader ,
			xml: XmlLoader ,
			atlas:ImageAtlasLoader,
			jta:JtaLoader,
			jtas:JtasLoader};
		
		/** 资源类映射 **/
		private static var resourceClass : Object     = {
			png: ImageResource ,
			jpg: ImageResource ,
			gif: ImageResource ,
			jpeg: ImageResource ,
			swf: MCResource ,
			xml: XmlResource ,
			atlas:ImageAtlasResource,
			jta:JtaResource,
			jtas:ImageResource};
		
		
		/**
		 * 检测类型
		 */
		public static function checkType ( url : String ) : String
		{
			var str : String = url.substr( url.lastIndexOf( "." ) + 1 );
			if(str.indexOf("?") != -1){
				str = str.substring(0,str.indexOf("?"));
			}
			return str.toLowerCase();
		}
		
		/**
		 * 创建加载器类
		 */
		public static function createLoader ( loadObj : LoadObj ) : BaseLoader
		{
			if ( loaderClass[ loadObj.extension ] == null )
				return new BinaryLoader( loadObj );
			return new loaderClass[ loadObj.extension ]( loadObj );
		}
		
		/**
		 * 创建资源类
		 */
		public static function createResource ( loadObj : LoadObj ) : Resource
		{
			if ( resourceClass[ loadObj.extension ] == null )
				return new BinaryResource();
			return new resourceClass[ loadObj.extension ]();
		}
	}
}