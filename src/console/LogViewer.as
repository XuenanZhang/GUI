package console
{
	import UI.abstract.tween.TweenManager;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.net.LocalConnection;
	import flash.profiler.profile;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;

	/**
	 * 日志控制台
	 */
	public class LogViewer extends Sprite implements ILogAppender
	{
		private var _stage : Stage;

		private var _width : int;

		private var _height : int;

		private const HOTKEY : uint           = Keyboard.BACKQUOTE;

		/** 输入文本 **/
		private var _input : TextField;

		/** 输出界面 **/
		private var _outputBitmap : Bitmap;

		/** 图像字符集 **/
		private var _glyphCache : GlyphCache  = new GlyphCache();

		/** 不可输出列表 **/
		private var _dictDisable : Dictionary = new Dictionary();

		/** 日志内容缓存 **/
		private var _logCache : Array         = [];

		/** 输入历史记录 **/
		private var _inputHistory : Array     = [];

		private var _historyIndex : int;

		private var _enable : Boolean         = true;

		private var _dirty : Boolean;

		private var _tabPrefix : String       = "";

		private var _tabStart : int           = 0;

		private var _tabEnd : int             = 0;

		private var _tabOffset : int          = 0;

		private var _bottomLineIndex : int    = int.MAX_VALUE;

		public function LogViewer ( stage : Stage )
		{
			_stage = stage;
			_stage.addEventListener( KeyboardEvent.KEY_DOWN , onStageKeyDown );
			_stage.addEventListener( Event.RESIZE , resize );

			init();
		}

		private function init () : void
		{
			if ( !_input )
			{
				_input = new TextField();
				_input.type = TextFieldType.INPUT;
				_input.border = true;
				_input.borderColor = 0xcccccc;
				_input.multiline = false;
				_input.height = 18;
				_input.x = 5
				var format : TextFormat = new TextFormat();
				format.size = 12;
				format.color = 0xffffff;
				_input.defaultTextFormat = format;
				_input.setTextFormat( format );
				_input.addEventListener( KeyboardEvent.KEY_DOWN , onInputKeyDown );
				this.addChild( _input );
			}

			_outputBitmap = new Bitmap();
			this.addChild( _outputBitmap );

			doubleClickEnabled = true;
			this.addEventListener( MouseEvent.CLICK , onClick );
			this.addEventListener( MouseEvent.DOUBLE_CLICK , onDoubleClick );
			TweenManager.intervalCall( 0.1 , onFrame );
			_dirty = true;

			registerCommand();
		}

		private function registerCommand () : void
		{
			Console.registerCommand( "copy" , onDoubleClick , "复制内容到剪贴板" )
			Console.registerCommand( "clear" , onClearInfo , "清理历史记录" )
			Console.registerCommand( "enable" , onEnable , "enable loggerName：设置loggerName可输出" )
			Console.registerCommand( "disable" , onDisable , "disable loggerName：设置loggerName不可输出" )
			Console.registerCommand( "gc" , onGC , "释放内存" );
		}

		private function onStageKeyDown ( e : KeyboardEvent ) : void
		{
			if ( e.keyCode == HOTKEY )
			{
				if ( this.parent )
				{
					this.parent.removeChild( this );
					deactivate();
				}
				else
				{
					_stage.addChild( this );
					activate();
					onFrame();
					_input.restrict = "^" + String.fromCharCode( e.charCode );
				}
			}
			
			if ( e.keyCode == Keyboard.A )
			{
				Profiler.execute = true;
			}
			else
				Profiler.execute = false;
		}

		private function activate () : void
		{
			resize();
			_stage.focus = _input;
			_input.text = "";
		}

		private function deactivate () : void
		{
			_stage.focus = null;
		}

		private function onClick ( e : MouseEvent = null ) : void
		{
			_stage.focus = _input;
			e.stopImmediatePropagation();
		}

		private function onDoubleClick ( e : MouseEvent = null ) : void
		{
			e.stopImmediatePropagation();
		}

		private function onClearInfo () : void
		{
			_logCache = [];
			_bottomLineIndex = -1;
			_dirty = true;
		}

		private function onEnable ( loggerName : String = "" ) : void
		{
			if ( !loggerName )
			{
				_enable = true;
				return;
			}

			if ( _dictDisable[ loggerName ] )
				delete _dictDisable[ loggerName ];
		}

		private function onDisable ( loggerName : String = "" ) : void
		{
			if ( !loggerName )
			{
				_enable = false;
				return;
			}

			_dictDisable[ loggerName ] = true;
		}

		private  function onGC () : void
		{
			try
			{
				new LocalConnection().connect("GC");
				new LocalConnection().connect("GC");
			}
			catch ( e : Error )
			{
				
			}
			Logger.print(LogViewer, "gc complete..." );
		}
		
		private function onInputKeyDown ( e : KeyboardEvent ) : void
		{
			var key : uint = e.keyCode;
			if ( key != Keyboard.TAB && key != Keyboard.SHIFT )
			{
				_tabStart = -1;
				_tabOffset = 0;
			}

			var i : int = 0;
			switch ( key )
			{
				case Keyboard.ENTER:
					if ( _input.text.length > 0 )
					{
						processCommand();
					}
					break;
				case Keyboard.UP:
					if ( _historyIndex > 0 )
						setHistory( _inputHistory[ --_historyIndex ] );
					else if ( _inputHistory.length > 0 )
						setHistory( _inputHistory[ 0 ] )
					e.preventDefault();
					break;
				case Keyboard.DOWN:
					if ( _historyIndex < _inputHistory.length - 1 )
						setHistory( _inputHistory[ ++_historyIndex ] );
					else if ( _historyIndex == _inputHistory.length - 1 )
						_input.text == "";
					e.preventDefault();
					break;
				case Keyboard.PAGE_UP:

					if ( _bottomLineIndex == int.MAX_VALUE )
						_bottomLineIndex = _logCache.length - 1;

					_bottomLineIndex -= getViewMaxLines() - 2;

					if ( _bottomLineIndex < 0 )
						_bottomLineIndex = 0;
					break;
				case Keyboard.PAGE_DOWN:

					if ( _bottomLineIndex != int.MAX_VALUE )
					{
						_bottomLineIndex += getViewMaxLines() - 2;

						if ( _bottomLineIndex + getViewMaxLines() >= _logCache.length )
							_bottomLineIndex = int.MAX_VALUE;
					}
					break;
				case Keyboard.TAB:
					var list : Array      = Console.getCommandList();
					var isFirst : Boolean = false;

					if ( _tabStart == -1 )
					{
						_tabPrefix = _input.text.toLowerCase();
						_tabStart = int.MAX_VALUE;
						_tabEnd = -1;

						for ( i = 0 ; i < list.length ; i++ )
						{
							if ( String( list[ i ].name ).substr( 0 , _tabPrefix.length ).toLowerCase() == _tabPrefix )
							{
								if ( i < _tabStart )
									_tabStart = i;
								if ( i > _tabEnd )
									_tabEnd = i;

								isFirst = true;
							}
						}
					}

					_tabOffset = _tabStart;

					if ( _tabEnd != -1 )
					{
						if ( !isFirst )
						{
							if ( e.shiftKey )
								_tabOffset--;
							else
								_tabOffset++;

							if ( _tabOffset < _tabStart )
								_tabOffset = _tabEnd;
							else if ( _tabOffset > _tabEnd )
								_tabOffset = _tabStart;
						}

						var match : String = list[ _tabOffset ].name;
						_input.text = match;
						_input.setSelection( match.length + 1 , match.length + 1 );
					}
					break;
				case Keyboard.BACKQUOTE:
					onStageKeyDown( new KeyboardEvent( KeyboardEvent.KEY_DOWN , true , false , 0 , HOTKEY ) );
					break;
			}

			_dirty = true;
			e.stopImmediatePropagation();
		}

		/**
		 * 历史记录
		 */
		private function setHistory ( text : String ) : void
		{
			_input.text = text;
			_input.setSelection( _input.length , _input.length );
		}

		/**
		 * 当前最多容纳多少行
		 */
		private function getViewMaxLines () : int
		{
			var h : int = _outputBitmap.bitmapData.height;
			h = Math.floor( h / _glyphCache.getLineHeight() );
			return h;
		}

		private function onFrame () : void
		{
			if ( _dirty == false || parent == null )
				return;
			_dirty = false;

			var lines : int     = getViewMaxLines() - 1;
			var startLine : int = 0;
			var endLine : int   = 0;

			if ( _bottomLineIndex == int.MAX_VALUE )
				startLine = Math.max( _logCache.length - lines , 0 );
			else
				startLine = Math.max( _bottomLineIndex - lines , 0 );
			endLine = Math.min( Math.max( startLine + lines , 0 ) , _logCache.length - 1 );
//			startLine--;

			var bd : BitmapData = _outputBitmap.bitmapData;
			bd.fillRect( bd.rect , 0 );

			for ( var i : int = endLine ; i >= startLine ; i-- )
			{
				if ( !_logCache[ i ] )
					continue;

				_glyphCache.drawLineToBitmap( _logCache[ i ].text , 0 , _outputBitmap.height - ( endLine + 1 - i ) * _glyphCache.getLineHeight() - 1 , _logCache[ i ].
											  color , _outputBitmap.bitmapData );
			}
		}

		private function processCommand () : void
		{
			var str : String = _input.text;
			_input.text = "";
			addLogMessage( LogEntry.INPUT , ">" , str );
			Console.processCommand( str );
			//UiDebug.processCommand( str );
			_inputHistory.push( str );
			_historyIndex = _inputHistory.length;
			_dirty = true;
		}

		public function addLogMessage ( type : String , loggerName : String , message : String ) : void
		{
			if ( !_enable )
				return;

			if ( _dictDisable[ loggerName ] )
				return;

			var color : uint = LogColor.getColor( type );
			var index : int  = loggerName.lastIndexOf( "::" );
			if ( index != -1 )
				loggerName = loggerName.substr( index + 2 );
			var messages : Array = message.split( "\n" );
			for each ( var msg : String in messages )
			{
				var date : Date      = new Date(); //(date.hours / 100 ).toFixed(2).substr(2)
				var dateStr : String = "[" + date.hours + ":"
					+ date.minutes + ":"
					+ date.seconds + "."
					+ date.milliseconds + "] ";
				var text : String    = dateStr + ( type == LogEntry.INPUT ? "" : type + ": " ) + loggerName + " - " + message;
				_logCache.push( { color: color , text: text } );
			}

		}

		private function resize ( e : Event = null ) : void
		{
			_outputBitmap.x = 5;
			_outputBitmap.y = 0;

			if ( _stage )
			{
				_width = _stage.stageWidth;
				_height = _stage.stageHeight * 0.65;
			}

			if ( _outputBitmap.bitmapData )
				_outputBitmap.bitmapData.dispose();
			_outputBitmap.bitmapData = new BitmapData( _width - 10 , _height - _input.height - 10 , true , 0 );

			_input.width = _width - 10;

			_input.y = _height - _input.height - 5;

			this.graphics.clear();
			this.graphics.beginFill( 0 , 0.9 );
			this.graphics.drawRect( 0 , 0 , _width , _height );
			this.graphics.endFill();

			_dirty = true;
		}
	}
}
