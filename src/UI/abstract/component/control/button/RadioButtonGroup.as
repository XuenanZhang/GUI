package UI.abstract.component.control.button
{
	import UI.abstract.component.control.base.UIComponent;
	import UI.abstract.component.event.RadioButtonGroupEvent;

	public class RadioButtonGroup extends TriggerButtonGroup
	{
		protected var _selectedButton : ITriggerButton;

		

		public function RadioButtonGroup ()
		{
			super();
		}

		/**
		 * 选择一个按钮
		 */
		public function set selected ( button : ITriggerButton ) : void
		{
			if ( button != _selectedButton )
			{
				if ( _selectedButton != null )
				{
					ITriggerButton( _selectedButton ).selected = false;
				}
				_selectedButton = button;
				if(_selectedButton){
					_selectedButton.selected = true;
				}

				
				

				dispatchEvent( new RadioButtonGroupEvent( RadioButtonGroupEvent.SELECTED , _selectedButton ) );
			}
		}

		/**
		 * 当前选择的按钮
		 */
		public function get selected () : ITriggerButton
		{
			return _selectedButton;
		}

		/**
		 * 重置 取消所有选择
		 */
		public function reset () : void
		{
			if ( _selectedButton != null )
			{
				ITriggerButton( _selectedButton ).selected = false;
				_selectedButton = null;
			}
		}

		override public function dispose () : void
		{
			_selectedButton = null;
			super.dispose();
			
		}
	}
}
