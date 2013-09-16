package console
{

	public class LogColor
	{
		public static const DEBUG : uint   = 0xDDDDDD;

		public static const INFO : uint    = 0xCCCCCC;

		public static const WARNING : uint = 0xFF6600;

		public static const ERROR : uint   = 0xFF0000;

		public static const MESSAGE : uint = 0x00DD00;

		public static const INPUT : uint   = 0xFFFFFF;

		public static function getColor ( type : String ) : uint
		{
			switch ( type )
			{
				case LogEntry.DEBUG:
					return DEBUG;
				case LogEntry.INFO:
					return INFO;
				case LogEntry.WARNING:
					return WARNING;
				case LogEntry.ERROR:
					return ERROR;
				case LogEntry.MESSAGE:
					return MESSAGE;
				case LogEntry.INPUT:
					return INPUT;
				default:
					return MESSAGE;
			}
		}
	}
}
