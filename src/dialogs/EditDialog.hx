package dialogs;

import haxe.ui.components.TextArea;
import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.containers.Box;
import haxe.ui.containers.ListView;
import haxe.ui.components.TextField;
import haxe.ui.components.DropDown;
import haxe.ui.components.Label;
import haxe.ui.components.Button;
import haxe.ui.core.Component;
import haxe.ui.events.UIEvent;

/**
 * ...
 * @author WSandwitch
 */
@:build(haxe.ui.macros.ComponentMacros.build("assets/edit-dialog.xml"))
class EditDialog extends Dialog {
	var _item:Note;
	public static var HISTORY:String = "History";
	
	public var saveCallback:Note->Void;
	public var removeCallback:Int->Void;
	
    public function new(i:Note) {
        super();
		_item = i;
        title = "Edit";
        buttons = HISTORY | (DialogButton.SAVE | DialogButton.CANCEL);// | "Custom Button" | DialogButton.APPLY;
//		if (i.id != null)
//			buttons = _removeButton | buttons;

		cast(findComponent("edate"), DropDown).value = i.date;
		cast(findComponent("etext"), TextArea).text = i.text;
		findComponent("ehour").value = i.date.getHours();
		findComponent("eminute").value = i.date.getMinutes();
		cast(findComponent("groupsb"), Button).onClick = function (e:Dynamic){
			var ud = new GroupsDialog(i);
			ud.saveCallback = function () {
				updateGroup(i);
			};
			ud.showDialog();
		};
		updateGroup(i);
//		trace(findComponent("group"));
//		cast(findComponent("groupsb"), Button).onClick = function (e:Dynamic){
//			var gd = new GroupsDialog(i);
//			gd.showDialog();
//		};
		
		onDialogClosed = function(e:DialogEvent) {
			if (e.button == DialogButton.SAVE){
				var ed:EditDialog = cast e.target;
				var date=cast(ed.findComponent("edate"), DropDown).value;
				i.date = new Date(date.getFullYear(), date.getMonth(), date.getDate(), ed.findComponent("ehour").value, ed.findComponent("eminute").value, Date.now().getSeconds());
				i.save();
				i.text = ed.findComponent("etext").text;
				saveCallback(i);
			}
			if (e.button == DialogButton.CANCEL){
				saveCallback(i);
			}
			if (e.button == HISTORY){
				new NoteHistoryDialog(_item).showDialog();
			}		
		}
    }
	
	function updateGroup(i:Note){
		cast(findComponent("egroup"), Label).text = i.group.name;
	}
}
