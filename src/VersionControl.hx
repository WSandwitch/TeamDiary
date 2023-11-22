package ;

/**
 * ...
 * @author ...
 */
class VersionControl {

	public var table_name:String = "version_control";
	public var tcolumn:String = "tid";
	
		//===
	static var _tid:Int = 1;
	static var _migrations:Array<Array<String>> = [
		[
			'CREATE TABLE IF NOT EXISTS ${NoteValue.tname} (id INTEGER PRIMARY KEY, note_id integer, text TEXT, date integer, created_at integer, syncronized integer);',
			'CREATE TABLE IF NOT EXISTS ${Note.tname} (id INTEGER PRIMARY KEY, date integer, created_at integer, syncronized integer);',
		], [
			'CREATE TABLE IF NOT EXISTS ${Group.tname} (id INTEGER PRIMARY KEY, name TEXT, created_at integer, syncronized integer);',
			'INSERT INTO ${Group.tname}(id,name) VALUES (1,\'default\');',
			'ALTER TABLE ${Note.tname} ADD COLUMN group_id integer DEFAULT 1;',
		]
	];
	
	function add_version(){
		_dbm.context.request('INSERT INTO ${table_name} (${tcolumn}) VALUES(${_tid});');
	}
	
	var _dbm:DBManager;
	public function new(dbm:DBManager) {
		_dbm = dbm;
		_dbm.context.request('create table if not exists ${table_name} (${tcolumn} id);');
		var version = dbm.context.request('select count(*) as ver from ${table_name} where ${tcolumn}=${_tid}').getIntResult(0);
		for (i in version..._migrations.length) {
			dbm.context.request('BEGIN TRANSACTION;');
				for (m in _migrations[i]) {
					dbm.context.request(m);
				}
			dbm.context.request('COMMIT;');
			add_version();
		}
	}
}