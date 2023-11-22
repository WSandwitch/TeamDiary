package dialogs;

import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.containers.Box;
import haxe.ui.containers.ListView;
import haxe.ui.components.CheckBox;
import haxe.ui.components.TextField;
import haxe.ui.components.DropDown;
import haxe.ui.components.Button;
import haxe.ui.core.Component;
import haxe.ui.events.UIEvent;

/**
 * ...
 * @author WSandwitch
 */
@:build(haxe.ui.macros.ComponentMacros.build("assets/groups-dialog.xml"))
class GroupsDialog extends Dialog {
	var _item:Null<Note>;
	
	public var saveCallback:Null<Void->Void>=null;
	public var removeCallback:Int->Void;
	
    public function new(i:Null<Note>=null) {
        super();
		_item = i;
		title = i == null ? "Edit":"Select" +" groups";
		
		if (i!=null){
			buttons = DialogButton.APPLY | DialogButton.CANCEL;// | "Custom Button" | DialogButton.SAVE;
			cast(findComponent("remb"), Button).hide();
			cast(findComponent("groupsdd"), ListView).onChange = function(e:Dynamic){
				var lv:ListView = cast e.target;
				lv.selectedItem.selected = !lv.selectedItem.selected;
				var na:Array<Dynamic> = cast(lv.dataSource.data, Array<Dynamic>).copy();
				lv.dataSource.clear();
				for (g in na){
					lv.dataSource.add(g);
				}
			};
		}else{
			buttons = DialogButton.CANCEL;
			cast(findComponent("remb"), Button).onClick = function (e:Dynamic){
				for (g in cast(cast(findComponent("groupsdd"), ListView).dataSource.data, Array<Dynamic>)){
					if (g.selected){
						g.remove();
					}
				}
				findComponent("editbox").hide();
				updateGroups();
			};
			cast(findComponent("groupsdd"), ListView).onChange = function(e:Dynamic){
				var lv:ListView = cast e.target;
				
				var tf:TextField = cast findComponent("editname");
				tf.value = lv.selectedItem.name;
				cast(findComponent("editb"), Button).onClick = function(e:Dynamic){
					lv.selectedItem.name = tf.value;
					lv.selectedItem.save();
					findComponent("editbox").hide();
					updateGroups();
				};
				findComponent("editbox").show();
			};
		}
		
		cast(findComponent("addb"), Button).onClick = function (e:Dynamic){
			var n:TextField = findComponent("addname");
			new Group({name:n.value}).save();
			n.value = "";
			updateGroups();
		}
		
		
		findComponent("editbox").hide();
		updateGroups();
		
		onDialogClosed = function(e:DialogEvent) {
			trace (e.button);
			if (e.button == DialogButton.APPLY){
				var si:Group = cast(findComponent("groupsdd"), ListView).selectedItem;
				_item.group_id = si.id;
				if (saveCallback != null){
					saveCallback(); 
				}
			}
		}
	}
	
	public function hideNew(){
		findComponent("addb").hide();
	}
	
	public function setNew(str:String){
		cast(findComponent("addname"), TextField).value = str;
	}
	
	function updateGroups(){
		var groups = cast(findComponent("groupsdd"), ListView);
		groups.dataSource.clear();
		for (g in Group.all("")){
			groups.dataSource.add(g);
		}
	}
}

