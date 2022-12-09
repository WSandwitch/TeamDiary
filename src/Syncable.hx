package;

/**
 * @author WSandwitch
 */
interface Syncable {
	public var id:Null<Int>;
	public var syncronized:Bool;
	
	public function save(settime:Bool = true, sync:Bool = true):Dynamic;
	public function to_json():Dynamic;
}