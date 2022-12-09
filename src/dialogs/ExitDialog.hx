package dialogs;

import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.containers.Box;
import haxe.ui.containers.ListView;
import haxe.ui.components.TextField;
import haxe.ui.components.CheckBox;
import haxe.ui.components.DropDown;
import haxe.ui.components.Button;
import haxe.ui.core.Component;
import haxe.ui.events.UIEvent;

/**
 * ...
 * @author WSandwitch
 */
@:build(haxe.ui.macros.ComponentMacros.build("assets/exit-dialog.xml"))
class ExitDialog extends Dialog {
		
    public function new(cb:Void->Void) {
        super();
		title = "Exit";
		cast(findComponent("exitb"), Button).onClick = function (e:Dynamic){
			openfl.system.System.exit(0);
		};
		
		onDialogClosed = function(e:DialogEvent) {
			cb();
		}
	}
}

