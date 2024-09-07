package rulescript.macro;

import haxe.macro.Context;
import haxe.macro.Expr;
import sys.FileSystem;
import sys.io.File;

using StringTools;

class AbstractMacro
{
	/**
	 * Converts abstract to class
	 */
	#if !macro macro #end public static function buildAbstract(name:String, pack:String):Array<Field>
	{
		var fields = Context.getBuildFields();
		var pos = Context.currentPos();

		var type = Context.getLocalClass();

		var isEnum:Bool = type.get().meta.has(':enum');

		var cl = macro class {};

		var imports = Context.getLocalImports();

		imports.push({
			path: name.split('.').map(s -> {
				name: s,
				pos: pos
			}),
			mode: INormal
		});

		if (name.contains('.'))
		{
			var list = name.split('.');

			while (list.length > 1)
				pack += '.' + list.shift();

			name = list[0];
		}

		cl.name = '_' + name;
		cl.pack = pack.split('.');

		for (f in fields)
		{
			if (isEnum && (f.kind.match(FVar(_, _))))
			{
				cl.fields.push({
					name: f.name,
					doc: f.doc,
					access: [APublic, AStatic],
					kind: switch (f.kind)
					{
						case FVar(t, e) if (e != null):
							f.kind;
						default:
							FVar(macro :String, macro $v{f.name});
					},
					pos: f.pos,
					meta: f.meta
				});
			}
			else if (f.access.contains(AStatic))
				cl.fields.push(f);
		}

		Context.defineModule('$pack._$name', [cl], imports);

		return fields;
	}
}