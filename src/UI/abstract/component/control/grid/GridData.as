package UI.abstract.component.control.grid
{

	public class GridData
	{
		/** 格子基础图像地址 **/
		public var imageUrl : String = "";

		/** 数量 **/
		public var num : int;


		/**
		 * 复制数据
		 */
		public function clone () : GridData
		{
			var obj : GridData = new GridData();
			obj.imageUrl = imageUrl;
			obj.num = num;
			return obj;
		}

		/**
		 * 还原为初始化状态
		 */
		public function clear () : void
		{
			imageUrl = "";
			num = 0;
		}
		/**
		 * 是否有数据可以拖动
		 */
		public function isDrog () : Boolean
		{
			return Boolean( imageUrl );
		}
	}
}
