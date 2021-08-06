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

	var headspaceCutscene:FlxSprite;

	var handSelect:FlxSprite;
	var omoriTransitionSprite:FlxSprite;
	var bgFade:FlxSprite;
	var tween:FlxTween;
	

	public function new(talkingRight:Bool = true, ?dialogueList:Array<String>)
	{
		super();

		if (PlayState.SONG.song.toLowerCase() == 'headspace')
		{
			headspaceCutscene = new FlxSprite(0, 40);
			// the second paramater in the Paths command just decides what folder it try to find in, in place of the original 'week7' folder - Stahl
			headspaceCutscene.frames = Paths.getSparrowAtlas('headspaceCutscene', 'omori');
			headspaceCutscene.animation.addByPrefix('bump', 'logo bumpin', 3);
			headspaceCutscene.setGraphicSize(Std.int((headspaceCutscene.width / 1.2) * 0.8));
			headspaceCutscene.updateHitbox();
			add(headspaceCutscene);
			headspaceCutscene.animation.play('bump');
			headspaceCutscene.screenCenter();
			
		}

		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'headspace':
				FlxG.sound.playMusic(Paths.music('white_space', 'omori'), 0);
				FlxG.sound.music.fadeIn(5, 0, 1);
			case 'reverie':
				FlxG.sound.playMusic(Paths.music('spaces_in-between', 'omori'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
		}

		var hasDialog = false;
		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'headspace':
				box = new FlxSprite(-20, 0);
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('UI/dialogueBox', 'omori');
				box.animation.addByPrefix('normalOpen', 'Text Box Appear', 40, false);
				box.animation.addByIndices('normal', 'Text Box Appear', [10], "", 40);
			case 'reverie':
				box = new FlxSprite(-20, 0);
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('UI/dialogueBox', 'omori');
				box.animation.addByPrefix('normalOpen', 'Text Box Appear', 40, false);
				box.animation.addByIndices('normal', 'Text Box Appear', [10], "", 40);
			case 'guilty':
				box = new FlxSprite(-20, 0);
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('UI/dialogueBox', 'omori');
				box.animation.addByPrefix('normalOpen', 'Text Box Appear', 40, false);
				box.animation.addByIndices('normal', 'Text Box Appear', [10], "", 40);
		}

		this.dialogueList = dialogueList;
		
		if (!hasDialog)
			return;
		
		//removed the original week 6 exception - Stahl

		portraitLeft = new FlxSprite(-20, 40);
		portraitLeft.frames = Paths.getSparrowAtlas('senpaiPortrait', 'omori');
		portraitLeft.animation.addByPrefix('enter', 'Senpai Portrait Enter', 24, false);
		portraitLeft.setGraphicSize(Std.int(portraitLeft.width * PlayState.daPixelZoom * 0.9));
		portraitLeft.updateHitbox();
		portraitLeft.scrollFactor.set();
		add(portraitLeft);

		portraitLeft.visible = false;
		portraitRight = new FlxSprite(-20, 0).loadGraphic(Paths.image('bfPortrait', 'omori'));
		portraitRight.setGraphicSize(Std.int(portraitRight.width * 0.8));
		portraitRight.updateHitbox();
		portraitRight.scrollFactor.set();
		add(portraitRight);
		portraitRight.screenCenter();
		
		portraitRight.visible = false;
		portraitOmori = new FlxSprite(-20, 40);
		portraitOmori.frames = Paths.getSparrowAtlas('senpaiPortrait', 'omori');
		portraitOmori.animation.addByPrefix('enter', 'Senpai Portrait Enter', 24, false);
		portraitOmori.setGraphicSize(Std.int(portraitOmori.width * PlayState.daPixelZoom * 0.9));
		portraitOmori.updateHitbox();
		portraitOmori.scrollFactor.set();
		add(portraitOmori);
		portraitOmori.visible = false;

		box.animation.play('normalOpen');
		box.setGraphicSize(Std.int(box.width * 0.8));
		box.updateHitbox();
		add(box);

		box.screenCenter(X);
		portraitLeft.screenCenter(X);

		// hand select
		var handSelect:FlxSprite = new FlxSprite(995, 640).loadGraphic(Paths.image('UI/redHandTextbox', 'omori'));
		handSelect.setGraphicSize(Std.int(handSelect.width * 1.5));
		add(handSelect);
		handSelect.visible = true;
		FlxTween.tween(handSelect, {x: 980}, 0.85544454, { ease: FlxEase.quadInOut, startDelay: 0, type: FlxTweenType.PINGPONG });

		if (!talkingRight)
		{
			// box.flipX = true;
		}

		//main dialogue
		dropText = new FlxText(242, 542, Std.int(FlxG.width * 0.6), "", 40);
		dropText.font = 'OMORI_GAME';
		dropText.color = 0x000000;
		add(dropText);

		swagDialogue = new FlxTypeText(240, 540, Std.int(FlxG.width * 0.6), "", 40);
		swagDialogue.font = 'OMORI_GAME';
		swagDialogue.color = 0xFFFFFFFF;
		swagDialogue.sounds = [FlxG.sound.load(Paths.sound('omoriText'), 0.6)];
		add(swagDialogue);

		dialogue = new Alphabet(0, 200, "", false, true);
		
		// Please refer to StoryMenuState.hx to understand how I felt after
		// spending 6 hours attempting to randomly pitch the text noise, only
		// to find out that such an effect is impossible in OpenFL. :]

		// Me from a lot later here! I looked back at StoryMenuState.hx and
		// couldn't find that message. Idk if it's still there, but good luck
		// looking for it...

		// epic trolling I organized the code - Stahl

		// dialogue.x = 90;
		// add(dialogue);
	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;

	override function update(elapsed:Float)
	{
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

					// you might want to make it default case if it's going to be used in other song too - Stahl
					if (PlayState.SONG.song.toLowerCase() == 'headspace' || PlayState.SONG.song.toLowerCase() == 'reverie' || PlayState.SONG.song.toLowerCase() == 'guilty')
					{
						FlxG.sound.music.stop();

						FlxG.sound.play(Paths.sound('omoriTransition'), 0.8);
						var omoriTransitionSprite = new FlxSprite(300, 1000).loadGraphic(Paths.image('UI/omoriTransition', 'omori'));
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
					if (PlayState.SONG.song.toLowerCase() == 'headspace' || PlayState.SONG.song.toLowerCase() == 'reverie' || PlayState.SONG.song.toLowerCase() == 'guilty')
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