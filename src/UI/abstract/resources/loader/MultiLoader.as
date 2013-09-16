package UI.abstract.resources.loader
{
	import UI.abstract.resources.ResourceManager;
	import UI.abstract.resources.item.Resource;

	/**
	 * 多文件加载器
	 */
	public class MultiLoader
	{
		private var obj : Object;

		/** 当前未加载数量 **/
		private var currNum : int;

		private var _res : ResourceManager;

		/** 是否取消加载 **/
		private var isCanel : Boolean;
		
		private var _isComplete:Boolean = false;
		
		private var list:Array;

		public function MultiLoader ( res : ResourceManager , list : Array , obj : Object )
		{
			_res = res;
			currNum = list.length;
			this.obj = obj;
			this.list = list;
			

		}
		public function load():void{
			for ( var i : int = 0 ; i < list.length ; i++ )
				_res.load( list[ i ] , onComplete , { onField: onField } );
		}
		private function onComplete ( res : Resource ) : void
		{
			
			currNum--;
			if ( currNum == 0 )
			{
				_isComplete = true;
				if ( isCanel )
				{
					dispose();
					return;
				}
				//选回调，再移除
				if (obj && obj.onComplete )
				{
					obj.onComplete.apply( null , obj.onCompleteParam );
					_res.loadListOnComplete(obj.onComplete);
				}
				dispose();
			}

		}

		private function onField () : void
		{
			_isComplete = true;
			currNum--;
			//if ( currNum == 0 )
			//{
				if ( isCanel )
				{
					dispose();
					return;
				}
				//选回调，再移除
				if (obj && obj.onField )
				{
					obj.onField.apply(null , obj.onFieldParam);
				}
				if (obj && obj.onComplete )
				{
					_res.loadListOnComplete(obj.onComplete);
				}
				dispose();
			//}
		}

		public function canel () : void
		{
			isCanel = true;
		}

		public function dispose () : void
		{
			obj = null;
			_res = null;
			list.length = 0;
			//list = null;
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
