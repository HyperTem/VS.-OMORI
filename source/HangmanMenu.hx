package;

import lime.system.System;
import openfl.Lib;
import lime.app.Application;
import flixel.addons.ui.FlxUIInputText;
import flixel.input.keyboard.FlxKey;
import sys.FileSystem;
import flixel.FlxObject;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.system.FlxSound;
import flixel.util.FlxGradient;
#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.addons.text.FlxTypeText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.addons.display.FlxBackdrop;

using StringTools;

class HangmanMenu extends MusicBeatState
{
    public static var curSelected:Int = 0;

    var goingBack:Bool = false;

    var textTyped:Bool = false;

    var dialogueOpened:Bool = false;
    
    var dialogueStarted:Bool = false;

    var nameLength:Int = 0;

    var camLerp:Float = 0.16;

    var chooseName:FlxText;

    var swagDialogue:FlxTypeText;

    var swagDialogue2:FlxTypeText;

    var name:FlxUIInputText;

    var hangmanTitle:Alphabet;

    var hangmanKeys:Alphabet;

    var hangmanKeys2:Alphabet;

    var box:FlxSprite;

    public var curName:String = "";

    public static var nameResult:String = "";
    public static var coming:String = "";

    var bsDialogueList:Array<String> = [
        "WARNING!! Activating this will reveal huge spoilers for OMORI's story! Please play OMORI before activating this! Press ESCAPE to leave or ENTER to keep going.",
        "It's a long way down... do you want to jump?"
    ];

    public function new()
    {
        super();

        var bg:FlxSprite = new FlxSprite(0).loadGraphic(Paths.image('blankBlackboard'));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		hangmanTitle = new Alphabet(2, 38, 'hangman', false, false, true);
        hangmanTitle.x = 38;
        add(hangmanTitle);
            
        chooseName = new FlxText(FlxG.width * 0.7, 25, 0, "You know what to do.", 32);
		chooseName.setFormat(Paths.font("OMORI_GAME.ttf"), 32, FlxColor.WHITE, RIGHT);
		chooseName.alignment = CENTER;
		chooseName.setBorderStyle(OUTLINE, 0xFF000000, 5, 1);
		chooseName.x = 38;
		chooseName.y = 124;
        chooseName.scrollFactor.set();
		add(chooseName);

        name = new FlxUIInputText(10, 10, FlxG.width, '', 8);
		name.setFormat(Paths.font("vcr.ttf"), 72, FlxColor.WHITE, RIGHT);
		name.alignment = CENTER;
		name.setBorderStyle(OUTLINE, 0xFF000000, 5, 1);
		name.screenCenter();
        name.scrollFactor.set();
		add(name);
        name.backgroundColor = 0xFF000000;
        name.maxLength = 23;
        name.lines = 2;
        name.caretColor = 0xFFFFFFFF;
        name.visible = false;
        
        new FlxTimer().start(0.1, function(tmr:FlxTimer)
			{
				selectable = true;
			});
    }

    var selectable:Bool = false;

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        name.hasFocus = true;

        if (FlxG.keys.justPressed.ANY)
        {
            if (textTyped == true)
            {
                remove (hangmanKeys);
                remove (hangmanKeys2);
            }

            nameLength = name.text.length;

            if (nameLength >= 11)
            {
            hangmanKeys = new Alphabet(3, 100, (name.text.substr(0, 11).trim()), false, false, true);
            hangmanKeys.screenCenter();
            hangmanKeys.y = (hangmanKeys.y - 32);
            hangmanKeys.scrollFactor.set();
            add(hangmanKeys);
            textTyped = true;

            hangmanKeys2 = new Alphabet(3, 100, (name.text.substr(11).trim()), false, false, true);
            hangmanKeys2.screenCenter();
            hangmanKeys2.y = (hangmanKeys2.y + 32);
            hangmanKeys2.scrollFactor.set();
            add(hangmanKeys2);
            textTyped = true;
            }
            if (nameLength < 11)
            {
                hangmanKeys = new Alphabet(3, 100, (name.text.toLowerCase()), false, false, true);
                hangmanKeys.screenCenter();
                hangmanKeys.scrollFactor.set();
                add(hangmanKeys);
                textTyped = true;
            }
        }

