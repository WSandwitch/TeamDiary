package;

/**
 * ...
 * @author WSandwitch
 */
class Group implements Syncable {
	
	public var id:Null<Int>;
	public var name:String = "";
	public var selected:Bool = false; //for adding on edit
	public var text(get,null):String = "";
	private function get_text():String{return name;}
	public var updated_at:Date = Date.now();
	public var syncronized:Bool = false;
	public var removed:Bool = false;
	
	public function new(data:Dynamic){
		id = data.id;
		name = data.name;
		if (data.updated_at != null)
			updated_at = DBManager.dateFromTime(data.updated_at);
		if (data.syncronized != null)
			syncronized = data.syncronized == 1;
		if (data.removed != null)
			removed = data.removed == 1;
	}
	
	public function save(settime:Bool=true, sync:Bool = true):Group{
		if (settime)
			updated_at = Date.now();
		if (sync) 
			syncronized = false;
		var keys:Array<Dynamic>=['name', 'updated_at', 'syncronized', 'removed'];
		var vals:Array<Dynamic> = ['"${name}"', DBManager.timeFromDate(updated_at), syncronized?1:0, removed?1:0];
		if (id!=null){
			keys.push('id');
			vals.push(id);
		}
		_dbm.context.request('INSERT OR REPLACE INTO ${tname} (${keys.join(",")}) VALUES(${vals.join(",")});');
		if (id==null){
			id = _dbm.context.request('select id from ${tname} order by id desc limit 1').getIntResult(0);
		}
//		if (sync) {
//			_dbm.sync.pushChanged(this);
//		}
		return this;
	}
	
	public function remove():Void{
		if (id != null){
			removed = true;
			save();
			
			var ids = [for (o in _dbm.context.request('SELECT item_id FROM ${Item.tname}_${tname} where gid = ${id};').results()) o.item_id]; 
			trace(ids);
			_dbm.context.request('DELETE FROM ${Item.tname}_${tname} where gid = ${id};'); //remove all connections to removed group
			//sync to server
			for (i in Item.all('WHERE id in (${ids.join(",")})')){
				i.save(); 
			}
			//_dbm.context.request('DELETE FROM ${tname} where id = ${id};');
		}
	}	
	
	//----
	public function to_json():Dynamic{
		return {
			id: id, 
			name: name, 
			updated_at: DBManager.timeFromDate(updated_at),
			removed: removed?1:0,
		};
	}
	
	//---
	static var _dbm:DBManager;
	
	public static function get(id:Int):Group{
		return new Group(_dbm.context.request('select * from ${tname} where id = ${id} limit 1').results().first());
	}
	
	public static function all(ext:String, fields:String = "*"):List<Group>{
		return _dbm.context.request('select ${fields} from ${tname} ${ext};').results().map(function(o:Dynamic){
			return new Group(o);
		});
	}
	
	public static var tname:String = 'groups';
	public static function init(dbm:DBManager){
		_dbm = dbm;
	}
	
	public function toString(){
		return text;
	}
}