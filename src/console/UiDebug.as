package console
{
	import UI.abstract.component.control.base.UIComponent;
	import UI.theme.defaulttheme.button.Button;
	import UI.theme.defaulttheme.list.List;
	
	import avmplus.getQualifiedClassName;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;

	/**
	 * ui专用 指令集
	 *
	 * 字符串规则: 以下数据中间用空格隔开
	 * 1、ui 开头
	 * 2、id 操作组件id
	 * 3、操作命令：
	 * 	  创建组件: create 类名
	 * 	  移出组件: remove
	 * 	  设置ui属性值: set 属性 value
	 * 	  输出ui属性值: get 属性
	 * 	  调用函数: fun 函数名 参数（用空格隔开）
	 */
	public class UiDebug
	{
		/** ui组件映射 **/
		private static var _dict : Dictionary = new Dictionary();

		/** ui类名映射 **/
		private static var _classDict : Dictionary;

		public static var _parent : DisplayObjectContainer;

		private static var _isInit : Boolean;
		
		public static function init ( parent : DisplayObjectContainer ) : void
		{
			if ( !_isInit )
			{
				_isInit = true;
				Console.registerCommand( "ui" , onUI , "操作ui组件专用命令,详细用法参考 ui help" );
			}
			_parent = parent;
		}
		
		private static function onUI ( ...params ) : void
		{
			if ( !params || params.length == 0 ) return;
			processCommand(params.splice("") );
		}
		
		public static function save ( id : int, obj : Object) : void
		{
			if ( _dict[id] )
			{
				Logger.warn( UiDebug , "processCommand" , "id " + id + " 已经存在" );
				return;
			}
			_dict[id] = obj;
		}
		
		/**
		 * 处理命令
		 *
		 */
		public static function processCommand ( value : String ) : void
		{
			if ( !value )
				return;
			var arr : Array = value.split( "," );
			if ( arr[ 0 ] == "help" )
			{
				Logger.print( UiDebug , "字符串规则: 以下数据中间用空格隔开" );
				Logger.print( UiDebug , "1、ui 开头" );
				Logger.print( UiDebug , "2、id 操作组件id" );
				Logger.print( UiDebug , "3、操作命令：" );
				Logger.print( UiDebug , "   创建组件: create 类名" );
				Logger.print( UiDebug , "   移出组件: remove" );
				Logger.print( UiDebug , "   设置ui属性值: set 属性 value" );
				Logger.print( UiDebug , "   输出ui属性值: get 属性" );
				Logger.print( UiDebug , "   调用函数: fun 函数名 参数（用空格隔开）" );
				return;
			}

			try
			{
				var id : int = arr[0];
				var ui : Object = _dict[ id ];

				if ( arr[ 1 ] != "create" && !ui )
				{
					Logger.warn( UiDebug , "processCommand" , "id " + id + " 不存在" );
					return;
				}
				switch ( arr[ 1 ] )
				{
					case "create":
						if ( ui )
						{
							Logger.warn( UiDebug , "processCommand" , "id " + id + " 已经存在" );
							return;
						}
						var c : Class = getClass( arr[ 2 ] );
						ui = new c();
						if ( ui is DisplayObject )
							_parent.addChild( ui as DisplayObject );
						_dict[ id ] = ui;
						break;
					case "remove":
						ui = _dict[ id ];
						ui.dispose();
						delete _dict[ id ];
						break;
					
					case "set":
						ui[ arr[ 2 ] ] = arr[ 3 ];
						break;
					case "get":
						Logger.print( UiDebug , arr[ 2 ] + " = " + ui[ arr[ 2 ] ] );
						break;
					case "fun":
						ui[ arr[ 2 ] ].apply( null , arr.slice( 3 ) );
						break;
					default:
						Logger.warn( UiDebug , "processCommand" , "No such command '" + arr[ 1 ].toString() + "'!" );
						break;
				}

			}
			catch ( e : Error )
			{
				var errorStr : String = "Error：" + e.toString() + e.getStackTrace();
				Logger.error( UiDebug , "processCommand" , errorStr );
			}

		}

		private static function getClass ( str : String ) : Class
		{
			if ( !_classDict )
			{
				_classDict = new Dictionary();
				_classDict[ "button" ] = Button;
				_classDict[ "list" ] = List;
			}

			if ( _classDict[ str.toLowerCase() ] )
				return _classDict[ str.toLowerCase() ];
			else
				return getDefinitionByName( str ) as Class;
		}
	}
}
