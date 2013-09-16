package UI.abstract.resources.item
{
	import UI.abstract.resources.ResourceManager;
	import UI.abstract.resources.ResourceUtil;
	
	import flash.utils.ByteArray;

	public class LoadObj
	{
		public var url : String;

		/** 扩展类型 **/
		public var extension : String;

		/** 所有回调函数等列表 **/
		private var list : Array              = [];

		private var res : ResourceManager;
		
		private var _isComplete:Boolean = false;
		
		/**二级制**/
		public var byteArray:ByteArray;
		
		public function LoadObj (  res : ResourceManager )
		{
			this.res = res;
		}

		public function push ( obj : Object ) : void
		{
			//如果没有onComplete不放入数组，减少循环次数
			if(obj.onComplete){
				list.push( obj );
			}
		}
		
		/**
		 * 取消加载回调函数
		 * 返回true 代表列表已经没有回调函数
		 */
		public function canel ( fun : Function ) : Boolean
		{
			for ( var i : int = 0; i < list.length; i++ )
			{
				if ( list[i].onComplete == fun )
				{
					list.splice( i, 1 );
					break;
				}
			}
			if ( list.length == 0 )
				return true; 
			else
				return false;
		}

		/**
		 * 完成回调
		 */
		public function onComplete () : void
		{
			_isComplete = true;
			for ( var i : int = 0 ; i < list.length ; i++ )
			{
				if ( list[ i ].onComplete ){
					if(list[ i ].propName){
						var imageAtlasResource:ImageAtlasResource = res.getResource( ResourceManager.unFormatResourceName( url ) ) as ImageAtlasResource;
						switch(list[ i ].propName){
							case ResourceUtil.IMAGE:
								if(res.getResource( ResourceManager.unFormatResourceName( url+"?"+ResourceUtil.IMAGE+"="+list[ i ].prop ))){
									list[ i ].onComplete.apply( null , [ res.getResource( ResourceManager.unFormatResourceName( url+"?"+ResourceUtil.IMAGE+"="+list[ i ].prop )) ] );
								}else{
									list[ i ].onComplete.apply( null , [ imageAtlasResource.getTexture(list[ i ].prop) ] );
								}
								
								break;
							case ResourceUtil.MC:
								if(res.getResource( ResourceManager.unFormatResourceName( url+"?"+ResourceUtil.MC+"="+list[ i ].prop ))){
									list[ i ].onComplete.apply( null , [ res.getResource( ResourceManager.unFormatResourceName( url+"?"+ResourceUtil.MC+"="+list[ i ].prop )) ] );
								}else{
									list[ i ].onComplete.apply( null , [ imageAtlasResource.getTextures(list[ i ].prop) ] );
								}
								break;
							default:
								list[ i ].onComplete.apply( null , [ null ] );
								break;
						}
						
					}else{
						list[ i ].onComplete.apply( null , [ res.getResource( ResourceManager.unFormatResourceName( url ) ) ] );
					}
				}
					
			}
			list.length = 0;
		}


		/**
		 * 加载错误回调
		 */
		public function onField () : void
		{
			_isComplete = true;
			for ( var i : int = 0 ; i < list.length ; i++ )
			{
				if ( list[ i ].onField )
					list[ i ].onField.apply();
			}
			list.length = 0;
		}

		public function dispose () : void
		{
			list.length = 0;
			list = null;
			res = null;
			if(byteArray){
				byteArray.clear();
				byteArray = null;
			}
		}
		/**
		 * 是否处于完成回调状态，如果是外部就不调用这个类的方法
		 */
		public function get isComplete():Boolean
		{
			return _isComplete;
		}

	}
}
