package console
{
	/**
	 * 日志记录类
	 */
	public interface ILogAppender
	{
		function addLogMessage ( type :String, loggerName : String, message : String ) : void;
	}
}