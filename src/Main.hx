package ;

import haxe.Timer.delay;
import haxe.ui.ComponentBuilder;
import haxe.ui.components.Calendar;
import haxe.ui.components.Stepper;
import haxe.ui.components.VerticalScroll;
import haxe.ui.containers.CalendarView;
import haxe.ui.containers.ScrollView;
import haxe.ui.events.MouseEvent;
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
	static var _currentDate:Date = new Date(Date.now().getFullYear(), Date.now().getMonth(), Date.now().getDate(), 0, 0, 0);
	
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
			var calendarv:CalendarView = cast mainView.findComponent("calendar1");
			var calendar:Calendar= cast calendarv.findComponent(Calendar);
			var mchangef = function(e:Dynamic){
				var calendarv:CalendarView = e.target;
				var calendar:Calendar= cast calendarv.findComponent(Calendar);
				_currentDate = calendar.date; //selectedDate
				reloadDayMemos();
				for (cc in calendar.findComponents(Button)){
					cc.removeClass("day-border");
					if (Std.parseInt(cc.text) == Date.now().getDate()){
						if (cc.hasClass("calendar-day")){
							if (_currentDate.getMonth() == Date.now().getMonth() && _currentDate.getFullYear() == Date.now().getFullYear()){	
								cc.addClass("day-border");
							}
						}
					}
					var date = DBManager.timeFromDate(new Date(_currentDate.getFullYear(), _currentDate.getMonth(), Std.parseInt(cc.text), 0, 0, 0));
					var date2 = DBManager.timeFromDate(new Date(_currentDate.getFullYear(), _currentDate.getMonth(), Std.parseInt(cc.text)+1, 0, 0, 0));
					for (l in cc.findComponents(Label)){
						l.removeClass("day-notes");
						if (cc.hasClass("calendar-day")){
							if (Note.count('where date < ${date2} and date >= ${date}') > 0){
								l.addClass("day-notes");
							}
						}
					}
				}

/*				if (_currentDate.getMonth() == Date.now().getMonth()){
					var list = curr_day.styleNames.split(" ");
					if (list.indexOf("day-border") < 0)
						curr_day.styleNames += " day-border";
				}else{
					var list = curr_day.styleNames.split(" ");
					if (list.remove("day-border"))
						curr_day.styleNames = list.join(" ");					
				}
*/			};

			calendarv.onChange = mchangef;
			cast(calendarv.findComponent("prev-month"), Button).onClick = function(e:Dynamic){ delay(mchangef.bind({target:calendarv}),1); };
			cast(calendarv.findComponent("next-month"), Button).onClick = function(e:Dynamic){ delay(mchangef.bind({target:calendarv}),1); };
			cast(calendarv.findComponent("current-year"), Stepper).onChange = function(e:Dynamic){ delay(mchangef.bind({target:calendarv}),1); };
			_daymemos.onChange = function(e:Dynamic){
				var l:ListView = cast e.target;
				var dialog = new EditDialog(l.selectedItem);
				dialog.saveCallback = function(i:Note){mchangef({target:calendarv}); };
				dialog.showDialog();
			};
			for (cc in calendar.findComponents(Button)){
				cc.addClass("calendar-button");
			}
			cast(mainView.findComponent("addnewbutton"), Button).onClick = function(e:Dynamic){
				var date:Date=Date.now();
				if (
					date.getMonth() != _currentDate.getMonth() ||
					date.getDate() != _currentDate.getDate() ||
					date.getFullYear() != _currentDate.getFullYear()
				){
					date = new Date(_currentDate.getFullYear(), _currentDate.getMonth(), _currentDate.getDate(), 12, 0, 0);
				}
				
				var dialog = new EditDialog(new Note({
					date: DBManager.timeFromDate(date)
				}));
				dialog.saveCallback = function(i:Note){mchangef({target:calendarv});};
				dialog.showDialog();
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
			//var now = Date.now();
			_app.start();
			mchangef({target:calendarv});//new Date(now.getFullYear(), now.getMonth(), now.getDate(), 0, 0, 0));
//			delay(hideScroll.bind(mainView), 100);
//			delay(hideScroll.bind(mainView), 300);
			
			//
//			sync.updateCallback = reloadItems;
//			delay(function(){sync.checkUpdates(); }, 200);
			//testing stuff
		#if debug
//			var n = new Note({}).save();
//			n.value = new NoteValue({text: "sdadasda"});
//			n.value = new NoteValue({text: "sdadasdaqwqa"});
//			n.value = new NoteValue({text: "sdadasdaweq	e	\nqewQEQE"});
//			trace(n);
//			trace(n.text);
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

	static function reloadDayMemos(){
//		var date = DBManager.timeFromDate(_currentDate);
		var date = DBManager.timeFromDate(new Date(_currentDate.getFullYear(), _currentDate.getMonth(), _currentDate.getDate(), 0, 0, 0));
		var date2 = DBManager.timeFromDate(new Date(_currentDate.getFullYear(), _currentDate.getMonth(), _currentDate.getDate()+1, 0, 0, 0));
		_daymemos.dataSource.clear();
		for (e in Note.all(
			'where date < ${date2} and date >= ${date}'
//			'where date < ${date+24*60*60} and date >= ${date}'
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


/*
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
*/