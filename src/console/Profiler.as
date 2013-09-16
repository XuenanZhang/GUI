package console
{
	import flash.profiler.profile;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;

	public class Profiler
	{
		public static var enable : Boolean          = false;

		public static var nameFieldWidth : int      = 70;

		public static var indentAmount : int        = 3;

		private static var _reallyEnabled : Boolean = true;

		private static var _wantReport : Boolean    = false;

		private static var _wantWipe : Boolean      = false;

		private static var _stackDepth : int        = 0;

		private static var _rootNode : ProfileInfo;

		private static var _currentNode : ProfileInfo;

		private static var _execute : Boolean;
		
		/**
		 * 执行分析处理
		 */
		public static function set execute ( value : Boolean ) : void
		{
			_execute = value;
		}
		

		/**
		 * 开始分析
		 */
		public static function enter ( blockName : String ) : void
		{
			if ( !CONFIG::debug )
				return;

			if ( !_currentNode )
			{
				_rootNode = new ProfileInfo( "Root" );
				_currentNode = _rootNode;
			}

			// 堆栈开始
			if ( _stackDepth == 0 )
			{
				if ( _execute )
				{
					if ( !enable )
					{
						_wantWipe = true;
						enable = true;
					}
				}
				else
				{
					if ( enable )
					{
						_wantReport = true;
						enable = false;
					}
				}

				_reallyEnabled = enable;

				if ( _wantWipe )
					doWipe();

				if ( _wantReport )
					doReport();
			}

			_stackDepth++;
			if ( !_reallyEnabled )
				return;

			var newNode : ProfileInfo = _currentNode.children[ blockName ];
			if ( !newNode )
			{
				newNode = new ProfileInfo( blockName , _currentNode );
				_currentNode.children[ blockName ] = newNode;
			}

			// 入栈
			_currentNode = newNode;

			_currentNode.startTime = getTimer();
		}

		/**
		 * 退出分析
		 */
		public static function exit ( blockName : String ) : void
		{
			if ( !CONFIG::debug )
				return;

			_stackDepth--;
			if ( !_reallyEnabled )
				return;

			if ( blockName != _currentNode.name )
				throw new Error( "当前退出栈名 " + blockName + " 不等于应该退出的栈名 " + _currentNode.name )

			// 更新统计
			var elapsedTime : int = getTimer() - _currentNode.startTime;
			_currentNode.activations++;
			_currentNode.totalTime += elapsedTime;
			if ( elapsedTime > _currentNode.maxTime )
				_currentNode.maxTime = elapsedTime;
			if ( elapsedTime < _currentNode.minTime )
				_currentNode.minTime = elapsedTime;

			_currentNode = _currentNode.parent;
		}

		private static function doWipe ( pi : ProfileInfo = null ) : void
		{
			_wantWipe = false;

			if ( !pi )
			{
				doWipe( _rootNode );
				return;
			}

			pi.wipe();
			for each ( var childPi : ProfileInfo in pi.children )
				doWipe( childPi );
		}

		private static function doReport () : void
		{
			_wantReport = false;

			var header : String = Sprintf.format( "%" + nameFieldWidth + "s%8s%8s%8s%8s%8s%8s%12s" , "Name" , "Num" , "Total%" , "NonSub%" , "AvgMs" ,
												  "MinMs" , "MaxMs" , "TotMs" );
			Logger.print( Profiler , header );
			print( _rootNode , 0 ); 
		}

		private static function print ( pi : ProfileInfo , indent : int ) : void
		{
			//排除子项后 自己所花费的时间
			var selfTime : Number      = pi.totalTime;
			var totalTime : Number     = 0;
			var hasChildrens : Boolean = false;

			for each ( var childPi : ProfileInfo in pi.children )
			{
				hasChildrens = true;
				selfTime -= childPi.totalTime;
				totalTime += childPi.totalTime;
			}

			//整个统计过程时间
			if ( pi.name == "Root" ) 
				pi.totalTime = totalTime;

			//自己及其子项占整个过程时间百分比
			var displayTime : Number = -1; 
			if ( pi.parent )
				displayTime = pi.totalTime / _rootNode.totalTime * 100;

			// 自己占整个过程百分比
			var displaySelfTime : Number = -1;
			if ( pi.parent )
				displaySelfTime = selfTime / _rootNode.totalTime * 100;

			var entry : String = null;
			if ( indent == 0 )
			{
				entry = "-Root"; 
			}
			else
			{
				entry = Sprintf.format( "%-" + ( indent * indentAmount ) + "s%" + ( nameFieldWidth - indent * indentAmount ) + "s%8s%8s%8s%8s%8s%8s%12s" ,
										hasChildrens ? "-" : "" , pi.name , pi.activations , displayTime.toFixed( 2 ) , displaySelfTime.toFixed( 2 ) , 
										Number( pi.totalTime / pi.activations ).toFixed( 1 ) , pi.minTime , pi.maxTime , pi.totalTime );
			}
			Logger.print( Profiler , entry ); 

			var tmpArray : Array = [];
			for each ( childPi in pi.children )   
				tmpArray.push( childPi );
			tmpArray.sortOn( "totalTime" , Array.NUMERIC | Array.DESCENDING );
			for each ( childPi in tmpArray )
				print( childPi , indent + 1 );
		}
	}
}

class ProfileInfo
{
	public var name : String;

	public var children : Object = {};

	public var parent : ProfileInfo;

	public var startTime : int;

	public var totalTime : int;

	public var activations : int;

	public var maxTime : int     = int.MIN_VALUE;

	public var minTime : int     = int.MAX_VALUE;

	public function ProfileInfo ( name : String , parent : ProfileInfo = null )
	{
		this.name = name;
		this.parent = parent;
	}

	public function wipe () : void
	{
		startTime = totalTime = activations = 0;
		maxTime = int.MIN_VALUE;
		minTime = int.MAX_VALUE;
	}
}
