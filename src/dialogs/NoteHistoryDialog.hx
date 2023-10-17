package dialogs;

import haxe.ui.components.Label;
import haxe.ui.containers.HBox;
import haxe.ui.containers.ScrollView;
import haxe.ui.containers.VBox;
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

 
 /*
<vbox width="100%">
	<hbox width="100%" style="horizontal-spacing:0;">
		<label id="date" width="100%" verticalAlign="center" horizontalAlign="center" style="font-size: 13;border: 1px solid #bbbbbb"/>
		<vbox id="box">
		</vbox>
	</hbox>
	<label id="text" width="100%" horizontalAlign="left" style="font-size: 15;" />
</vbox>
*/
@:build(haxe.ui.macros.ComponentMacros.build("assets/notehistory-dialog.xml"))
class NoteHistoryDialog extends Dialog {
	var _item:Note;
	
	public var saveCallback:Item->Void;
	public var removeCallback:Int->Void;
	
    public function new(i:Note) {
        super();
		_item = i;
		title = "History";
		
		buttons = DialogButton.CANCEL;
	
		var items = cast(findComponent("items"), VBox);
		items.removeChildren();
		var values:Array<NoteValue> = [for (o in i.values) o];
		values.reverse();
		for (pos in 0...values.length){
			var vh:NoteValue = values[pos];
			var vb1:VBox = new VBox();
			items.addComponent(vb1);
			var hb1:HBox = new HBox();
			vb1.addComponent(hb1);
			var l:Label = new Label();
			hb1.addComponent(l);
			l.text = vh.created_at.toString();
			var hb2:HBox = new HBox();
			hb2.addClass("diff_text");
			hb1.addComponent(hb2);
			//var pos = values.length - 1 - vi;
			if (pos != values.length - 1) {
				var l2:Label;
				var diffs:Array<Dynamic> = DiffMatchPatch.diff(values[pos + 1].text, vh.text);
				for (a in diffs){
					l2 = new Label();
					l2.text = a[1];
					l2.addClass("diff_text");
					if (a[0]<0){
						l2.addClass("text_removed");
					}else if (a[0]>0){
						l2.addClass("text_added");						
					}
					hb2.addComponent(l2);
					trace(text);
				}
				
//				items.dataSource.add({date: vh.created_at, box: l});
			}else{
				var l2:Label = new Label();
				l2.text = vh.text;
				hb2.addComponent(l2);
			}
		}
		onDialogClosed = function(e:DialogEvent) {
			
		}
	}

}

