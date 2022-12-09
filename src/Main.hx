package ;

import haxe.Timer.delay;
import haxe.ui.ComponentBuilder;
import haxe.ui.components.Calendar;
import haxe.ui.components.VerticalScroll;
import haxe.ui.containers.CalendarView;
import haxe.ui.containers.ScrollView;
import haxe.ui.events.UIEvent;
//import network.Sync;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.EventType;
import haxe.ui.HaxeUIApp;
import haxe.ui.containers.ListView;
import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.components.TextField;
import haxe.ui.components.Button;
import haxe.ui.components.Image;
import haxe.ui.components.Label;
import haxe.ui.core.Component;
import haxe.ui.macros.ComponentMacros;
import lime.ui.KeyCode;
import sys.db.Sqlite;
import haxe.ui.Toolkit;
import dialogs.*;



class Main {
	static var _daymemos:ListView;
	static var _app:HaxeUIApp;
	
	static var sort:String = "updated_at";
	static var sortdir:String = "DESC";
	static var sortstr:String = ' ORDER BY ${Item.tname}.updated_at DESC';
	static var filter:Item;
	static var filterstr:String = ""; //"WHERE name LIKE '%${StringTools.replace(StringTools.replace(val, "%", "\%"), "_", "\_")}%' ESCAPE '\'" // 'JOIN ${Item.tname}_${Group.tname} AS ig ON ig.item_id = ${Item.tname}.id WHERE ig.gid = ${val} '
	
	//static var sync:Sync;
	
	static inline var screenWidth:Float = 399;
	
    public static function main() {
//		sync = new Sync();
		//it looks the sae on different window size
		Toolkit.scale = openfl.Lib.current.stage.stageWidth * 1.0 / screenWidth; 
		Toolkit.theme = "default";//dark
		_app = new HaxeUIApp();
        _app.ready(function() {
			//trace(Screen.instance.dpi);
			trace(haxe.ui.Toolkit.scale);
            var mainView:Component = ComponentBuilder.fromFile("assets/main-view.xml");
            _app.addComponent(mainView);
            _daymemos = cast(mainView.findComponent("daymemos"), ListView);
			var calendar:CalendarView = mainView.findComponent("calendar1");
			calendar.onChange = function(e:UIEvent){
				var date:Date = cast(e.target, Calendar).selectedDate;
				reloadDayMemos(date);
				trace(date);
				delay(hideScroll.bind(mainView), 100);
				delay(hideScroll.bind(mainView), 300);
			}
			for (cc in calendar.findComponents(Button)){
				//trace(cc.styleNames);
				cc.styleNames += " calendar-button";
			}
			cast(mainView.findComponent("addnewbutton"), Button).onClick = function(e:Dynamic){
//				var dialog = new EditDialog(new Item({}));
//				dialog.saveCallback = function(i:Item){reloadItems(); };
//				dialog.showDialog();
			};
			
/*			
			cast(mainView.findComponent("settingsb"), Button).onClick = function(e:Dynamic){
				var dialog = new SettingsDialog(reloadItems, sync);
				//dialog.saveCallback = function(i:Item){reloadItems(""); };
				dialog.showDialog();
			};
			cast(mainView.findComponent("filterb"), Button).onClick = function(e:Dynamic){
				var dialog = new GroupsDialog(filter);
				dialog.saveCallback = setFilter;
				dialog.hideNew();
				dialog.setNew(filter.name);
				dialog.showDialog();
			};
			cast(mainView.findComponent("sortb"), Button).onClick = function(e:Dynamic){
				var dialog = new SortingDialog(setSort, sort, sortdir);
				dialog.showDialog();
			};
*/			cast(mainView.findComponent("exitb"), Button).onClick = function(e:Dynamic){
				doExit();
			};
			var now = Date.now();
			reloadDayMemos(new Date(now.getFullYear(), now.getMonth(), now.getDate(), 0, 0, 0));
			_app.start();
			delay(hideScroll.bind(mainView), 100);
			delay(hideScroll.bind(mainView), 300);
			
			//
//			sync.updateCallback = reloadItems;
//			delay(function(){sync.checkUpdates(); }, 200);
			//testing stuff
		#if debug
//			new NoteValue({text: "sdadasda"}).save();
//			new NoteValue({text: "sdadasdaqwqa"}).save();
//			new NoteValue({text: "sdadasdaweq	e	\nqewQEQE"}).save();
		#end
		});
		
		
		openfl.Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, function(e:KeyboardEvent){
//			trace(e);
			if ([KeyCode.ESCAPE, KeyCode.APP_CONTROL_BACK].indexOf(e.keyCode)!=-1) {
				e.preventDefault(); 
				e.stopImmediatePropagation(); 
				e.stopPropagation(); 
				//show exit dialog
				doExit();
			}
		});
    }
	
	static function hideScroll(mainView:Component){
		try{ cast(mainView.findComponent("scrollview1").findComponent(VerticalScroll, false), VerticalScroll).hidden = true; }catch (e:Dynamic){
			//trace(e);
		}
	}
	
	static function reloadDayMemos(d:Date){
		var date = DBManager.timeFromDate(d);
		_daymemos.dataSource.clear();
		trace(date);
		for (e in NoteValue.all(
				'where date < ${date+24*60*60} and date >= ${date}'
		)){
			_daymemos.dataSource.add(e);
		}
	}
	
	static var _onexit:Bool = false;
	static function doExit(){
		if (!_onexit){
			_onexit = true;
			(new ExitDialog(()->{_onexit = false; })).showDialog();
		}
	}
	
	static function setFilter(i:Item, str:String){
		var gs:List<Group> = i.groups;
		i.name = str;
		if (gs == null) return;
		if (gs.length > 0){
			filterstr = ' INNER JOIN ${Item.tname}_${Group.tname} AS ig ON ig.item_id = ${Item.tname}.id WHERE ig.gid IN (${[for(g in gs) g.id].join(",")})';
		}else{
			filterstr = '' ;
		}
		if (str != null && str.length > 0){
			filterstr += (filterstr.indexOf("WHERE") >-1 ? " AND " : " WHERE ") + '${Item.tname}.name LIKE \'%' + StringTools.replace(StringTools.replace(i.name, "%", "\\%"), "_", "\\_") +"%' ESCAPE '\\'";
		}		
		if (gs.length > 0) 
			filterstr += ' GROUP BY (${Item.tname}.id)';
//		reloadItems();
	}
	
	static function setSort(s:String, d:String){
		sort = s;
		sortdir = d;
		sortstr = ' ORDER BY ${Item.tname}.${s} ${d}';
//		reloadItems();
	}
	
	public static function error(text: String){
		//added error text on the screen
	}
}

@:xml('
	<vbox width="100%">	
		<hbox width="100%">	
			<label id="date" width="100%" style="font-size: 12;" />
			<label id="created_at" style="font-size: 12;" />
		</hbox>
		<label id="text_short" horizontalAlign="left" style="font-size: 19;" />
	</vbox>
')
class NoteComponent extends Component{
	public function new() {
        super();
		cast(findComponent("date"), Label).text = "test texts";
    }
}