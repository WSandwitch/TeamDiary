package ;
import haxe.Json;
import sys.db.Connection;

/**
 * ...
 * @author ...
 */
class NoteValue implements Syncable {
	public var needremove:Bool = false;
	
	public var id:Null<Int>;
	public var note_id:Int;
	public var text:String = "";
//	public var date:Date = Date.now();
	public var created_at:Date = Date.now();
	public var syncronized:Bool = false;
	
	public var note(get, set):Note;
	public function get_note():Note{
		return Note.get(note_id);
	}
	public function set_note(o:Note):Note{
		note_id = o.id;
		return o;
	}
	
	public var text_short(get, null):Dynamic;
	public function get_text_short():Dynamic{
		return text.substr(0,50);//TODO add check for size on screen
	}
	
	
	public function new(data:Dynamic) {
		id = data.id;
		note_id = data.note_id;
		if (data.text != null)
			text = data.text;
//		if (data.date != null)
//			date = DBManager.dateFromTime(data.date);
		if (data.created_at != null)
			created_at = DBManager.dateFromTime(data.created_at);
		if (data.syncronized != null)
			syncronized = data.syncronized == 1;
	}
	
	public function save(settime:Bool=true, sync:Bool = true):NoteValue{
		if (settime)
			created_at = Date.now();
		if (sync) 
			syncronized = false;
		var keys:Array<Dynamic> = ['text', 'note_id', 'created_at', 'syncronized'];
		var vals:Array<Dynamic> = ['"${text}"', note_id, DBManager.timeFromDate(created_at), syncronized?1:0];
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
			text: text, 
//			date: DBManager.timeFromDate(date), 
			created_at:DBManager.timeFromDate(created_at),
			note_id: note_id,
		};
	}

	
	public static var tname:String = 'notevalues';

	//===
	public static function get(id:Int):NoteValue{
		return new NoteValue(request('SELECT * FROM ${tname} WHERE id = ${id} LIMIT 1').results().first());
	}
	
	public static function all(ext:String, fields:String = "*"):List<NoteValue>{
		return request('SELECT DISTINCT ${fields} FROM ${tname} ${ext};').results().map(function(o:Dynamic){
			return new NoteValue(o);
		});
	}
	
}