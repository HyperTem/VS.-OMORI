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

    var longDialogueStarted:Bool = false;

    var screenLock:Bool = false;
    
    var exitLock:Bool = false;

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
    
    var wishDialogueList:Array<String> = [
        "Hello, everyone! I'm WISH, RECIPIENT, playtester and chart editor for the VS. OMORI mod.",
        "It's been an honor working on this project; it's the first FNF mod I've worked on (even if I didn't do that much), and I hope this leads to many more.",
        "I'm so thankful to HyperTem for inviting me to the mod in the first place, but I'd also like to shoutout the rest of the team:",
        "Julie's been amazing to work with, Miles has pumped out banger after banger, ~~Sh~~artCarrot, Basil, and Moony have given amazing shape to the mod, and Dylan",
        "uhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh /j",
        "If you'd like to see some more of my charting work (or think you can beat me in a 4K 1v1), I'm 'Necross' on Quaver.",
        "I'll probably change my Twitter handle again in the future, but for now it's @WISH_RECIPIENT; I don't do much there, but I appreciate the attention.",
        "THANK YOU FOR... PLAYING.",
    ];
    var hypertemDialogueList:Array<String> = [
        "Hi!! I'm HyperTem, and I did the programming and stage art for this mod!",
        "I'm gonna be honest, I had ZERO coding experience before working on this mod. This has been a huge learning experience for me, but it's been such a fun ride...",
        "It's always been a life goal of mine to learn how to make a game, and helping create this has bought me closer to that than ever...",
        "I probably wouldn't have gotten around to it without this mod, honestly.",
        "It's been such a wonderful experience putting this together, and i've met so many wonderful people in the time i've been making this mod happen,,,,",
        "A huge thanks to Moony for bringing the team together and letting all of us make this, Miles for putting together the absolute bangers of this mod...",
        "Carrot for making the wonderful Omori sprites, Julie and Wish for putting together the charts and making them the best they can be...",
        "Springy for making our menus look swag, Dylan for moral support...",
        "And all of the above for being wonderful friends. I love you all!",
        "I hope you loved playing this mod as much as I loved making it. Thanks for playing!",
        "Oh, and also, type 'wombo' on Hangman. :]"
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
            case 'poggers':
                System.exit(0);
            case 'do not sub to sticky':
                System.exit(0);
            case 'gaster':
                System.exit(0);
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
                nameResult = name.text.toLowerCase();
                if (screenLock != true)
                {
                    switch (nameResult)
                    {
                        // case "welcome to black space":
                        /* {
                            if (bsDialogueList[1] == null && bsDialogueList[0] != null)
                            {
                                screenLock = true;
                                FlxG.save.data.AlterUnlocked = true;
                                FlxG.save.data.altMenu = true;
                                FlxG.sound.music.fadeOut(1, 0);
                                remove(swagDialogue);
                                swagDialogue = new FlxTypeText(240, 540, Std.int(FlxG.width * 0.6), (bsDialogueList[0]), 40);
                                swagDialogue.font = 'OMORI_GAME';
                                swagDialogue.color = 0xFFFFFFFF;
                                swagDialogue.sounds = [FlxG.sound.load(Paths.sound('omoriText'), 0.6)];
                                add(swagDialogue);
                                swagDialogue.resetText(bsDialogueList[0]);
                                swagDialogue.start(0.03, true, false, [], unlockExit);
                                bsDialogueList.remove(bsDialogueList[0]);
                            }
                            else
                            {
                                screenLock = true;
                                exitLock = true;
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
                                        swagDialogue.start(0.03, true, false, [], unlockText);
                                        bsDialogueList.remove(bsDialogueList[0]);
                                    });
                                });
                            }
                        } */
                        case "wish":
                        {
                            if (wishDialogueList[1] == null && wishDialogueList[0] != null)
                            {
                                screenLock = true;
                                remove(swagDialogue);
                                swagDialogue = new FlxTypeText(240, 540, Std.int(FlxG.width * 0.6), (wishDialogueList[0]), 40);
                                swagDialogue.font = 'OMORI_GAME';
                                swagDialogue.color = 0xFFFFFFFF;
                                swagDialogue.sounds = [FlxG.sound.load(Paths.sound('omoriText'), 0.6)];
                                add(swagDialogue);
                                swagDialogue.resetText(wishDialogueList[0]);
                                swagDialogue.start(0.03, true, false, [], unlockExit);
                                wishDialogueList.remove(wishDialogueList[0]);
                            }
                            else if (longDialogueStarted == false)
                            {
                                screenLock = true;
                                exitLock = true;
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
                                        swagDialogue = new FlxTypeText(240, 540, Std.int(FlxG.width * 0.6), (wishDialogueList[0]), 40);
                                        swagDialogue.font = 'OMORI_GAME';
                                        swagDialogue.color = 0xFFFFFFFF;
                                        swagDialogue.sounds = [FlxG.sound.load(Paths.sound('omoriText'), 0.6)];
                                        add(swagDialogue);
                                        swagDialogue.resetText(wishDialogueList[0]);
                                        swagDialogue.start(0.03, true, false, [], unlockText);
                                        wishDialogueList.remove(wishDialogueList[0]);
                                        longDialogueStarted = true;
                                    });
                                });
                            }
                            else
                            {
                                screenLock = true;
                                remove(swagDialogue);
                                swagDialogue = new FlxTypeText(240, 540, Std.int(FlxG.width * 0.6), (wishDialogueList[0]), 40);
                                swagDialogue.font = 'OMORI_GAME';
                                swagDialogue.color = 0xFFFFFFFF;
                                swagDialogue.sounds = [FlxG.sound.load(Paths.sound('omoriText'), 0.6)];
                                add(swagDialogue);
                                swagDialogue.resetText(wishDialogueList[0]);
                                swagDialogue.start(0.03, true, false, [], unlockText);
                                wishDialogueList.remove(wishDialogueList[0]);
                            }
                        }
                        case "wish recipient":
                        {
                            if (wishDialogueList[1] == null && wishDialogueList[0] != null)
                            {
                                screenLock = true;
                                remove(swagDialogue);
                                swagDialogue = new FlxTypeText(240, 540, Std.int(FlxG.width * 0.6), (wishDialogueList[0]), 40);
                                swagDialogue.font = 'OMORI_GAME';
                                swagDialogue.color = 0xFFFFFFFF;
                                swagDialogue.sounds = [FlxG.sound.load(Paths.sound('omoriText'), 0.6)];
                                add(swagDialogue);
                                swagDialogue.resetText(wishDialogueList[0]);
                                swagDialogue.start(0.03, true, false, [], unlockExit);
                                wishDialogueList.remove(wishDialogueList[0]);
                            }
                            else if (longDialogueStarted == false)
                            {
                                screenLock = true;
                                exitLock = true;
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
                                        swagDialogue = new FlxTypeText(240, 540, Std.int(FlxG.width * 0.6), (wishDialogueList[0]), 40);
                                        swagDialogue.font = 'OMORI_GAME';
                                        swagDialogue.color = 0xFFFFFFFF;
                                        swagDialogue.sounds = [FlxG.sound.load(Paths.sound('omoriText'), 0.6)];
                                        add(swagDialogue);
                                        swagDialogue.resetText(wishDialogueList[0]);
                                        swagDialogue.start(0.03, true, false, [], unlockText);
                                        wishDialogueList.remove(wishDialogueList[0]);
                                        longDialogueStarted = true;
                                    });
                                });
                            }
                            else
                            {
                                screenLock = true;
                                remove(swagDialogue);
                                swagDialogue = new FlxTypeText(240, 540, Std.int(FlxG.width * 0.6), (wishDialogueList[0]), 40);
                                swagDialogue.font = 'OMORI_GAME';
                                swagDialogue.color = 0xFFFFFFFF;
                                swagDialogue.sounds = [FlxG.sound.load(Paths.sound('omoriText'), 0.6)];
                                add(swagDialogue);
                                swagDialogue.resetText(wishDialogueList[0]);
                                swagDialogue.start(0.03, true, false, [], unlockText);
                                wishDialogueList.remove(wishDialogueList[0]);
                            }
                        }
                        case "julie":
                        {
                            screenLock = true;
                            exitLock = true;
                            FlxG.sound.play(Paths.sound('confirmLaptop'));
                            new FlxTimer().start(1.5, function(tmr:FlxTimer)
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
                                new FlxTimer().start(0.025, function(tmr:FlxTimer)
                                {
                                    swagDialogue = new FlxTypeText(240, 540, Std.int(FlxG.width * 0.6), "You feel the need to check 'https://youtu.be/i3R7Xb4xQWg', because HyperTem couldn't get webms working in time. Sad!", 40);
                                    swagDialogue.font = 'OMORI_GAME';
                                    swagDialogue.color = 0xFFFFFFFF;
                                    swagDialogue.sounds = [FlxG.sound.load(Paths.sound('omoriText'), 0.6)];
                                    add(swagDialogue);
                                    swagDialogue.start(0.03, true, false, [], unlockExit);
                                });
                            });
                        }
                        case "welcome to black space":
                        {
                            screenLock = true;
                            exitLock = true;
                            FlxG.sound.play(Paths.sound('confirmLaptop'));
                            new FlxTimer().start(1.5, function(tmr:FlxTimer)
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
                                new FlxTimer().start(0.025, function(tmr:FlxTimer)
                                {
                                    swagDialogue = new FlxTypeText(240, 540, Std.int(FlxG.width * 0.6), "Coming soon...", 40);
                                    swagDialogue.font = 'OMORI_GAME';
                                    swagDialogue.color = 0xFFFFFFFF;
                                    swagDialogue.sounds = [FlxG.sound.load(Paths.sound('omoriText'), 0.6)];
                                    add(swagDialogue);
                                    swagDialogue.start(0.03, true, false, [], unlockExit);
                                });
                            });
                        }
                        case "hypertem":
                        {
                            if (hypertemDialogueList[1] == null && hypertemDialogueList[0] != null)
                            {
                                screenLock = true;
                                remove(swagDialogue);
                                swagDialogue = new FlxTypeText(240, 540, Std.int(FlxG.width * 0.6), (hypertemDialogueList[0]), 40);
                                swagDialogue.font = 'OMORI_GAME';
                                swagDialogue.color = 0xFFFFFFFF;
                                swagDialogue.sounds = [FlxG.sound.load(Paths.sound('omoriText'), 0.6)];
                                add(swagDialogue);
                                swagDialogue.resetText(hypertemDialogueList[0]);
                                swagDialogue.start(0.03, true, false, [], unlockExit);
                                hypertemDialogueList.remove(hypertemDialogueList[0]);
                            }
                            else if (longDialogueStarted == false)
                            {
                                screenLock = true;
                                exitLock = true;
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
                                        swagDialogue = new FlxTypeText(240, 540, Std.int(FlxG.width * 0.6), (hypertemDialogueList[0]), 40);
                                        swagDialogue.font = 'OMORI_GAME';
                                        swagDialogue.color = 0xFFFFFFFF;
                                        swagDialogue.sounds = [FlxG.sound.load(Paths.sound('omoriText'), 0.6)];
                                        add(swagDialogue);
                                        swagDialogue.resetText(hypertemDialogueList[0]);
                                        swagDialogue.start(0.03, true, false, [], unlockText);
                                        hypertemDialogueList.remove(hypertemDialogueList[0]);
                                        longDialogueStarted = true;
                                    });
                                });
                            }
                            else
                            {
                                screenLock = true;
                                remove(swagDialogue);
                                swagDialogue = new FlxTypeText(240, 540, Std.int(FlxG.width * 0.6), (hypertemDialogueList[0]), 40);
                                swagDialogue.font = 'OMORI_GAME';
                                swagDialogue.color = 0xFFFFFFFF;
                                swagDialogue.sounds = [FlxG.sound.load(Paths.sound('omoriText'), 0.6)];
                                add(swagDialogue);
                                swagDialogue.resetText(hypertemDialogueList[0]);
                                swagDialogue.start(0.03, true, false, [], unlockText);
                                hypertemDialogueList.remove(hypertemDialogueList[0]);
                            }
                        }
                        case "please sub to sticky":
                        {
                            screenLock = true;
                            exitLock = true;
                            FlxG.save.data.stickyMewoUnlocked = true;
                            FlxG.sound.play(Paths.sound('confirmLaptop'));
                            new FlxTimer().start(1.5, function(tmr:FlxTimer)
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
                                new FlxTimer().start(0.025, function(tmr:FlxTimer)
                                {
                                    swagDialogue = new FlxTypeText(240, 540, Std.int(FlxG.width * 0.6), "Listen, I know it's the 5th time we've done this, but I promise it won't crash this time... I think.", 40);
                                    swagDialogue.font = 'OMORI_GAME';
                                    swagDialogue.color = 0xFFFFFFFF;
                                    swagDialogue.sounds = [FlxG.sound.load(Paths.sound('omoriText'), 0.6)];
                                    add(swagDialogue);
                                    swagDialogue.start(0.03, true, false, [], unlockExit);
                                });
                            });
                        }
                        case "set him free":
                        {
                            screenLock = true;
                            exitLock = true;
                            FlxG.save.data.tylerReleased = true;
                            FlxG.sound.play(Paths.sound('confirmLaptop'));
                            new FlxTimer().start(1.5, function(tmr:FlxTimer)
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
                                new FlxTimer().start(2, function(tmr:FlxTimer)
                                {
                                    swagDialogue = new FlxTypeText(240, 540, Std.int(FlxG.width * 0.6), "...Finally.", 40);
                                    swagDialogue.font = 'OMORI_GAME';
                                    swagDialogue.color = 0xFFFFFFFF;
                                    swagDialogue.sounds = [FlxG.sound.load(Paths.sound('omoriText'), 0.6)];
                                    add(swagDialogue);
                                    swagDialogue.start(0.03, true, false, [], unlockExit);
                                });
                            });
                        }
                        case "artcarrot":
                        {
                            screenLock = true;
                            exitLock = true;
                            FlxG.sound.play(Paths.sound('confirmLaptop'));
                            new FlxTimer().start(1.5, function(tmr:FlxTimer)
                            {
                                FlxG.sound.play(Paths.sound('pageTurn'), 1.7);
                                var artcarrot:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('secrets/artcarrot'));
                                artcarrot.screenCenter();
                                artcarrot.antialiasing = true;
                                artcarrot.alpha = 0;
                                add(artcarrot);
                                FlxTween.tween(artcarrot, {alpha: 1}, 1);
                                new FlxTimer().start(1, function(tmr:FlxTimer)
                                {
                                    exitLock = false;
                                });
                            });
                        }
                        case "basildev":
                        {
                            screenLock = true;
                            exitLock = true;
                            FlxG.sound.play(Paths.sound('confirmLaptop'));
                            new FlxTimer().start(1.5, function(tmr:FlxTimer)
                            {
                                FlxG.sound.play(Paths.sound('pageTurn'), 1.7);
                                var basildev:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('secrets/springy'));
                                basildev.screenCenter();
                                basildev.antialiasing = true;
                                basildev.alpha = 0;
                                add(basildev);
                                FlxTween.tween(basildev, {alpha: 1}, 1);
                                new FlxTimer().start(1, function(tmr:FlxTimer)
                                {
                                    exitLock = false;
                                });
                            });
                        }
                        case "springy":
                        {
                            screenLock = true;
                            exitLock = true;
                            FlxG.sound.play(Paths.sound('confirmLaptop'));
                            new FlxTimer().start(1.5, function(tmr:FlxTimer)
                            {
                                FlxG.sound.play(Paths.sound('pageTurn'), 1.7);
                                var springy:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('secrets/springy'));
                                springy.screenCenter();
                                springy.antialiasing = true;
                                springy.alpha = 0;
                                add(springy);
                                FlxTween.tween(springy, {alpha: 1}, 1);
                                new FlxTimer().start(1, function(tmr:FlxTimer)
                                {
                                    exitLock = false;
                                });
                            });
                        }
                        case "miles":
                        {
                            screenLock = true;
                            exitLock = true;
                            FlxG.sound.play(Paths.sound('confirmLaptop'));
                            new FlxTimer().start(1.5, function(tmr:FlxTimer)
                            {
                                FlxG.sound.play(Paths.sound('pageTurn'), 1.7);
                                var miles:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('secrets/miles'));
                                miles.screenCenter();
                                miles.antialiasing = true;
                                miles.alpha = 0;
                                add(miles);
                                FlxTween.tween(miles, {alpha: 1}, 1);
                                new FlxTimer().start(1, function(tmr:FlxTimer)
                                {
                                    exitLock = false;
                                });
                            });
                        }
                        case "calum":
                        {
                            screenLock = true;
                            exitLock = true;
                            FlxG.sound.play(Paths.sound('confirmLaptop'));
                            new FlxTimer().start(1.5, function(tmr:FlxTimer)
                            {
                                FlxG.sound.play(Paths.sound('pageTurn'), 1.7);
                                var miles:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('secrets/miles'));
                                miles.screenCenter();
                                miles.antialiasing = true;
                                miles.alpha = 0;
                                add(miles);
                                FlxTween.tween(miles, {alpha: 1}, 1);
                                new FlxTimer().start(1, function(tmr:FlxTimer)
                                {
                                    exitLock = false;
                                });
                            });
                        }
                        case "angel":
                        {
                            screenLock = true;
                            exitLock = true;
                            FlxG.sound.play(Paths.sound('confirmLaptop'));
                            new FlxTimer().start(1.5, function(tmr:FlxTimer)
                            {
                                FlxG.sound.play(Paths.sound('pageTurn'), 1.7);
                                var miles:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('secrets/miles'));
                                miles.screenCenter();
                                miles.antialiasing = true;
                                miles.alpha = 0;
                                add(miles);
                                FlxTween.tween(miles, {alpha: 1}, 1);
                                new FlxTimer().start(1, function(tmr:FlxTimer)
                                {
                                    exitLock = false;
                                });
                            });
                        }
                        case "angelgutz":
                        {
                            screenLock = true;
                            exitLock = true;
                            FlxG.sound.play(Paths.sound('confirmLaptop'));
                            new FlxTimer().start(1.5, function(tmr:FlxTimer)
                            {
                                FlxG.sound.play(Paths.sound('pageTurn'), 1.7);
                                var miles:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('secrets/miles'));
                                miles.screenCenter();
                                miles.antialiasing = true;
                                miles.alpha = 0;
                                add(miles);
                                FlxTween.tween(miles, {alpha: 1}, 1);
                                new FlxTimer().start(1, function(tmr:FlxTimer)
                                {
                                    exitLock = false;
                                });
                            });
                        }
                        case "loss":
                        {
                            screenLock = true;
                            exitLock = true;
                            FlxG.sound.play(Paths.sound('confirmLaptop'));
                            new FlxTimer().start(1.5, function(tmr:FlxTimer)
                            {
                                FlxG.sound.play(Paths.sound('pageTurn'), 1.7);
                                var loss:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('secrets/loss'));
                                loss.screenCenter();
                                loss.antialiasing = true;
                                loss.alpha = 0;
                                add(loss);
                                FlxTween.tween(loss, {alpha: 1}, 1);
                                new FlxTimer().start(1, function(tmr:FlxTimer)
                                {
                                    exitLock = false;
                                });
                            });
                        }
                        case "el wiwi":
                        {
                            screenLock = true;
                            exitLock = true;
                            FlxG.sound.play(Paths.sound('confirmLaptop'));
                            new FlxTimer().start(1.5, function(tmr:FlxTimer)
                            {
                                FlxG.sound.play(Paths.sound('pageTurn'), 1.7);
                                var elWiwi:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('secrets/elWiwi'));
                                elWiwi.screenCenter();
                                elWiwi.antialiasing = true;
                                elWiwi.alpha = 0;
                                add(elWiwi);
                                FlxTween.tween(elWiwi, {alpha: 1}, 1);
                                new FlxTimer().start(1, function(tmr:FlxTimer)
                                {
                                    exitLock = false;
                                });
                            });
                        }
                        case "welcome to funk space":
                        {
                            screenLock = true;
                            exitLock = true;
                            FlxG.sound.play(Paths.sound('confirmLaptop'));
                            new FlxTimer().start(1.5, function(tmr:FlxTimer)
                            {
                                FlxG.sound.play(Paths.sound('pageTurn'), 1.7);
                                var omoriMenuBG = new FlxSprite().loadGraphic(Paths.image('omoriMenuBG'));
                                omoriMenuBG.screenCenter();
                                omoriMenuBG.antialiasing = true;
                                omoriMenuBG.alpha = 0;
                                add(omoriMenuBG);
                                FlxTween.tween(omoriMenuBG, {alpha: 1}, 1);
                                new FlxTimer().start(1, function(tmr:FlxTimer)
                                {
                                    exitLock = false;
                                });
                            });
                        }
                        case "guilty as charged":
                        {
                            screenLock = true;
                            exitLock = true;
                            FlxG.sound.play(Paths.sound('confirmLaptop'));
                            new FlxTimer().start(1.5, function(tmr:FlxTimer)
                            {
                                FlxG.sound.play(Paths.sound('pageTurn'), 1.7);
                                var guiltyAsCharged = new FlxSprite().loadGraphic(Paths.image('secrets/guiltyAsCharged'));
                                guiltyAsCharged.screenCenter();
                                guiltyAsCharged.antialiasing = true;
                                guiltyAsCharged.alpha = 0;
                                add(guiltyAsCharged);
                                FlxTween.tween(guiltyAsCharged, {alpha: 1}, 1);
                                new FlxTimer().start(1, function(tmr:FlxTimer)
                                {
                                    exitLock = false;
                                });
                            });
                        }
                        case "duck":
                        {
                            screenLock = true;
                            exitLock = true;
                            FlxG.sound.play(Paths.sound('confirmLaptop'));
                            new FlxTimer().start(1.5, function(tmr:FlxTimer)
                            {
                                FlxG.sound.play(Paths.sound('pageTurn'), 1.7);
                                var duck:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('secrets/duck'));
                                duck.screenCenter();
                                duck.antialiasing = true;
                                duck.alpha = 0;
                                add(duck);
                                FlxTween.tween(duck, {alpha: 1}, 1);
                                new FlxTimer().start(1, function(tmr:FlxTimer)
                                {
                                    exitLock = false;
                                });
                            });
                        }
                        case "wombo":
                        {
                            screenLock = true;
                            exitLock = true;
                            FlxG.sound.play(Paths.sound('confirmLaptop'));
                            new FlxTimer().start(1.5, function(tmr:FlxTimer)
                            {
                                FlxG.sound.play(Paths.sound('pageTurn'), 1.7);
                                var wombo:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('secrets/wombo'));
                                wombo.screenCenter();
                                wombo.antialiasing = true;
                                wombo.alpha = 0;
                                add(wombo);
                                FlxTween.tween(wombo, {alpha: 1}, 1);
                                new FlxTimer().start(1, function(tmr:FlxTimer)
                                {
                                    exitLock = false;
                                });
                            });
                        }
                        default:
                        {
                            FlxG.switchState(new MainMenuState());
                        }
                    }
                }
                else if (exitLock == true)
                {
                    // do nothing lmao
                }
                else
                {
                    FlxG.switchState(new MainMenuState());
                }
            }
        }
    }
    function unlockText():Void
    {
        screenLock = false;
    }
    function unlockExit():Void
    {
        exitLock = false;
    }
}