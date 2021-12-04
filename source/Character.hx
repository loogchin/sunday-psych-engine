package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.tweens.FlxTween;
import flixel.util.FlxSort;
import Section.SwagSection;
#if MODS_ALLOWED
import sys.io.File;
import sys.FileSystem;
#end
import openfl.utils.Assets;
import haxe.Json;
import haxe.format.JsonParser;

using StringTools;

typedef CharacterFile = {
	var animations:Array<AnimArray>;
	var image:String;
	var scale:Float;
	var sing_duration:Float;
	var healthicon:String;

	var position:Array<Float>;
	var camera_position:Array<Float>;

	var flip_x:Bool;
	var no_antialiasing:Bool;
	var healthbar_colors:Array<Int>;
}

typedef AnimArray = {
	var anim:String;
	var name:String;
	var fps:Int;
	var loop:Bool;
	var indices:Array<Int>;
	var offsets:Array<Int>;
}

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = DEFAULT_CHARACTER;

	public var colorTween:FlxTween;
	public var holdTimer:Float = 0;
	public var heyTimer:Float = 0;
	public var specialAnim:Bool = false;
	public var animationNotes:Array<Dynamic> = [];
	public var stunned:Bool = false;
	public var singDuration:Float = 4; //Multiplier of how long a character holds the sing pose
	public var idleSuffix:String = '';
	public var danceIdle:Bool = false; //Character use "danceLeft" and "danceRight" instead of "idle"

	public var healthIcon:String = 'face';
	public var animationsArray:Array<AnimArray> = [];

	public var positionArray:Array<Float> = [0, 0];
	public var cameraPosition:Array<Float> = [0, 0];

	//Used on Character Editor
	public var imageFile:String = '';
	public var jsonScale:Float = 1;
	public var noAntialiasing:Bool = false;
	public var originalFlipX:Bool = false;
	public var healthColorArray:Array<Int> = [255, 0, 0];
	public var alreadyLoaded:Bool = true; //Used by "Change Character" event

	public static var DEFAULT_CHARACTER:String = 'bf'; //In case a character is missing, it will use BF on its place
	public var noteSkin:String = 'normal';

	public function new(x:Float, y:Float, ?character:String = 'bf', ?isPlayer:Bool = false)
	{
		super(x, y);

		#if (haxe >= "4.0.0")
		animOffsets = new Map();
		#else
		animOffsets = new Map<String, Array<Dynamic>>();
		#end
		curCharacter = character;
		this.isPlayer = isPlayer;
		antialiasing = ClientPrefs.globalAntialiasing;

		var library:String = null;
		var tex:FlxAtlasFrames;
		switch (curCharacter)
		{
			//case 'your character name in case you want to hardcode him instead':
			case 'sunday-alt':
				tex = Paths.getSparrowAtlas('sunday/sunday_assets');
				frames = tex;
				animation.addByPrefix('idle', 'sunday idle', 24, true);
				animation.addByPrefix('singUP', 'sunday up', 24, false);
				animation.addByPrefix('singDOWN', 'sunday down', 24, false);
				animation.addByPrefix('singLEFT', 'sunday left', 24, false);
				animation.addByPrefix('singRIGHT', 'sunday right', 24, false);

				addOffset('idle',1,1);
				addOffset("singDOWN", 157, -27);
				addOffset("singRIGHT", -71,-10);
				addOffset("singUP", 137, 147);
				addOffset("singLEFT", 39,-1);
				
				playAnim('idle');

				healthIcon = 'face';
				healthColorArray = [161, 161, 161];
			case 'sunday':
				tex = Paths.getSparrowAtlas('sunday/sunday_assets');
				frames = tex;
				animation.addByPrefix('idle', 'sunday alt idle', 24, true);
				animation.addByPrefix('singUP', 'sunday alt up', 24, false);

				addOffset('idle',1,1);
				addOffset("singUP", 137, 147);
				
				playAnim('idle');

				healthIcon = 'face';
				healthColorArray = [161, 161, 161];
			case 'sunday-guitar':
				tex = Paths.getSparrowAtlas('sunday/sunday_guitar_assets');
				frames = tex;
				animation.addByPrefix('idle', 'sunday guitar idle', 24, true);
				
				animation.addByPrefix('singUP', 'sunday guitar up', 24, false);
				animation.addByPrefix('singUP-alt', 'sunday guitar alt up', 24, false);
				
				animation.addByPrefix('singDOWN', 'sunday guitar down', 24, false);
				animation.addByPrefix('singDOWN-alt', 'sunday guitar alt down', 24, false);
				
				animation.addByPrefix('singLEFT', 'sunday guitar left', 24, false);
				animation.addByPrefix('singLEFT-alt', 'sunday guitar alt left', 24, false);
				
				animation.addByPrefix('singRIGHT', 'sunday guitar right', 24, false);
				animation.addByPrefix('singRIGHT-alt', 'sunday guitar alt right', 24, false);
				
				animation.addByPrefix('end', 'sunday guitar end', 24, false);

				addOffset('idle-alt',1,1);
				
				addOffset("singRIGHT-alt",-31,-15);
				addOffset("singDOWN", 167, -28);
				addOffset("singLEFT-alt",41,-5);
				addOffset("singUP", 138, 145);
				
				addOffset('end', 166, -5);
				addOffset('idle',1,1);
				
				addOffset("singRIGHT", -36,-12);
				addOffset("singDOWN-alt",160,-30);
				addOffset("singUP-alt",104,-7);
				addOffset("singLEFT", 45, -2);
				
				playAnim('idle');

				healthIcon = 'face';
				healthColorArray = [161, 161, 161];
			case 'sunday-guitar-note':
				tex = Paths.getSparrowAtlas('sunday/sunday_guitar_assets');
				frames = tex;
				animation.addByPrefix('idle', 'sunday guitar idle', 24, true);
				
				animation.addByPrefix('singUP', 'sunday guitar up', 24, false);
				animation.addByPrefix('singUP-alt', 'sunday guitar alt up', 24, false);
				
				animation.addByPrefix('singDOWN', 'sunday guitar down', 24, false);
				animation.addByPrefix('singDOWN-alt', 'sunday guitar alt down', 24, false);
				
				animation.addByPrefix('singLEFT', 'sunday guitar left', 24, false);
				animation.addByPrefix('singLEFT-alt', 'sunday guitar alt left', 24, false);
				
				animation.addByPrefix('singRIGHT', 'sunday guitar right', 24, false);
				animation.addByPrefix('singRIGHT-alt', 'sunday guitar alt right', 24, false);
				
				animation.addByPrefix('end', 'sunday guitar end', 24, false);

				addOffset('idle-alt',1,1);
				
				addOffset("singRIGHT-alt",-31,-15);
				addOffset("singDOWN", 167, -28);
				addOffset("singLEFT-alt",41,-5);
				addOffset("singUP", 138, 145);
				
				addOffset('end', 166, -5);
				addOffset('idle',1,1);
				
				addOffset("singRIGHT", -36,-12);
				addOffset("singDOWN-alt",160,-30);
				addOffset("singUP-alt",104,-7);
				addOffset("singLEFT", 45, -2);
				
				playAnim('idle');

				healthIcon = 'face';
				healthColorArray = [161, 161, 161];

			default:
				var characterPath:String = 'characters/' + curCharacter + '.json';
				#if MODS_ALLOWED
				var path:String = Paths.modFolders(characterPath);
				if (!FileSystem.exists(path)) {
					path = Paths.getPreloadPath(characterPath);
				}

				if (!FileSystem.exists(path))
				#else
				var path:String = Paths.getPreloadPath(characterPath);
				if (!Assets.exists(path))
				#end
				{
					path = Paths.getPreloadPath('characters/' + DEFAULT_CHARACTER + '.json'); //If a character couldn't be found, change him to BF just to prevent a crash
				}

				#if MODS_ALLOWED
				var rawJson = File.getContent(path);
				#else
				var rawJson = Assets.getText(path);
				#end

				var json:CharacterFile = cast Json.parse(rawJson);
				if(Assets.exists(Paths.getPath('images/' + json.image + '.txt', TEXT))) {
					frames = Paths.getPackerAtlas(json.image);
				} else {
					frames = Paths.getSparrowAtlas(json.image);
				}
				imageFile = json.image;

				if(json.scale != 1) {
					jsonScale = json.scale;
					setGraphicSize(Std.int(width * jsonScale));
					updateHitbox();
				}

				positionArray = json.position;
				cameraPosition = json.camera_position;

				healthIcon = json.healthicon;
				singDuration = json.sing_duration;
				flipX = !!json.flip_x;
				if(json.no_antialiasing) {
					antialiasing = false;
					noAntialiasing = true;
				}

				if(json.healthbar_colors != null && json.healthbar_colors.length > 2)
					healthColorArray = json.healthbar_colors;

				antialiasing = !noAntialiasing;
				if(!ClientPrefs.globalAntialiasing) antialiasing = false;

				animationsArray = json.animations;
				if(animationsArray != null && animationsArray.length > 0) {
					for (anim in animationsArray) {
						var animAnim:String = '' + anim.anim;
						var animName:String = '' + anim.name;
						var animFps:Int = anim.fps;
						var animLoop:Bool = !!anim.loop; //Bruh
						var animIndices:Array<Int> = anim.indices;
						if(animIndices != null && animIndices.length > 0) {
							animation.addByIndices(animAnim, animName, animIndices, "", animFps, animLoop);
						} else {
							animation.addByPrefix(animAnim, animName, animFps, animLoop);
						}

						if(anim.offsets != null && anim.offsets.length > 1) {
							addOffset(anim.anim, anim.offsets[0], anim.offsets[1]);
						}
					}
				} else {
					quickAnimAdd('idle', 'BF idle dance');
				}
				//trace('Loaded file to character ' + curCharacter);
		}
		originalFlipX = flipX;

		recalculateDanceIdle();
		dance();

		if (isPlayer)
		{
			flipX = !flipX;

			/*// Doesn't flip for BF, since his are already in the right place???
			if (!curCharacter.startsWith('bf'))
			{
				// var animArray
				if(animation.getByName('singLEFT') != null && animation.getByName('singRIGHT') != null)
				{
					var oldRight = animation.getByName('singRIGHT').frames;
					animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
					animation.getByName('singLEFT').frames = oldRight;
				}

				// IF THEY HAVE MISS ANIMATIONS??
				if (animation.getByName('singLEFTmiss') != null && animation.getByName('singRIGHTmiss') != null)
				{
					var oldMiss = animation.getByName('singRIGHTmiss').frames;
					animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
					animation.getByName('singLEFTmiss').frames = oldMiss;
				}
			}*/
		}

		switch (curCharacter)
		{
			case 'sunday-guitar-note':
				noteSkin = 'GH_NOTES';
			case 'sunday-guitar':
				noteSkin = 'NOTE_assets';
			case 'sunday':
				noteSkin = 'NOTE_assets';
			case 'bf':
				noteSkin = 'NOTE_assets';
		}
	}

	override function update(elapsed:Float)
	{
		if(!debugMode && animation.curAnim != null)
		{
			if(heyTimer > 0)
			{
				heyTimer -= elapsed;
				if(heyTimer <= 0)
				{
					if(specialAnim && animation.curAnim.name == 'hey' || animation.curAnim.name == 'cheer')
					{
						specialAnim = false;
						dance();
					}
					heyTimer = 0;
				}
			} else if(specialAnim && animation.curAnim.finished)
			{
				specialAnim = false;
				dance();
			}

			if (!isPlayer)
			{
				if (animation.curAnim.name.startsWith('sing'))
				{
					holdTimer += elapsed;
				}

				if (holdTimer >= Conductor.stepCrochet * 0.001 * singDuration)
				{
					dance();
					holdTimer = 0;
				}
			}

			if(animation.curAnim.finished && animation.getByName(animation.curAnim.name + '-loop') != null)
			{
				playAnim(animation.curAnim.name + '-loop');
			}
		}
		super.update(elapsed);
	}

	public var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance()
	{
		if (!debugMode && !specialAnim)
		{
			if(danceIdle)
			{
				danced = !danced;

				if (danced)
					playAnim('danceRight' + idleSuffix);
				else
					playAnim('danceLeft' + idleSuffix);
			}
			else if(animation.getByName('idle' + idleSuffix) != null) {
					playAnim('idle' + idleSuffix);
			}
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		specialAnim = false;
		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			offset.set(daOffset[0], daOffset[1]);
		}
		else
			offset.set(0, 0);

		if (curCharacter.startsWith('gf'))
		{
			if (AnimName == 'singLEFT')
			{
				danced = true;
			}
			else if (AnimName == 'singRIGHT')
			{
				danced = false;
			}

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
			{
				danced = !danced;
			}
		}
	}

	public function recalculateDanceIdle() {
		danceIdle = (animation.getByName('danceLeft' + idleSuffix) != null && animation.getByName('danceRight' + idleSuffix) != null);
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}

	public function quickAnimAdd(name:String, anim:String)
	{
		animation.addByPrefix(name, anim, 24, false);
	}
}
