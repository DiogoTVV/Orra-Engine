package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;

class NoteSplash extends FlxSprite
{
	public var offsets:Array<Int> = [0,0];
	
	public function new(i:Int, assetModifier:String = 'base')
	{
		super();
		ID = i;
		
		switch(assetModifier)
		{
			default:
				frames = Paths.getSparrowAtlas('notes/NOTE_splashes');
				animation.addByPrefix('anim1', 'note splash ${getAnim(i)} 1', 24, false);
				animation.addByPrefix('anim2', 'note splash ${getAnim(i)} 2', 24, false);
				animation.play('anim1');
				offsets = [80, 74];
		}
	}
	
	var directions:Array<String> = ['purple', 'blue', 'green', 'red'];
	function getAnim(i:Int):String
	{
		var anim = directions[i];
		return anim;
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		offset.set(offsets[0], offsets[1]);
		
		if(animation.curAnim.finished)
			alpha = 0;
		else
			alpha = 1;
	}
}