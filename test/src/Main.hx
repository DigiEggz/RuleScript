package;

import rulescript.*;
import rulescript.parsers.*;
import rulescript.scriptedClass.RuleScriptedClassUtil;
import sys.io.File;
import test.HelloWorldAbstract;
import test.ScriptedClassTest;
import test.TestAbstract;

class Main
{
	static var script:RuleScript;

	static var callNum:Int = 0;
	static var errorsNum:Int = 0;

	static function restTest(hello:String, ...rest:Int) {}

	static function main():Void
	{
		var language:String = 'haxe'; // 'lua';

		test.Test.LocalHelloClass.init();
		HelloWorldAbstract.RULESCRIPT;

		trace('Testing Commands:');

		switch (language)
		{
			case 'haxe':
				script = new RuleScript(null, new HxParser());

				script.getParser(HxParser).allowAll();

				try
				{
					mathTest();
					packageTest();
					importAndUsingTest();
					stringInterpolationTest();
					abstractTest();
					moduleTest();
					fileScriptTest();
					scriptClassesTest();
				}
				catch (e)
					trace(e?.details());
			case 'lua':
				script = new RuleScript(null, new LuaParser());

				try
				{
					luaTest();
				}
				catch (e)
					trace(e?.details());
		}

		trace('
			Tests: $callNum,
			Errors: $errorsNum
		');
	}

	static function mathTest()
	{
		runScript('1 + 7');
		runScript('1 - 2');
		runScript('15*2');
		runScript('10 / 2');

		runScript('5 + 5*2');
		runScript('1.1 + 2.53 + 122');
		runScript('(15*2) + (12/2)');
		runScript('2 / (3*5)');

		runScript('1.153');
	}

	static function packageTest()
	{
		runScript('
            package;

            return "Hello World";
        ');

		runScript('
            package scripts.hello.world;

            return "Hello World";
        ');
	}

	static function importAndUsingTest()
	{
		runScript('
            import Reflect as AliasReflect;

            var a = {
                "hello":"world"
            };

            return AliasReflect.getProperty(a,"hello");
        ');

		runScript('
            import Reflect.getProperty;

            var a = {
                "hello":"world"
            };

            return getProperty(a,"hello");
        ');

		runScript('
            import Reflect.getProperty as get;

            var a = {
                "hello":"world"
            };

            return get(a,"hello");
        ');

		runScript('
            using Reflect;

            var a = {
                "hello":"world"
            };
            
            return a.getProperty("hello");
        ');
	}

	static function stringInterpolationTest()
	{
		runScript("
            var a = 'Hello';
        
            return 'RuleScript: $a World';
        ");

		runScript("
            var a = 'World';
        
            return 'RuleScript: Hello $a';
        ");

		runScript("
            var a = {
                a:'RuleScript',
                b: () -> 'Hello',
                c:'World'
            };
        
            return a.a + ' ' + a.b() + ' ' + a.c;
        ");

		runScript("
            var a = {
                a:'RuleScript',
                b: () -> 'Hello',
                c:'World'
            };
        
            return '${a.a}: ${a.b() + \" \" + a.c}';
        ");
	}

	static function abstractTest()
	{
		runScript('
            import test.TestAbstract;

            return TestAbstract.helloworld;
        ');

		runScript('
            import test.HelloWorldAbstract;

            return HelloWorldAbstract.rulescriptPrint();
        ');

		runScript('
            import test.HelloWorldAbstract as Hw;

            return Hw.rulescriptPrint();
        ');

		runScript("
            import test.HelloWorldAbstract as Hw;

            return '${Hw.RULESCRIPT}: ${Hw.hello} ${Hw.world}';
        ");

		runScript('
            import test.Test.LocalHelloClass;

            return LocalHelloClass.hello();
        ');
	}

	static function moduleTest()
	{
		script.getParser(HxParser).mode = MODULE;

		runScript('
			package;

			class HelloWorld
			{
				function main(){
					trace("hello world");

					var a = {
						b: "rulescript class: hello world"
					}
					trace(Reflect.getProperty(a,"b"));

				}
			}
		');

		script.variables.get('main')();

		script.superInstance = {"test": () -> trace('testing super instance')};

		runScript('
			package;

			class HelloWorld
			{
				function main(){
					test();
				}
			}
		');

		script.variables.get('main')();

		script.superInstance = {"replace": () -> trace('testing super instance')};

		runScript('
			package;

			using StringTools;

			class HelloWorld
			{
				function main(){
					var a = {
						b:{
							c:{
								text:"hello"
							}
						}
					};
					trace(a.b.c.text.replace("hello","world"));
				}
			}
		');

		script.variables.get('main')();
	}

	static function scriptClassesTest()
	{
		script.getParser(HxParser).mode = MODULE;

		RuleScriptedClassUtil.registerRuleScriptedClass('scripted', script.getParser(HxParser).parse(File.getContent('scripts/haxe/ScriptedClass.rhx')));

		var srcClass = new SrcClassTest<Hello<Int>, Int>('Src'),
			scriptClass = new ScriptedClassTest('scripted', 'Script');
		trace(srcClass.info());
		trace(scriptClass.info());

		trace(srcClass.argFunction(true, 'hello', 'world'));
		trace(scriptClass.argFunction(true, 'hello', 'world'));

		trace(srcClass.string(new Hello<Int>(12)));
		trace(scriptClass.string(new Hello<String>('hello')));

		trace(srcClass.stringArray([new Hello<Int>(12)]));
		trace(scriptClass.stringArray([new Hello<String>('hello')]));
	}

	static function fileScriptTest()
	{
		script.getParser(HxParser).mode = DEFAULT;
		runFileScript('haxe/PropertyTest.rhx');

		script.getParser(HxParser).mode = MODULE;
		runFileScript('haxe/test.rhc');

		script.variables.get('main')();
	}

	static function luaTest()
	{
		runFileScript('lua/Script.lua');
		script.variables.get('main')();
	}

	static function runScript(code:String)
	{
		// Reset package, for reusing package keyword
		script.interp.scriptPackage = '';

		Sys.println('\n[Running code #${++callNum}]: "$code"\n\n         [Result]: ${script.tryExecute(code, onError)}');
	}

	static function runFileScript(path:String)
	{
		// Reset package, for reusing package keyword
		script.interp.scriptPackage = '';

		var code:String = File.getContent('scripts/' + path);

		Sys.println('\n[Running code #${++callNum}]: "$code"\n\n         [Result]: ${script.tryExecute(code, onError)}');
	}

	static function onError(e:haxe.Exception):Dynamic
	{
		errorsNum++;
		return e.details();
	}
}
