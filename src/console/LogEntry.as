package console
{

	/**
	 * 日志记录条目
	 */
	public class LogEntry
	{

		/**
		 * 日志类型：用户输入
		 */
		public static const INPUT : String   = "Input";

		/**
		 * 日志类型：错误
		 */
		public static const ERROR : String   = "Error";

		/**
		 * 日志类型：警告
		 */
		public static const WARNING : String = "Warning";

		/**
		 * 日志类型：调试
		 */
		public static const DEBUG : String   = "Debug";

		/**
		 * 日志类型：信息
		 */
		public static const INFO : String    = "Info";

		/**
		 * 日志类型：普通消息
		 */
		public static const MESSAGE : String = "Message";

		/**
		 * 日志发送者
		 */
		public var reporter : Class          = null;

		/**
		 * 日志发出的方法
		 */
		public var method : String           = "";

		/**
		 * 日志消息
		 */
		public var message : String          = "";

		/**
		 * 日志类型
		 */
		public var type : String             = null;

		/**
		 * 日志级别
		 */
		public var depth : int               = 0;

		/**
		 * 完整日志信息
		 */
		public function get foramatMessage () : String
		{
			var strDepth : String = "";
			for ( var i : int = 0 ; i < depth ; i++ )
				strDepth += "  ";

			var strReporter : String = "";
			if ( reporter )
				strReporter = reporter + ": ";

			var strMethod : String = "";
			if ( method )
				strMethod = method + " - ";

			return strDepth + strReporter + method + message;
		}
	}
}
