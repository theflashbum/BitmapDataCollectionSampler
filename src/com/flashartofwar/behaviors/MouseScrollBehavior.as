package com.flashartofwar.behaviors
{
import com.flashartofwar.events.TrainEvent;

import flash.display.Graphics;
import flash.display.Shape;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.geom.Rectangle;

public class MouseScrollBehavior extends EventDispatcher
{
    protected var scrollWidth:Number = 0;
    protected var rightBorder:Number = 0;
    protected var visibleRect:Rectangle;
    protected var hitRect:Rectangle;
    protected var hitRect2:Rectangle;
    protected var halfwayPoint:Number;

    protected var mX:Number;
    protected var mY:Number;
    protected var speed:Number = 0;
    protected var targPos:Number = 0;
    protected var leftBorder:Number = 0;
    protected var debugHitRects:Shape;
    protected var cachedX:Array = new Array();
    public var hitAreaPercent:Number = .5;
    public var containerIDs:Array = [];
    public var hitRectHeight:Number = 423;
    public var hitRectDebug:Boolean;
    public var useMouseControls:Boolean = true;


    /**
     *
     *
     */
    public function MouseScrollBehavior(visibleRect:Rectangle, scrollWidth:Number)
    {
        this.visibleRect = visibleRect.clone();
        this.scrollWidth = scrollWidth;
        refreshViewPort();
    }

    /**
     *
     * @param value
     *
     */
    public function set width(value:Number):void
    {
        visibleRect.width = value;
        refreshViewPort();
    }

    public function get width():Number
    {
        return visibleRect.width;
    }

    /**
     *
     *
     */
    protected function onScrollingMode():void
    {
        useMouseControls = true;
    }

    /**
     *
     * @param config
     *
     */
    protected function init():void
    {

    }

    /**
     *
     *
     */
    protected function refreshViewPort():void
    {
        redrawHitRects();
        rightBorder = -Number(scrollWidth - visibleRect.width);
    }

    /**
     *
     * @param e
     *
     */
    protected function onToggelMouseActive(e:Event):void
    {
        var type:String = e.type;
        if (type == TrainEvent.MOUSE_ACTIVATE)
        {
            useMouseControls = true;
        }
        else if (type == TrainEvent.MOUSE_DEACTIVATE)
        {
            useMouseControls = false;
        }
    }

    /**
     *
     *
     */
    public function reset():void
    {
        targPos = 0;
    }

    /**
     * This refreshes the redrawHitRects.
     */
    protected function redrawHitRects():void {

        var tmpW:Number = convertPosToValue(hitAreaPercent, visibleRect.width) + 1;
        var tempHR2X:Number = visibleRect.width - tmpW;

        hitRect = new Rectangle(0, 0, tmpW, hitRectHeight);
        hitRect2 = new Rectangle(tempHR2X, 0, tmpW, hitRectHeight);

        // Find halfway mark for mask
        halfwayPoint = visibleRect.width / 2;
    }


    /**
     * This is for debug only. Pass in a Sprite or Shape's graphic to see a debug
     * display of the hitarea.
     *
     * @param target
     */
    public function displayHitRects(target:Graphics):void
    {
        target.clear();
        target.beginFill(0xff0000, .2);
        target.drawRect(hitRect.x, hitRect.y, hitRect.width, hitRect.height);
        target.endFill();
        target.beginFill(0x00ff00, .2);
        target.drawRect(hitRect2.x, hitRect2.y, hitRect2.width, hitRect2.height);
        target.endFill();

    }

    /**
     *
     * @param pos
     * @param max
     * @return
     *
     */
    public function convertPosToValue(pos:Number, max:Number):Number {
        return Number(pos * max);
    }


    /**
     *
     * @param e
     *
     */
    public function calculateTargetPos(mX:Number, mY:Number):void {

        // Set Mouse zone
        var zone:String = (mX <= halfwayPoint) ? "right" : "left";

        // Detect Mouse position based on Middle of Mask and see what hitRec to test agenst.
        var targetHitRect:Rectangle = (zone == "right") ? hitRect : hitRect2;

        //set value if scrolling from a source other than mouse
        if (targetHitRect.contains(mX, mY))
        {
            var reverse:Boolean = (zone == "right") ? true : false;
            speed = getRange((zone == "right") ? mX : (mX - targetHitRect.x), targetHitRect.width, reverse);
            //targPos += (zone == "right") ? Math.ceil(speed * 50) : Math.ceil(- speed * 50);
        }
        //trace("speed", speed);
        /*
         if(targPos >= 0)
         {
         targPos = leftBorder;
         //				//TODO dispatch Beginning event
         }
         else if(targPos <= rightBorder)
         {
         targPos = rightBorder;
         //				//TODO dispatch End Event
         }
         else
         {
         //TODO dispatch Middle Event
         }*/

    }


    /**
     *
     * @param pos
     * @param max
     * @param reverse
     * @param round
     * @return
     *
     */
    public function getRange(pos:Number, max:Number, reverse:Boolean = false, round:Boolean = true):Number {

        // Calculate
        var value:Number = Math.max(0, Math.min(1, pos / max));

        // Round
        if (round) value = int((value) * 100) / 100;

        // Reverse
        value = (reverse) ? Number(1 - value) : value;

        return value;
    }


}
}