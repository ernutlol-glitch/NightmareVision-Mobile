package extensions.flixel;

import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.FlxG;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.StrNameLabel;

class FlxUIDropDownMenuEx extends FlxUIDropDownMenu
{
    var currentScroll:Int = 0; 
    public var canScroll:Bool = true;
    private var _lastTouchY:Float = -1;

    public function new(X:Float = 0, Y:Float = 0, DataList:Array<StrNameLabel>, ?Callback:String->Void, ?Header:FlxUIDropDownHeader, ?DropPanel:FlxUI9SliceSprite, ?ButtonList:Array<FlxUIButton>, ?UIControlCallback:Bool->FlxUIDropDownMenu->Void)
    {
        super(X, Y, DataList, Callback, Header, DropPanel, ButtonList, UIControlCallback);
        dropDirection = Down;
    }

    override function updateButtonPositions():Void
    {
        var buttonHeight = header.background.height;
        dropPanel.y = header.background.y;
        if (dropsUp()) dropPanel.y -= getPanelHeight();
        else dropPanel.y += buttonHeight;

        var offset = dropPanel.y;
        for (i in 0...currentScroll)
        { 
            var button:FlxUIButton = list[i];
            if (button != null) button.y = -99999;
        }
        for (i in currentScroll...list.length)
        {
            var button:FlxUIButton = list[i];
            if (button != null) {
                button.y = offset;
                offset += buttonHeight;
            }
        }
    }

    public override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (dropPanel.visible && list.length > 1 && canScroll)
        {
            var dragUp:Bool = false;
            var dragDown:Bool = false;

            #if FLX_MOUSE
            if (FlxG.mouse.wheel > 0 || FlxG.keys.justPressed.UP) dragUp = true;
            if (FlxG.mouse.wheel < 0 || FlxG.keys.justPressed.DOWN) dragDown = true;
            #end

            #if android
            if (FlxG.touches.list.length > 0) {
                var touch = FlxG.touches.list[0];
                if (touch.pressed) {
                    if (_lastTouchY != -1) {
                        var delta = touch.screenY - _lastTouchY;
                        if (delta > 30) { dragUp = true; _lastTouchY = touch.screenY; }
                        else if (delta < -30) { dragDown = true; _lastTouchY = touch.screenY; }
                    } else {
                        _lastTouchY = touch.screenY;
                    }
                } else {
                    _lastTouchY = -1;
                }
            }
            #end

            if (dragUp) {
                --currentScroll;
                if (currentScroll < 0) currentScroll = 0;
                updateButtonPositions();
            } else if (dragDown) {
                currentScroll++;
                if (currentScroll >= list.length) currentScroll = list.length - 1;
                updateButtonPositions();
            }

            #if android
            var releasedTouches = FlxG.touches.justReleased();
            if (releasedTouches.length > 0) {
                // Si soltamos fuera de la lista y del botón principal, cerramos
                if (!releasedTouches[0].overlaps(this) && !releasedTouches[0].overlaps(header)) {
                    showList(false);
                }
            }
            #end
        }
    }

        override private function showList(b:Bool):Void
    {
        super.showList(b);

        if(!b && currentScroll != 0) {
            currentScroll = 0;
            updateButtonPositions();
        }

        #if !android
        FlxUI.forceFocus(b, this);
        #end
    }
} 