package console
{
	import flash.display.Stage;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	/**
	 * 日志管理类
	 */
	public class Logger
	{
		/** 所有监听信息日志记录类 **/
		private static var _listeners : Vector.<ILogAppender> = new Vector.<ILogAppender>();

		/** 是否启动 **/
		private static var _started : Boolean;

		/** 未进行显示的 **/
		private static var _pendingEntries : Array            = [];

		/** 是否可用 **/
		private static var _enable : Boolean;

		/**
		 * 初始化日志记录类
		 */
		public static function startup ( stage : Stage ) : void
		{
			registerListerner( new LogViewer( stage ) );

			_enable = true;
			_started = true;

			for ( var i : int = 0 ; i < _pendingEntries.length ; i++ )
				processEntry( _pendingEntries[ i ] );

			_pendingEntries.length = 0;
			_pendingEntries = null;
			
			UiDebug.init(stage);
		}

		/**
		 * 注册日志记录类
		 */
		public static function registerListerner ( listener : ILogAppender ) : void
		{
			_listeners.push( listener );
		}

		/**
		 * 输出日志记录，默认MESSAGE级别
		 */
		public static function print ( reporter : * , message : String ) : void
		{
			custom( LogEntry.MESSAGE , reporter , "" , message );
		}

		/**
		 * 输出日志记录，默认INFO级别
		 */
		public static function info ( reporter : * , method : String , message : String ) : void
		{
			custom( LogEntry.INFO , reporter , method , message );
		}

		/**
		 * 输出日志记录，默认DEBUG级别
		 */
		public static function debug ( reporter : * , method : String , message : String ) : void
		{
			custom( LogEntry.DEBUG , reporter , method , message );
		}

		/**
		 * 输出日志记录，默认WARN级别
		 */
		public static function warn ( reporter : * , method : String , message : String ) : void
		{
			custom( LogEntry.WARNING , reporter , method , message );
		}

		/**
		 * 输出日志记录，默认ERROR级别
		 */
		public static function error ( reporter : * , method : String , message : String ) : void
		{
			custom( LogEntry.ERROR , reporter , method , message );
		}

		/**
		 * 自定义级别
		 */
		public static function custom ( type : String , reporter : * , method : String , message : String ) : void
		{
			if ( !_enable )
				return;

			var entry : LogEntry = new LogEntry();
			entry.type = type;
			entry.reporter = getDefinitionByName( getQualifiedClassName( reporter ) ) as Class;
			entry.method = method;
			entry.message = method ? method + " - " + message : message;
			processEntry( entry );
		}

		/**
		 * 处理条目
		 */
		private static function processEntry ( entry : LogEntry ) : void
		{
			if ( !_enable )
				return;

			if ( !_started )
			{
				_pendingEntries.push( entry );
				return;
			}

			for ( var i : int = 0 ; i < _listeners.length ; i++ )
				_listeners[ i ].addLogMessage( entry.type , getQualifiedClassName( entry.reporter ) , entry.message );
		}
	}
}
