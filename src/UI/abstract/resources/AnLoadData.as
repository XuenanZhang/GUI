package UI.abstract.resources
{
	import flash.utils.Dictionary;
	
	public dynamic class AnLoadData
	{
		public var content:Object;
		
		public var name:String;	//名字
		public var category:String;	//种类
		public var loaded:Boolean = false;;
		public var loadings:int = 0;
		public var ready:Boolean = false;
		public var ref:int = 0;
		public var priority:int = 0;
		public var preload:Boolean = false;
		public var x:int = - AnConst.PEOPLE_WIDTH / 2;
		public var y:int = - AnConst.PEOPLE_HEIGHT;
		public var loadedMap:Dictionary=new Dictionary();//已经请求加载
		public var readyMap:Dictionary=new Dictionary();//已经加载完成
		public function AnLoadData(category:String, name:String, priority:int=0)
		{
			this.name = name;
			this.category = category;
			this.priority = priority;
		}
	}
}