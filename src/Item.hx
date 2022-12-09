package ;
import haxe.Json;
import sys.db.Connection;

/**
 * ...
 * @author ...
 */
class Item implements Syncable {
	public var needremove:Bool = false;
	
	public var id:Null<Int>;
	public var unit_id:Null<Int>;
	public var name:String = "";
	public var unit:String = "";
	public var value:Float = 0;
	public var pvalue:Null<Float> = null;
	public var updated_at:Date = Date.now();
	public var syncronized:Bool = false;
	public var removed:Bool = false;
	//public var history:Array<ValueHistory> = [];
	public var groups:Null<List<Group>>;
	public var lgroups(get, null):String;	
	
	
	public function new(data:Dynamic) {
		id = data.id;
		unit_id = data.unit_id;
		if (data.name != null)
			name = data.name;
		if (data.value != null)
			value = data.value;
		if (data.updated_at != null)
			updated_at = DBManager.dateFromTime(data.updated_at);
		if (data.syncronized != null)
			syncronized = data.syncronized == 1;
		if (data.removed != null)
			removed = data.removed == 1;
		//history = ValueHistory.all('where item_id = ${id} ORDER BY updated_at ASC');
		//if (history.length > 0)
		//	pvalue = history[history.length - 1].value;
		if (data.groups != null){
			groups = Group.all('where ${Group.tname}.id in (${data.groups.join(",")})');
		}else{
			groups = getGroups();
		}
		if (groups == null)
			groups = new List<Group>();
	}
	
	public function save(settime:Bool=true, sync:Bool = true):Item{
		if (settime)
			updated_at = Date.now();
		if (sync) 
			syncronized = false;
		var keys:Array<Dynamic> = ['name', 'value', 'updated_at', 'syncronized', 'removed'];
		var vals:Array<Dynamic> = ['"${name}"', value, DBManager.timeFromDate(updated_at), syncronized?1:0, removed?1:0];
		if (id!=null){
			keys.push('id');
			vals.push(id);
		}
		if (unit_id!=null){
			keys.push('unit_id');
			vals.push(unit_id);
		}
		_dbm.context.request('INSERT OR REPLACE INTO ${tname} (${keys.join(",")}) VALUES(${vals.join(",")});');
		if (id==null){
			id = _dbm.context.request('select id from ${tname} order by id desc limit 1').getIntResult(0);
		}
		pvalue = value;

		saveGroups();
		
//		if (sync) {
//			_dbm.sync.pushChanged(this);
//		}
		return this;
	}
	
	public function saveGroups(){
		_dbm.context.request('BEGIN TRANSACTION;');
		_dbm.context.request('DELETE FROM ${tname}_${Group.tname} WHERE item_id = ${id} and gid not in (${[for (g in groups) if (g.selected) g.id].join(",")});');
		for (g in groups){
			var keys=['item_id','gid'];
			var vals = [id, g.id];
			_dbm.context.request('INSERT OR REPLACE INTO ${tname}_${Group.tname} (${keys.join(",")}) VALUES(${vals.join(",")});');
		}
		_dbm.context.request('COMMIT;');
		return this;
	}
	
	public function remove():Void{
		if (id!=null){
			//_dbm.context.request('DELETE FROM ${tname} where id = ${id};');
			//ValueHistory.removeAll(id);
			removed = true;
			save();
		}
	}
	
	function getGroups(){
		return Group.all('where ${Group.tname}.id in (select gid from ${tname}_${Group.tname} where item_id = ${id})');
	}
	
	public function get_lgroups():String{
		var grs = [for (g in groups) if (g.name != null) g.name];
		if (grs.length == 0){
			return " ";
		}else{
			return grs.join(", ");//TODO: check why is null here
		}
	}
	
	
	//----
	public function to_json():Dynamic{
		return {
			id: id, 
			name: name, 
			value: value, 
			updated_at:DBManager.timeFromDate(updated_at),
			unit_id: unit_id,
			removed: removed?1:0,
			groups: [for (g in groups) g.id ]
		};
	}
	
	//===
	static var _dbm:DBManager;
	
	public static function get(id:Int):Item{
		return new Item(_dbm.context.request('SELECT * FROM ${tname} WHERE id = ${id} LIMIT 1').results().first());
	}
	
	public static function all(ext:String, fields:String = "*"):List<Item>{
		return _dbm.context.request('SELECT DISTINCT ${fields} FROM ${tname} ${ext};').results().map(function(o:Dynamic){
			return new Item(o);
		});
	}
	
	public static var tname:String = 'items';
	public static function init(dbm:DBManager){
		_dbm = dbm;
	}
}