        switch (name.text.toLowerCase())
        {
            case 'gaster':
                System.exit(0);
            case 'error':
                FlxG.game.stage.window.alert('Got you!', 'Boo!');
            case 'tyler':
                trace("Tyler Mode successfully activated!");
        }

        if (selectable && !goingBack)
        {
            if (FlxG.keys.justPressed.ESCAPE)
                {
                    goingBack = true;
                    FlxG.sound.play(Paths.sound('cancelMenu'));
                    FlxTween.tween(name, { 'scale.x': 0}, 0.5, { ease: FlxEase.expoIn});
                    FlxTween.tween(chooseName, { 'scale.x': 0}, 0.5, { ease: FlxEase.expoIn});
                    new FlxTimer().start(0.5, function(tmr:FlxTimer)
                        {
                            nameResult = name.text;
                            FlxG.switchState(new MainMenuState());
                        });
                }
        
            if (FlxG.keys.justPressed.ENTER && name.text != '')
            {
                nameResult = name.text;
                if (nameResult == "welcome to black space")
                {
                    if (bsDialogueList[1] == null && bsDialogueList[0] != null)
                    {
                        StoryMenuState.weekUnlocked[StoryMenuState.secretWeek] = true;
                        StoryMenuState.weekData[StoryMenuState.secretWeek] = ['Alter'];
                        StoryMenuState.weekCharacters[StoryMenuState.secretWeek] = ['omori', 'bf', 'gf'];
                        StoryMenuState.weekNames[StoryMenuState.secretWeek] = "Red Hands";
                        FlxG.sound.music.stop();
                        remove(swagDialogue);
                        swagDialogue = new FlxTypeText(240, 540, Std.int(FlxG.width * 0.6), (bsDialogueList[0]), 40);
                        swagDialogue.font = 'OMORI_GAME';
                        swagDialogue.color = 0xFFFFFFFF;
                        swagDialogue.sounds = [FlxG.sound.load(Paths.sound('omoriText'), 0.6)];
                        add(swagDialogue);
                        swagDialogue.resetText(bsDialogueList[0]);
                        swagDialogue.start(0.03, true);
                        bsDialogueList.remove(bsDialogueList[0]);
                        new FlxTimer().start(3.5, function(tmr:FlxTimer)
                            {
                                FlxG.switchState(new MainMenuState());
                            });
                    }
                    else
                    {
                        FlxG.sound.play(Paths.sound('confirmLaptop'));
                        new FlxTimer().start(1.5, function(tmr:FlxTimer)
                        {
                            {
                                box = new FlxSprite(-20, 0);
                                box.frames = Paths.getSparrowAtlas('omoriDialogueBox');
                                box.animation.addByPrefix('normalOpen', 'Text Box Appear', 40, false);
                                box.animation.addByIndices('normal', 'Text Box Appear', [10], "", 40);
                                box.animation.play('normalOpen');
                                box.setGraphicSize(Std.int(box.width * 0.8));
                                box.updateHitbox();
                                add(box);
                                box.screenCenter(X);
                            }
    
                            new FlxTimer().start(0.025, function(tmr:FlxTimer)
                            {
                                swagDialogue = new FlxTypeText(240, 540, Std.int(FlxG.width * 0.6), (bsDialogueList[0]), 40);
                                swagDialogue.font = 'OMORI_GAME';
                                swagDialogue.color = 0xFFFFFFFF;
                                swagDialogue.sounds = [FlxG.sound.load(Paths.sound('omoriText'), 0.6)];
                                add(swagDialogue);
                                swagDialogue.resetText(bsDialogueList[0]);
                                swagDialogue.start(0.03, true);
                                bsDialogueList.remove(bsDialogueList[0]);
                            });
                        });
                    }
                }
                else
                {
                    FlxG.switchState(new MainMenuState());
                }
            }
        }
    }
}