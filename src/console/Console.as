package console
{
	/**
	 * 处理用户命令行
	 */
	public class Console
	{
		/** 命令集 **/
		protected static var _commands : Object = {};
		
		protected static var _commandSortList : Array = [];
		
		protected static var _sort : Boolean;
		
		public static const blank : String = "  ";
		
		/**
		 * 注册可以处理的命令
		 */
		public static function registerCommand ( name : String, callback : Function, docs : String = null ) : void
		{
			if ( !name )
			{
				Logger.error( Console, "registerCommand", "Command has no name!" );
				return;
			}
			
			if ( callback == null )
			{
				Logger.error( Console, "registerCommand", "Command " + name + " has no callback!" );
				return;
			}
				
			var c : ConsoleCommand = new ConsoleCommand();
			c.name = name;
			c.callback = callback;
			c.docs = docs;
			
			if ( _commands[name.toLowerCase()] )
				Logger.warn( Console, "registerCommand", "Command " + name + " 已经存在, 新命令替换已存在命令" );
			
			_commands[name.toLowerCase()] = c;
			_sort = true;
		}
		
		/**
		 * 处理命令信息
		 */
		public static function processCommand ( msg : String ) : void
		{
			if ( !_commands.help )
				registerCommand( "help", helpCommand, "帮助：显示所有已注册命令信息和其他快捷键信息" );
			
			var arr : Array = msg.split(" ");
			
			if ( !arr || arr.length == 0 )
				return;
			var cc : ConsoleCommand = _commands[arr[0].toString().toLowerCase()];
			
			if ( !cc )
			{
				Logger.warn( Console, "processCommand", "Unkonw command '" + arr[0].toString() + "'!" );
				return;
			}
			
			try
			{
				cc.callback.apply( null, arr.slice( 1 ) );
			}
			catch ( e : Error )
			{
				var errorStr : String = "Error：" + e.toString() + e.getStackTrace();
				Logger.error( Console, arr[0], errorStr );
			}
		}
		
		private static function helpCommand ( prefix : String = null ) : void
		{
			Logger.print( Console, "输入框快捷键:" );
			Logger.print(Console, blank + "UP : 上一条输入信息" );
			Logger.print(Console, blank + "DOWN : 下一条输入信息" );
			Logger.print(Console, blank + "PAGE_UP : 上一页信息" );
			Logger.print(Console, blank + "PAGE_DOWN : 下一页输入信息" );
			Logger.print(Console, blank + "TAB : 所有命令" );
			
			updateList();
			Logger.print( Console, "" );
			Logger.print( Console, "Commands:" );
			
			var cc : ConsoleCommand;
			for ( var i : int = 0; i < _commandSortList.length; i++ )
			{
				cc = _commandSortList[i];
				
				if ( prefix && prefix != cc.name.substr(0, prefix.length ) )
					continue;
				
				Logger.print( Console, blank + cc.name + " - " + (cc.docs ? cc.docs : "") );
			}
		}
		
		public static function getCommandList () : Array
		{
			updateList();
			return _commandSortList;
		}
		
		private static function updateList () : void
		{
			if ( !_sort ) return;
			_sort = false;
			
			_commandSortList.length = 0;
			for each ( var item : ConsoleCommand in _commands )
				_commandSortList.push( item );
				
			_commandSortList.sort( function ( a : ConsoleCommand, b : ConsoleCommand ) : int
			{
				if ( a.name > b.name )
					return 1;
				else
					return -1;
			});
		}
			
				
	}
}

class ConsoleCommand
{
	public var name : String;
	public var callback : Function;
	public var docs : String;
}