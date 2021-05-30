package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class BackgroundMewo extends FlxSprite
{
	public function new(x:Float, y:Float)
	{
		super(x, y);

		// BG fangirls dissuaded
		frames = Paths.getSparrowAtlas('mewoBounce');

		animation.addByIndices('danceLeft', 'BG girls group', CoolUtil.numberArray(30, 15), "", 30, false);
		animation.addByIndices('danceRight', 'BG girls group', CoolUtil.numberArray(14), "", 30, false);
	}

	var danceDir:Bool = false;

	public function dance():Void
	{
		danceDir = !danceDir;

		if (danceDir)
			animation.play('danceRight', true);
		else
			animation.play('danceLeft', true);
	}
}
