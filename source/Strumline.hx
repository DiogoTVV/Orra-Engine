package;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxSort;

using StringTools;

class StrumArrow extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var initialX:Int = 0;
	public var initialY:Int = 0;
	public var ratio:Float = 1;
	
	public function new(i:Int, size:Float)
	{
		super();
		animOffsets = new Map<String, Array<Dynamic>>();
		
		scrollFactor.set();
		frames = Paths.getSparrowAtlas('NOTE_assets');
		
		ID = i;
		antialiasing = true;
		//setGraphicSize(Std.int(width * 0.7));
		setGraphicSize(Std.int(width * size));
		switch(i)
		{
			case 0:
				animation.addByPrefix('static', 'arrowLEFT');
				animation.addByPrefix('pressed', 'left press', 24, false);
				animation.addByPrefix('confirm', 'left confirm', 24, false);
			case 1:
				animation.addByPrefix('static', 'arrowDOWN');
				animation.addByPrefix('pressed', 'down press', 24, false);
				animation.addByPrefix('confirm', 'down confirm', 24, false);
			case 2:
				animation.addByPrefix('static', 'arrowUP');
				animation.addByPrefix('pressed', 'up press', 24, false);
				animation.addByPrefix('confirm', 'up confirm', 24, false);
			case 3:
				animation.addByPrefix('static', 'arrowRIGHT');
				animation.addByPrefix('pressed', 'right press', 24, false);
				animation.addByPrefix('confirm', 'right confirm', 24, false);
		}
		
		var offFuck:Array<Int> = [0,0];
		if (i >= 1 && i < 3)
		{
			offFuck[0] = 2;
			offFuck[1] = 2;
			if (i == 1)
			{
				offFuck[0] -= 1;
				offFuck[1] += 2;
			}
		}
		ratio = (size + 0.3);
		
		addOffset('static');
		addOffset('pressed', -2, -2);
		addOffset('confirm', 24 + offFuck[0], 24 + offFuck[1]);
		playAnim('static');
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
	
	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
			offset.set(daOffset[0] + 22, daOffset[1] + 20);
		else
			offset.set(0, 0);
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
		animOffsets[name] = [x * ratio, y * ratio];
}

class Strumline extends FlxTypedGroup<FlxBasic>
{
	public var receptors:FlxTypedGroup<StrumArrow>;
	public var allNotes:FlxTypedGroup<Note>;
	public var holdsGroup:FlxTypedGroup<Note>;
	public var notesGroup:FlxTypedGroup<Note>;
	public var noteSplashes:FlxTypedGroup<NoteSplash>;
	
	public var characters:Array<Character>;
	public var isPlayer:Bool;
	public var downscroll:Bool;
	public var autoplay:Bool;
	
	public function new(xPos:Float, characters:Array<Character>, downscroll:Bool = false, isPlayer:Bool = false, autoplay:Bool = true, ?size:Float = 0.7)
	{
		super();
		this.characters = characters;
		this.downscroll = downscroll;
		this.isPlayer = isPlayer;
		this.autoplay = autoplay;
		
		receptors = new FlxTypedGroup<StrumArrow>();
		allNotes = new FlxTypedGroup<Note>();
		holdsGroup = new FlxTypedGroup<Note>();
		notesGroup = new FlxTypedGroup<Note>();
		noteSplashes = new FlxTypedGroup<NoteSplash>();
		
		for(i in 0...4)
		{
			var receptor:StrumArrow = new StrumArrow(i, size);
			//receptor.x = (xPos + (Note.swagWidth * i)) - ((Note.swagWidth * 4) / 2);
			receptor.x = (xPos + ((160 * size) * i)) - (((160 * size) * 4) / 2);
			receptor.y = (!downscroll ? (50) : (FlxG.height - 165));
			receptors.add(receptor);
			
			receptor.initialX = Math.floor(receptor.x);
			receptor.initialY = Math.floor(receptor.y);
			
			var splash = new NoteSplash(i, 'base');
			noteSplashes.add(splash);
		}
		
		add(holdsGroup);
		add(receptors);
		add(notesGroup);
		add(noteSplashes);
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if(autoplay)
		{
			for(strum in receptors)
			{
				if(strum.animation.finished
				&& strum.animation.curAnim.name == 'confirm')
					strum.playAnim('static');
			}
		}
		
		for(splash in noteSplashes)
		{
			var daStrum = receptors.members[splash.ID];
			splash.setPosition(daStrum.x, daStrum.y);
		}
	}
	
	// PUSH MEEEEE
	public function push(newNote:Note):Void
	{
		var chosenGroup = (newNote.isSustainNote ? holdsGroup : notesGroup);
		chosenGroup.add(newNote);
		allNotes.add(newNote);
		chosenGroup.sort(FlxSort.byY, !downscroll ? FlxSort.DESCENDING : FlxSort.ASCENDING);
	}
}