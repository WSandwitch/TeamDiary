package ;
import haxe.Json;
import sys.db.Connection;

/**
 * ...
 * @author ...
 */
class Note implements Syncable {
	public var needremove:Bool = false;
	
	public var id:Null<Int>;
	public var group_id:Int = 1;
	public var date:Date = Date.now();
	public var created_at:Date = Date.now();
	public var syncronized:Bool = false;
	
	public var values(get, null):List<NoteValue>;
	public function get_values():List<NoteValue>{
		return NoteValue.all('where note_id=${id} order by id asc'); //Note.get(...
	}
	
	public var value(get, set):Null<NoteValue>;
	public function get_value():Null<NoteValue>{
		return values.last();
	}
	public function set_value(n:Null<NoteValue>):Null<NoteValue>{
		trace(n);
		trace(n.text);
		n.note_id = id;
		n.save();
		trace(n.id);
		return n;
	}
	
	public var group(get, set):Null<Group>;
	public function get_group():Null<Group>{
		return Group.get(group_id);
	}
	public function set_group(g:Null<Group>):Null<Group>{
		if (g != null)
			group_id = g.id;
		return g;
	}
	
	public var text(get, set):String;
	public function get_text():String{
		var v = value;
		if (value!=null)
			return value.text; //Note.get(...
		return "";
	}
	public function set_text(t:String):String{
		new NoteValue({note_id: id, text: t}).save();
		return t; //Note.get(...
	}
	
	public var text_short(get, null):Dynamic;
	public function get_text_short():Dynamic{
		return text.substr(0,50);//TODO add check for size on screen
	}
	
	
	public function new(data:Dynamic) {
		id = data.id;
		if (data.group_id != null)
			group_id = data.group_id;
		if (data.date != null)
			date = DBManager.dateFromTime(data.date);
		if (data.created_at != null)
			created_at = DBManager.dateFromTime(data.created_at);
		if (data.syncronized != null)
			syncronized = data.syncronized == 1;
	}
	
	public function save(settime:Bool=true, sync:Bool = true):Note{
		if (settime)
			created_at = Date.now();
		if (sync) 
			syncronized = false;
		var keys:Array<Dynamic> = [ 'date', 'created_at', 'syncronized', 'group_id'];
		var vals:Array<Dynamic> = [ DBManager.timeFromDate(date), DBManager.timeFromDate(created_at), syncronized?1:0, group_id];
		if (id!=null){
			keys.push('id');
			vals.push(id);
		}
		request('INSERT OR REPLACE INTO ${tname} (${keys.join(",")}) VALUES(${vals.join(",")});');
		if (id==null){
			id = request('select id from ${tname} order by id desc limit 1').getIntResult(0);
		}
		
//		if (sync) {
//			_dbm.sync.pushChanged(this);
//		}
		return this;
	}
	
	static function request(s:String):Dynamic{
		return DBManager.instance.context.request(s);
	}
	
	//----
	public function to_json():Dynamic{
		return {
			id: id, 
			group_id: group_id,
			date: DBManager.timeFromDate(date), 
			created_at:DBManager.timeFromDate(created_at)
		};
	}

	
	public static var tname:String = 'notes';

	//===
	public static function get(id:Int):Note{
		return new Note(request('SELECT * FROM ${tname} WHERE id = ${id} LIMIT 1;').results().first());
	}
	
	public static function all(ext:String = "", fields:String = "*"):List<Note>{
		return request('SELECT DISTINCT ${fields} FROM ${tname} ${ext};').results().map(function(o:Dynamic){
			return new Note(o);
		});
	}
	
	public static function count(ext:String = ""):Int{
		return request('SELECT DISTINCT count(id) as osize FROM ${tname} ${ext};').results().last().osize;
	}
	
}