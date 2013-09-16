package console
{

	public class Sprintf
	{
		public static function format ( value : String , ... params ) : String
		{
			var result : String = "";

			var next : *;
			var str : String;
			var pastFlags : Boolean;
			var flagLeft : Boolean;
			var flagSpace : Boolean;
			var fieldWidth : String;

			var length : int    = value.length;
			for ( var i : int = 0 ; i < length ; i++ )
			{
				var c : String = value.charAt( i );

				if ( c == "%" )
				{
					pastFlags = false;
					flagLeft = false;
					flagSpace = false;
					fieldWidth = "";
					c = value.charAt( ++i );
					while ( c != "%" && c != "s" )
					{
						// 左边加空格
						if ( !pastFlags )
						{
							if ( !flagLeft && c == "-" ) 
								flagLeft = true;
							else
								pastFlags = true; 
						}

						if ( pastFlags )
						{
							fieldWidth += c;
						}
						c = value.charAt( ++i );
					}

					switch ( c )
					{
						case "i":
							break;
						case "f":
							break;
						case "s":
							next = params.shift();
							str = String( next );

							if ( fieldWidth != "" )
							{
								if ( flagLeft )
									str = leftPad( str , int( fieldWidth ) )
								else
									str = rightPad( str , int( fieldWidth ) );
							}

							result += str;
							break;
						case "%":
							result += c;
							break;
					}
				}
				else
					result += c;
			}

			return result;
		}

		private static function leftPad ( source : String , targetLen : int , padChar : String = " " ) : String
		{
			if ( source.length < targetLen )
			{
				var padding : String = "";
				while ( padding.length + source.length < targetLen )
					padding += padChar;
				return padding + source;
			}
			return source;
		}

		private static function rightPad ( source : String , targetLen : int , padChar : String = " " ) : String
		{
			while ( source.length < targetLen )
				source += padChar;

			return source;
		}
	}
}
