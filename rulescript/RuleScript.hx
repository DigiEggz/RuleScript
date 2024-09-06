package rulescript;

import cpp.Function;
import hscript.Expr;

/**
 * Type limit
 */
abstract StringOrExpr(Dynamic) from String to String from Expr to Expr {}

/**
 * Addon for HScript with imports, using and more.
 * 
 * ## Adding script:
 * 
 * ```haxe
 * script = new RuleScript(null,new HxParser());
 * 
 * // Get parser as HxParser
 * script.getParser(HxParser).allowAll();
 *
 * // Run execute inside try-catch
 * script.tryExecute('trace("Hello World");'); // Hello World
 * 
 * script.execute('1+1;'); // 2
 * ```
 * 
 * ## Example:
 * 
 * Package
 * ```haxe
 * package scripts.hello.world;
 * ```
 * ### Import class:
 * ```haxe
 * import haxe.ds.StringMap;
 * 
 * var map = new StringMap();
 * map.set("Hello","World");
 * trace(map.get("Hello")); // World
 * ```
 * 
 * ### Import with alias:
 * 
 * ```haxe
 * import haxe.ds.StringMap as StrMap;
 * 
 * var map = new StrMap();
 * map.set("Hello","World");
 * trace(map.get("Hello")); // World
 * ```
 * 
 * You also can use `in` keyword
 * ```haxe
 * import haxe.ds.StringMap in StrMap;
 * 
 * var map = new StrMap();
 * map.set("Hello","World");
 * trace(map.get("Hello")); // World
 * ```
 * 
 * ### Using:
 * ```haxe
 * using Reflect;
 * 
 * var a = {
 *  "Hello":"World"
 * };
 * trace(a.getProperty("Hello")); // World
 * ```
 * 
 * ### String interpolation
 * ```haxe
 * var a = 'Hello';
 * return 'RuleScript: $a World'; // RuleScript: Hello World
 * ```
 * 
 */
class RuleScript
{
	/**
	 * Edit, if you want make importable script
	 * @see [Dynamic Keyword](https://haxe.org/manual/class-field-dynamic.html)
	 */
	public static dynamic function resolveScript(name:String):Dynamic
	{
		return null;
	}

	public var interp:RuleScriptInterp;

	public var variables(get, set):Map<String, Dynamic>;

	public var parser:Parser;

	public function new(?interp:RuleScriptInterp, ?parser:Parser)
	{
		// You can register custom parser in a child class
		this.interp ??= interp ?? new RuleScriptInterp();
		this.parser ??= parser ?? new HxParser();
	}

	public function execute(code:StringOrExpr):Dynamic
	{
		return interp.execute(code is String ? parser.parse(code) : code);
	}

	public function tryExecute(code:StringOrExpr, ?customCatch:haxe.Exception->Dynamic):Dynamic
	{
		return try
		{
			execute(parser.parse(code));
		}
		catch (v) customCatch != null ? customCatch(v) : v.details();
	}

	public function getParser<T:Parser>(?parserClass:Class<T>):T
		return cast parser;

	function get_variables():Map<String, Dynamic>
	{
		return interp.variables;
	}

	function set_variables(v:Map<String, Dynamic>):Map<String, Dynamic>
	{
		return interp.variables = v;
	}
}
