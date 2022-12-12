package ;

import sys.db.Connection;
import sys.db.Sqlite;

/**
 * ...
 * @author ...
 */
class DBManager {
	public var context: Connection;
	public var vcontrol: VersionControl;
	
	var _dbpath:String = "db.sqlite";
	
	public function new(){
	#if mobile
		_dbpath = lime.system.System.applicationStorageDirectory + "/" + _dbpath;
	#end
		context = Sqlite.open(_dbpath);
		vcontrol = new VersionControl(this);
	} 
	
	public static var instance:DBManager = new DBManager();
	
	public static function dateFromTime(time: Float):Date{
		return Date.fromTime(time*1000.0);
	}
	public static function timeFromDate(date: Date):Float{
		var str:String = '${date.getTime()/1000}';
		return Std.parseFloat(str.split(".")[0]);
	}
}