package ;

import openfl.net.SharedObject;

/**
 * ...
 * @author WSandwitch
 */
class Settings{
	
	static var _all:SharedObject = SharedObject.getLocal("settings", #if mobile lime.system.System.applicationStorageDirectory + "/" #else "./" #end);
	
	public static function exists(key:String):Bool {
		var data:haxe.DynamicAccess<Dynamic> = _all.data;
		return data.exists(key); 
	}
	
	public static function get(key:String):Dynamic {
		var data:haxe.DynamicAccess<Dynamic> = _all.data;
		return data.get(key); 
	}
	
	public static function set(key:String, val:Dynamic) {
		var data:haxe.DynamicAccess<Dynamic> = _all.data;
		data.set(key, val);
		_all.flush();
	}
	
}