package console
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;

	import flashx.textLayout.formats.TextAlign;

	public class GlyphCache
	{
		private var _textFormat : TextFormat;

		private var _textField : TextField;

		private var _colorDict : Dictionary = new Dictionary();

		private var _glyphDict : Dictionary = new Dictionary();

		public function GlyphCache ()
		{
			_textFormat = new TextFormat( "_typewriter" , 12 );
			_textField = new TextField();
			_textField.setTextFormat( _textFormat );
			_textField.defaultTextFormat = _textFormat;
		}

		public function drawLineToBitmap ( line : String , x : int , y : int , color : uint , renderTarget : BitmapData ) : int
		{
			if ( !_colorDict[ color ] )
				_colorDict[ color ] = new BitmapData( 128 , 128 , false , color );
			var colorData : BitmapData = _colorDict[ color ];
			var curPos : Point         = new Point( x , y );
			var lines : int            = 1;
			var count : int            = line.length;
			var glyph : Glyph;
			for ( var i : int = 0 ; i < count ; i++ )
			{
				var char : Number = line.charCodeAt( i );

				if ( char == 10 )
				{
					curPos.x = x;
					curPos.y += getLineHeight();
					lines++;
					continue;
				}
				glyph = getGlyph( char );
				renderTarget.copyPixels( colorData , glyph.rect , curPos , glyph.bitmapData , null , true );

				curPos.x += glyph.rect.width - 1;
			}
			return lines;
		}

		private function getGlyph ( charCode : Number ) : Glyph
		{
			if ( _glyphDict[ charCode ] == null )
			{
				var newGlyph : Glyph = new Glyph();
				var h : int          = getLineHeight()
				_textField.text = String.fromCharCode( charCode );

				newGlyph.bitmapData = new BitmapData( _textField.textWidth + 2 , h + 1 , true , 0 );
				newGlyph.bitmapData.draw( _textField );
				newGlyph.rect = newGlyph.bitmapData.rect;

				_glyphDict[ charCode ] = newGlyph;
			}

			return _glyphDict[ charCode ] as Glyph;
		}

		public function getLineHeight () : int
		{
			_textField.text = "A";
			return _textField.textHeight;
		}
	}
}
import flash.display.BitmapData;
import flash.geom.Rectangle;

class Glyph
{
	public var rect : Rectangle;

	public var bitmapData : BitmapData;
}
