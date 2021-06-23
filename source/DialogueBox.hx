package;

import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.group.FlxGroup;

using StringTools;

class DialogueBox extends FlxSpriteGroup
{
	var box:FlxSprite;

	var transout:TransitionData;
	var curCharacter:String = '';

	var dialogue:Alphabet;
	var dialogueList:Array<String> = [];

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???
	var swagDialogue:FlxTypeText;

	var transitioning:Bool = false;
	var dropText:FlxText;

	public var finishThing:Void->Void;

	var portraitLeft:FlxSprite;
	var portraitRight:FlxSprite;
	var portraitOmori:FlxSprite;
	var portraitBoyfriend:FlxSprite;

	var handSelect:FlxSprite;
	var omoriTransitionSprite:FlxSprite;
	var bgFade:FlxSprite;
	var tween:FlxTween;
	

	public function new(talkingRight:Bool = true, ?dialogueList:Array<String>)
	{
		super();

		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'senpai':
				FlxG.sound.playMusic(Paths.music('Lunchbox'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			case 'thorns':
				FlxG.sound.playMusic(Paths.music('LunchboxScary'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			case 'headspace':
				FlxG.sound.playMusic(Paths.music('white_space'), 0);
				FlxG.sound.music.fadeIn(5, 0, 1);
		}

		if (PlayState.SONG.song.toLowerCase() == 'senpai' || PlayState.SONG.song.toLowerCase() == 'roses' || PlayState.SONG.song.toLowerCase() == 'thorns')
		{
			bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFFB3DFd8);
			bgFade.scrollFactor.set();
			bgFade.alpha = 0;
			add(bgFade);

			new FlxTimer().start(0.83, function(tmr:FlxTimer)
			{
				bgFade.alpha += (1 / 5) * 0.7;
				if (bgFade.alpha > 0.7)
					bgFade.alpha = 0.7;
			}, 5);
		}
		var hasDialog = false;
		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'senpai':
				box = new FlxSprite(-20, 45);
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-pixel');
				box.animation.addByPrefix('normalOpen', 'Text Box Appear', 24, false);
				box.animation.addByIndices('normal', 'Text Box Appear', [4], "", 24);
			case 'roses':
				box = new FlxSprite(-20, 45);
				hasDialog = true;
				FlxG.sound.play(Paths.sound('ANGRY_TEXT_BOX'));

				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-senpaiMad');
				box.animation.addByPrefix('normalOpen', 'SENPAI ANGRY IMPACT SPEECH', 24, false);
				box.animation.addByIndices('normal', 'SENPAI ANGRY IMPACT SPEECH', [4], "", 24);

			case 'thorns':
				box = new FlxSprite(-20, 45);
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-evil');
				box.animation.addByPrefix('normalOpen', 'Spirit Textbox spawn', 24, false);
				box.animation.addByIndices('normal', 'Spirit Textbox spawn', [11], "", 24);

				var face:FlxSprite = new FlxSprite(320, 170).loadGraphic(Paths.image('weeb/spiritFaceForward'));
				face.setGraphicSize(Std.int(face.width * 6));
				add(face);
			case 'headspace':
				box = new FlxSprite(-20, 0);
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('omori/UI/dialogueBox');
				box.animation.addByPrefix('normalOpen', 'Text Box Appear', 40, false);
				box.animation.addByIndices('normal', 'Text Box Appear', [10], "", 40);
		}

		this.dialogueList = dialogueList;
		
		if (!hasDialog)
			return;
		
		portraitLeft = new FlxSprite(-20, 40);
		portraitLeft.frames = Paths.getSparrowAtlas('weeb/senpaiPortrait');
		portraitLeft.animation.addByPrefix('enter', 'Senpai Portrait Enter', 24, false);
		portraitLeft.setGraphicSize(Std.int(portraitLeft.width * PlayState.daPixelZoom * 0.9));
		portraitLeft.updateHitbox();
		portraitLeft.scrollFactor.set();
		add(portraitLeft);
		portraitLeft.visible = false;

		portraitRight = new FlxSprite(0, 40);
		portraitRight.frames = Paths.getSparrowAtlas('weeb/bfPortrait');
		portraitRight.animation.addByPrefix('enter', 'Boyfriend portrait enter', 24, false);
		portraitRight.setGraphicSize(Std.int(portraitRight.width * PlayState.daPixelZoom * 0.9));
		portraitRight.updateHitbox();
		portraitRight.scrollFactor.set();
		add(portraitRight);
		portraitRight.visible = false;

		portraitOmori = new FlxSprite(-20, 40);
		portraitOmori.frames = Paths.getSparrowAtlas('weeb/senpaiPortrait');
		portraitOmori.animation.addByPrefix('enter', 'Senpai Portrait Enter', 24, false);
		portraitOmori.setGraphicSize(Std.int(portraitOmori.width * PlayState.daPixelZoom * 0.9));
		portraitOmori.updateHitbox();
		portraitOmori.scrollFactor.set();
		add(portraitOmori);
		portraitOmori.visible = false;

		if (PlayState.SONG.song.toLowerCase() == 'senpai' || PlayState.SONG.song.toLowerCase() == 'roses' || PlayState.SONG.song.toLowerCase() == 'thorns')
		{
			box.animation.play('normalOpen');
			box.setGraphicSize(Std.int(box.width * PlayState.daPixelZoom * 0.9));
			box.updateHitbox();
			add(box);
		}
		else
		{
			box.animation.play('normalOpen');
			box.setGraphicSize(Std.int(box.width * 0.8));
			box.updateHitbox();
			add(box);
		}

		box.screenCenter(X);
		portraitLeft.screenCenter(X);

		if (PlayState.SONG.song.toLowerCase() == 'senpai' || PlayState.SONG.song.toLowerCase() == 'roses' || PlayState.SONG.song.toLowerCase() == 'thorns')
		{
			var handSelect = new FlxSprite(FlxG.width * 0.9, FlxG.height * 0.9).loadGraphic(Paths.image('weeb/pixelUI/hand_textbox'));
			add(handSelect);
		}
		if (PlayState.SONG.song.toLowerCase() == 'headspace')
		{
			var handSelect:FlxSprite = new FlxSprite(995, 640).loadGraphic(Paths.image('omori/UI/redHandTextbox'));
			handSelect.setGraphicSize(Std.int(handSelect.width * 1.5));
			add(handSelect);
			handSelect.visible = true;
			FlxTween.tween(handSelect, {x: 980}, 0.85544454, { ease: FlxEase.quadInOut, startDelay: 0, type: FlxTweenType.PINGPONG });
		}

		

		if (!talkingRight)
		{
			// box.flipX = true;
		}

		dropText = new FlxText(242, 542, Std.int(FlxG.width * 0.6), "", 40);
		dropText.font = 'OMORI_GAME';
		dropText.color = 0x000000;
		add(dropText);

		if (PlayState.SONG.song.toLowerCase() == 'senpai' || PlayState.SONG.song.toLowerCase() == 'roses' || PlayState.SONG.song.toLowerCase() == 'thorns')
		{
			swagDialogue = new FlxTypeText(240, 540, Std.int(FlxG.width * 0.6), "", 40);
			swagDialogue.font = 'OMORI_GAME';
			swagDialogue.color = 0xFFFFFFFF;
			swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
			add(swagDialogue);
		}
		else
		{
			swagDialogue = new FlxTypeText(240, 540, Std.int(FlxG.width * 0.6), "", 40);
			swagDialogue.font = 'OMORI_GAME';
			swagDialogue.color = 0xFFFFFFFF;
			swagDialogue.sounds = [FlxG.sound.load(Paths.sound('omoriText'), 0.6)];
			add(swagDialogue);
		}
		// Please refer to StoryMenuState.hx to understand how I felt after
		// spending 6 hours attempting to randomly pitch the text noise, only
		// to find out that such an effect is impossible in OpenFL. :]

		dialogue = new Alphabet(0, 200, "", false, true);
		// dialogue.x = 90;
		// add(dialogue);
	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;

	override function update(elapsed:Float)
	{
		// HARD CODING CUZ IM STUPDI
		if (PlayState.SONG.song.toLowerCase() == 'roses')
			portraitLeft.visible = false;
		if (PlayState.SONG.song.toLowerCase() == 'thorns')
		{
			portraitLeft.color = FlxColor.BLACK;
			swagDialogue.color = FlxColor.WHITE;
			dropText.color = FlxColor.BLACK;
		}

		dropText.text = swagDialogue.text;

		if (box.animation.curAnim != null)
		{
			if (box.animation.curAnim.name == 'normalOpen' && box.animation.curAnim.finished)
			{
				dialogueOpened = true;
			}
		}

		if (dialogueOpened && !dialogueStarted)
		{
			startDialogue();
			dialogueStarted = true;
		}

		if (FlxG.keys.justPressed.ANY  && dialogueStarted == true)
		{
			remove(dialogue);

			if (dialogueList[1] == null && dialogueList[0] != null)
			{
				if (!isEnding)
				{
					isEnding = true;
					
					if (PlayState.SONG.song.toLowerCase() == 'Senpai' || PlayState.SONG.song.toLowerCase() == 'Thorns')
					{
						FlxG.sound.music.fadeOut(2.2, 0);
						new FlxTimer().start(0.2, function(tmr:FlxTimer)
						{
							box.alpha -= 1 / 5;
							bgFade.alpha -= 1 / 5 * 0.7;
							portraitLeft.visible = false;
							portraitRight.visible = false;
							swagDialogue.alpha -= 1 / 5;
							dropText.alpha = swagDialogue.alpha;
						}, 5);
					}
					if (PlayState.SONG.song.toLowerCase() == 'headspace')
					{
						FlxG.sound.music.stop();

						FlxG.sound.play(Paths.sound('omoriTransition'), 0.8);
						var omoriTransitionSprite = new FlxSprite(300, 1000).loadGraphic(Paths.image('omori/UI/omoriTransition'));
						omoriTransitionSprite.screenCenter(X);
						add(omoriTransitionSprite);
						omoriTransitionSprite.visible = true;
						FlxTween.tween(omoriTransitionSprite, {y: -1000}, 0.7, { ease: FlxEase.linear, startDelay: 0, type: FlxTweenType.PERSIST });
					}
					new FlxTimer().start(1.2, function(tmr:FlxTimer)
					{
						transitioning = true;
						finishThing();
						kill();
					});
				}
			}
			else
			{
				dialogueList.remove(dialogueList[0]);
				startDialogue();
				
			}
		}
		
		super.update(elapsed);
	}

	var isEnding:Bool = false;

	function startDialogue():Void
	{
		cleanDialog();
		// var theDialog:Alphabet = new Alphabet(0, 70, dialogueList[0], false, true);
		// dialogue = theDialog;
		// add(theDialog);
	
		// swagDialogue.text = ;
		swagDialogue.resetText(dialogueList[0]);
		swagDialogue.start(0.03, true);

		switch (curCharacter)
		{
			case 'dad':
				portraitRight.visible = false;
				if (!portraitLeft.visible)
				{
					portraitLeft.visible = true;
					portraitLeft.animation.play('enter');
				}
			case 'bf':
				portraitLeft.visible = false;
				if (!portraitRight.visible)
				{
					portraitRight.visible = true;
					portraitRight.animation.play('enter');
				}
			case 'narrator':
				portraitLeft.visible = false;
				portraitRight.visible = false;
		}
	}
	
	function cleanDialog():Void
	{
		var splitName:Array<String> = dialogueList[0].split(":");
		curCharacter = splitName[1];
		dialogueList[0] = dialogueList[0].substr(splitName[1].length + 2).trim();
	}
}